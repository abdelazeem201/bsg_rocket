//========================================================================
// bnn-random-dense-xcel
//========================================================================
// This is a test, not really a ubmark. It runs a small randomized set of
// feature maps through the BNN convolution layer as well as through a 
// golden reference and compares the two.
// This test focuses on the dense layers

#include "bnn_common.h"
#include "bnn_data.h"
#include "bnn_params.h"

#ifndef __KH_OFFSET_DEFAULT
#define __KH_OFFSET_DEFAULT 1
#endif

#ifndef __WT_OFFSET_DEFAULT
#define __WT_OFFSET_DEFAULT 20
#endif

static uint32_t WT_OFFSET = __WT_OFFSET_DEFAULT;
static uint32_t KH_OFFSET = __KH_OFFSET_DEFAULT;
const unsigned M = CONVOLVERS * WORD_SIZE;
const unsigned N = WORD_SIZE;
const uint32_t I_SIZE = 4096/2; // num words of random data available
const uint32_t W_SIZE = 9364/2; // num words of random wts available

#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))
  static Word volatile data_o_buf[DMEM_WORDS];
#endif

#ifndef __SNEAK_PATH
#define __SNEAK_PATH false
#endif

//------------------------------------------------------------------------
// Test function
//------------------------------------------------------------------------
void test_dense_layer_random(
    Word* data_i, volatile Word* data_o,
    Word* wt,
    Word* kh,
    bool isSneakPath
) {
  printf ("## Running bnn-test-random-dense (M=%u words) ##\n", M/WORD_SIZE);
  const uint32_t o_words = N/WORD_SIZE;

  // Zero the output and reference array
  Word bin_ref[o_words];
  for (uint32_t i = 0; i < o_words; ++i) {
    data_o[i] = 0;
    bin_ref[i] = 0;
  }

  // Find value of KH
  KType ki;  HType hi;
  get_reference_kh(&ki, &hi, KH_OFFSET);
  //int64_t nc = (hi>0) ? -M_INT : M_INT;
  //if (ki != 0) nc = -(hi/ki);

  // Compute golden reference
  for (unsigned nw = 0; nw < N/WORD_SIZE; ++nw) {
    for (unsigned nb = 0; nb < WORD_SIZE; ++nb) {

      int sum = 0;
      const unsigned n = nw*WORD_SIZE + nb;

      // loop over input and weight bits
      for (unsigned m = 0; m < M/WORD_SIZE; ++m) {
        Word in_word = data_i[m];
        Word wt_word = wt[n*M/WORD_SIZE + m];
        // xor
        Word x = in_word ^ wt_word;
        // popcount
        Word mask = 1;
        for (unsigned b = 0; b < WORD_SIZE; ++b ) {
          sum += ((x & mask) == 0) ? 1 : -1;
          mask = mask << 1;
        }
      }

      // generate 1 output bit
      //Bit b = (sum < nc) ? 1 : 0;
      Bit b = (ki*(double)sum + hi < 0) ? 1 : 0;
      set_bit(bin_ref, nw*WORD_SIZE+nb, b);
      //printf ("* bit%d> (%4d) %d\n", nb, sum, b);

    }
  }

  // Call BNN
  uint32_t layer_mode = 0x5;  // [2:1]="conv1, conv, dense", [0]=new layer
  uint32_t n_inputs = M;
  uint32_t n_outputs = N;
  uint32_t input_words = M/WORD_SIZE;
  uint32_t output_words = o_words;
  uint32_t wt_bits = M*N;
  uint32_t wt_offset = 0;
  uint32_t dmem_mode = 0;
  uint32_t width_mode = 0;
  uint32_t norm_mode = 0; // 0='nothing', 1='do norm', 2='do pool'

  assert(input_words > 0);
  assert(output_words > 0);
  assert(input_words <= DMEM_WORDS);
  assert(output_words <= DMEM_WORDS);
  assert(wt_bits > 0);
  assert(wt_bits <= WT_WORDS * WORD_SIZE);

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
    printf ("*bin out*:\n");
    print_bits3d(data_o, 0, 1, 16, 4,16);
    printf ("*bin ref*:\n");
    print_bits3d(bin_ref, 0, 1, 16, 4,16);
  );

  // Compare bin results
  DB_PRINT (1, "## Checking results (N=%u words) ##\n", o_words);
  uint32_t n_err = 0;
  for (uint32_t n = 0; n < o_words; ++n) {
    Word diff = data_o[n] ^ bin_ref[n];
    n_err += popcount2(diff);
  }
  double err_rate = (double)n_err/N * 100;
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
  bool isSneakPath = __SNEAK_PATH;

  // Skip first one!
  for(int i = 1; i < argc; i++)
  {
    // Process arguments in the format:
    //     --args=%d
    START_ARGS_PARSER
    CHECK_ARGS_INT("--wt_offset"  , WT_OFFSET  );
    CHECK_ARGS_INT("--kh_offset"  , KH_OFFSET  );
    CHECK_ARGS_BOOL("--sneak_path", isSneakPath);
  }

  printf("\nConfiguration:\n");
  printf("  Weights' Offset = %d\n", WT_OFFSET);
  printf("  KHs'     Offset = %d\n", KH_OFFSET);
  if (isSneakPath)
    printf("  Sneak path is enabled\n" );
  else
    printf("  Sneak path is disabled\n");
  printf("\n");

  assert(M <= I_SIZE*WORD_SIZE);
  assert(M <= DMEM_WORDS*WORD_SIZE);
  assert(N <= DMEM_WORDS*WORD_SIZE);
  assert(N <= KH_WORDS*WORD_SIZE);
  assert(M*N <= WT_WORDS*WORD_SIZE);
  assert(I_SIZE <= DMEM_WORDS);
  assert(W_SIZE <= WT_WORDS);
  assert(WT_OFFSET + CONVOLVERS*PIX_PER_PHASE < W_SIZE);

#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))
  Word volatile *data_o  = (Word volatile *)data_o_buf;
#else
  Word volatile *data_o  = (Word volatile *)malloc(DMEM_WORDS * sizeof(Word));
#endif

  Word* data_i;
  Word* wt;
  Word kh[N/2];

  // Load the input data
  data_i = (Word*) data_random_uint32t;

  // Load the kernel weights
  wt = &((Word*)wt_random_uint32t)[WT_OFFSET];

  // For batch norm params we need floats for the baseline
  // and fixed-point for the xcel. We hardcode the floats
  // and load the fixed-points.
  //Word* kh_array_word = (Word*) kh_random_uint32t;
  Word* kh_array_word = (Word*) kh_random_uint32t;
  for (unsigned i = 0; i < N/2; ++i) {
    // set both the top and bottom 32 bits to kh_array_word[KH_OFFSET]
    Word kh32 = kh_array_word[KH_OFFSET];
    Word kh_word = kh32 << 32;  // fill upper 32 bits
    kh_word = kh_word | kh32;   // fill lower 32 bits
    kh[i] = kh_word;
  }

  // Page-faults
  // data_i
  LOAD_STATIC_ARRAY(data_random_uint32t);

  //data_o
  LOAD_ARRAY(data_o, DMEM_WORDS, sizeof(Word));

  // wt
  LOAD_STATIC_ARRAY(wt_random_uint32t);

  test_dense_layer_random(data_i, data_o, wt, kh, isSneakPath);

#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))
  data_o = NULL;
#else
  free((void *)data_o);
#endif

  printf ("Tests passed!\n");
  return 0;
}
