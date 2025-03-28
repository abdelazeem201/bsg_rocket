//========================================================================
// bnn-random-conv-xcel
//========================================================================
// This is a test, not really a ubmark. It runs a small randomized set of
// feature maps through the BNN convolution layer as well as through a 
// golden reference and compares the two.

#include "bnn_common.h"
#include "bnn_data.h"
#include "bnn_params.h"

#ifndef __KH_OFFSET_DEFAULT
#define __KH_OFFSET_DEFAULT 1
#endif

#ifndef __WT_OFFSET_DEFAULT
#define __WT_OFFSET_DEFAULT 10
#endif

#ifndef __INPUT_WIDTH
#define __INPUT_WIDTH 8
#endif

#ifndef __SNEAK_PATH
#define __SNEAK_PATH false
#endif

static uint32_t WT_OFFSET = __WT_OFFSET_DEFAULT;
static uint32_t KH_OFFSET = __KH_OFFSET_DEFAULT;
const uint32_t I_SIZE = 4096/2; // num words of random data available
const uint32_t W_SIZE = 9364/2; // num words of random wts available

#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))
  static Word volatile data_o_buf[DMEM_WORDS];
#endif

//------------------------------------------------------------------------
// Test function
//------------------------------------------------------------------------
void test_conv_layer_random(
    const uint32_t S,
    Word* data_i, volatile Word* data_o,
    Word* wt,
    Word* kh,
    bool isSneakPath
) {
  const unsigned M = CONVOLVERS * PIX_PER_PHASE / (S*S);
  assert (M*S*S <= I_SIZE*WORD_SIZE);

  printf ("## Running bnn-test-random (width=%u) ##\n", S);
  int64_t conv_ref[S*S];
  Word bin_ref[S*S];

  // Find value of KH
  KType ki;  HType hi;
  get_reference_kh(&ki, &hi, KH_OFFSET);
  int64_t nc = (hi>0) ? -M_INT : M_INT;
  if (ki != 0) nc = -(hi/ki);

  // Compute golden reference
  conv2d_padded(data_i, wt, conv_ref, M, S);
  for (uint32_t i = 0; i < S*S; ++i) {
    Bit b = (conv_ref[i] < nc) ? 1 : 0;
    set_bit(bin_ref, i, b);
  }

  // Call BNN
  uint32_t layer_mode = 0x3;  // [2:1]="conv1, conv, dense", [0]=new layer
  uint32_t n_inputs = M;
  uint32_t n_outputs = 1;
  uint32_t input_words = M*S*S/WORD_SIZE;
  uint32_t output_words = S*S/WORD_SIZE;
  uint32_t wt_bits = n_inputs * n_outputs * WT_SIZE;
  uint32_t wt_offset = 0;
  uint32_t dmem_mode = 0;
  uint32_t width_mode = S >> 4;
  uint32_t norm_mode = 1; // 0='nothing', 1='do norm', 2='do pool'

  assert(input_words > 0);
  assert(output_words > 0);
  assert(input_words <= DMEM_WORDS);
  assert(output_words <= DMEM_WORDS);
  assert(wt_bits > 0);
  assert(wt_bits <= WT_WORDS * WT_SIZE * CONV_W_PER_WORD);

  if (isSneakPath)
    wt = (Word*)__SNEAK_PATH_MAGICAL_ADDRESS;

  test_stats_on();
  bnn_xcel(
      wt, kh, data_i, data_o,
      n_inputs, n_outputs,
      input_words, output_words,
      wt_bits, wt_offset,
      layer_mode, dmem_mode,
      width_mode, norm_mode
  );
  test_stats_off();

  // print results
  DB(2,
    printf ("*conv ref*:\n");
    print_mat3d(conv_ref, 0, 1, S, 8,S);
  );
  DB(2,
    printf ("*bin out*:\n");
    print_bits3d(data_o, 0, 1, S, 8,S);
    printf ("*bin ref*:\n");
    print_bits3d(bin_ref, 0, 1, S, 8,S);
  );

  // Compare bin results
  DB_PRINT (1, "## Checking results (width=%u) ##\n", S);
  uint32_t n_err = 0;
  for (uint32_t n = 0; n < S*S/WORD_SIZE; ++n) {
    Word diff = data_o[n] ^ bin_ref[n];
    n_err += popcount2(diff);
  }
  double err_rate = (double)n_err/(S*S) * 100;
#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))
  uint32_t int_part  = (uint32_t)err_rate;
  uint32_t frac_part = (uint32_t)((err_rate - int_part) * 1000);
  printf ("Error rate: %d.%03d%%\n", int_part, frac_part);
#else
  printf ("Error rate: %7.4f%%\n", err_rate);
#endif
  assert(err_rate >= 0 && err_rate < 0.1);
}

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------
int main(int argc, char** argv) {
  bool     isSneakPath = __SNEAK_PATH ;
  uint32_t input_width = __INPUT_WIDTH;

  // Skip first one!
  for(int i = 1; i < argc; i++)
  {
    // Process arguments in the format:
    //     --args=%d
    START_ARGS_PARSER
    CHECK_ARGS_INT("--wt_offset"  , WT_OFFSET  );
    CHECK_ARGS_INT("--kh_offset"  , KH_OFFSET  );
    CHECK_ARGS_INT("--input_width", input_width);
    CHECK_ARGS_BOOL("--sneak_path", isSneakPath);
  }

  printf("\nConfiguration:\n");
  printf("  Weights' Offset = %d\n", WT_OFFSET  );
  printf("  KHs'     Offset = %d\n", KH_OFFSET  );
  printf("  Input    width  = %d\n", input_width);
  if (isSneakPath)
    printf("  Sneak path is enabled\n" );
  else
    printf("  Sneak path is disabled\n");
  printf("\n");

  assert(I_SIZE <= DMEM_WORDS);
  assert(W_SIZE <= WT_WORDS);
  assert(WT_OFFSET + CONVOLVERS*PIX_PER_PHASE < W_SIZE);
  assert((input_width == 8) || (input_width == 16) || (input_width == 32));

#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))
  Word volatile *data_o  = (Word volatile *)data_o_buf;
#else
  Word volatile *data_o  = (Word volatile *)malloc(DMEM_WORDS * sizeof(Word));
#endif

  Word* data_i;
  Word* wt;
  Word* kh;

  // Load the input data
  data_i = (Word*) data_random_uint32t;

  // Load the kernel weights
  wt = &((Word*)wt_random_uint32t)[WT_OFFSET];

  // For batch norm params we need floats for the baseline
  // and fixed-point for the xcel. We hardcode the floats
  // and load the fixed-points.
  kh = &((Word*)kh_random_uint32t)[KH_OFFSET];

  // Page-faults
  // data_i
  LOAD_STATIC_ARRAY(data_random_uint32t);

  //data_o
  LOAD_ARRAY(data_o, DMEM_WORDS, sizeof(Word));

  // wt
  LOAD_STATIC_ARRAY(wt_random_uint32t);

  // kh
  asm volatile
  (
    "ld zero, %[mem_addr_kh]\n"
    :
    : [mem_addr_kh] "m"(kh[0])
    : "memory"
  );

  // test three different input sizes
  test_conv_layer_random(input_width, data_i, data_o, wt, kh, isSneakPath);

#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))
  data_o = NULL;
#else
  free((void *)data_o);
#endif

  printf ("Tests passed!\n");
  return 0;
}
