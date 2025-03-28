//========================================================================
// bnn-layer-xcel
//========================================================================
// This is a test, not really a ubmark. It runs a small randomized set of
// feature maps through the BNN convolution layer as well as through a 
// golden reference and compares the two.

#include "bnn_common.h"
#include "bnn_data.h"
#include "bnn_params.h"

#ifndef __LAYER_NUMBER
#define __LAYER_NUMBER 1
#endif

#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))

#define MAX_DATA_O 2048
static Word volatile data_o_buf[MAX_DATA_O];

#endif

#ifndef __SNEAK_PATH
#define __SNEAK_PATH false
#endif

//------------------------------------------------------------------------
// Correct error rate we expect on each layer
//------------------------------------------------------------------------
const float bnn_layer_ref_err[8] = {
  0.00763,
  0.29907,
  0.60272,
  1.10474,
  0.53101,
  0.19531,
  0.68359,
  0.00000
};

const float ERR_BOUND = 0.00001;

//------------------------------------------------------------------------
// Test function for conv layers
//------------------------------------------------------------------------
void test_conv_layer(
    Word* wt,     Word* kh,
    Word* data_i, volatile Word* data_o,
    Word* bin_ref,
    const uint32_t M,
    const uint32_t N,
    const uint32_t Si,
    const uint32_t conv_mode, // 0=conv1, 1=conv
    const uint32_t max_pool,
    const float    err_ref,
          bool     isSneakPath
) {
  printf ("#### Testing convolution with %u inputs, width %u ####\n", M, Si);
  uint32_t So = max_pool ? Si/2 : Si;
  uint32_t input_words = conv_mode==0 ? Si*Si : M*Si*Si/WORD_SIZE;
  uint32_t output_words = N*So*So/WORD_SIZE;
  assert (input_words  > 0);
  assert (output_words > 0);
  assert (input_words  <= DMEM_WORDS);
  assert (output_words <= DMEM_WORDS);

  DB(3,
    printf ("*data*:\n");
    print_bits3d(data_i, 0, 1, Si, 6,Si);
    printf ("*params*:\n");
    print_params3d(wt, 0, 15);
  )

  test_stats_on();
  run_layer(
      // data in   data out
      data_i     , data_o      ,
      // Weights   KH
      wt         , kh          ,
      // # Ins     # Outs
      M          , N           ,
      // Width     Layer Idx
      Si         , 0           ,
      // In wrds   Out wrds
      input_words, output_words,
      // dmem_mode
      0          ,
      // type      max pool
      conv_mode  , max_pool    ,
      // Sneak path activation
      isSneakPath 
  );
  test_stats_off();

  // print results
  //printf ("*bin out*:\n");
  //print_bits3d(data_o, 8, 1, So, 8,So);
  //printf ("*bin ref*:\n");
  //print_bits3d(bin_ref, 8, 1, So, 8,So);

  // Compare bin results
  printf ("## Checking results ##\n");
  uint32_t n_err = 0;
  for (uint32_t n = 0; n < output_words; ++n) {
    Word diff = data_o[n] ^ bin_ref[n];
    n_err += popcount2(diff);
  }
  double err_rate = (double)n_err / (N * So * So) * 100;
#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))
  uint32_t int_part  = (uint32_t)err_rate;
  uint32_t frac_part = (uint32_t)((err_rate - int_part) * 100000);
  printf ("Error rate: %d.%05d%%\n", int_part, frac_part);
           int_part  = (uint32_t)err_ref;
           frac_part = (uint32_t)((err_ref - int_part) * 100000);
  printf ("Ref error : %d.%05d%%\n", int_part, frac_part);
#else
  printf ("Error rate: %9.5f%%\n", err_rate);
  printf ("Ref error : %9.5f%%\n", err_ref);
#endif
  assert((err_rate > err_ref-ERR_BOUND) && (err_rate < err_ref+ERR_BOUND));
}

//------------------------------------------------------------------------
// Test function for dense layers
//------------------------------------------------------------------------
void test_dense_layer(
    Word* wt,     Word* kh,
    Word* data_i, volatile Word* data_o,
    Word* bin_ref,
    const uint32_t M,   // pixels
    const uint32_t N,   // pixels
    const float    err_ref,
          bool     isSneakPath
) {
  assert(M/WORD_SIZE > 0);
  assert(N/WORD_SIZE > 0);

  printf ("#### Testing dense layer with %u inputs, %u outputs ####\n", M, N);
  DB(3,
    printf ("*data*:\n");
    print_bits(data_i, 0, 16, 8, 16);
    printf ("*params*:\n");
    print_bits(wt, 0, 16, 8, 16);
  )

  uint32_t input_words  = M / WORD_SIZE;
  uint32_t output_words = N / WORD_SIZE;

  test_stats_on();
  run_layer(
      // data in   data out
      data_i     , data_o      ,
      // Weights   KH
      wt         , kh          ,
      // # Ins     # Outs
      M          , N           ,
      // Width     Layer Idx
      1          , 0           ,
      // In wrds   Out wrds
      input_words, output_words,
      // dmem_mode
      0          ,
      // type      max pool
      2          , 0           ,
      // Sneak path activation
      isSneakPath 
  );
  test_stats_off();

  // print results
  //printf ("Word: output vs reference\n");
  //for (uint32_t i = 0; i < N/WORD_SIZE; ++i) {
  //  printf (" %3d:  %16lx  %16lx\n", i, data_o[i], bin_ref[i]);
  //}

  // Compare bin results
  printf ("## Checking results ##\n");
  uint32_t n_err = 0;
  for (uint32_t n = 0; n < N/WORD_SIZE; ++n) {
    Word diff = data_o[n] ^ bin_ref[n];
    n_err += popcount2(diff);
  }
  double err_rate = (double)n_err/N * 100;
#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))
  uint32_t int_part  = (uint32_t)err_rate;
  uint32_t frac_part = (uint32_t)((err_rate - int_part) * 100000);
  printf ("Error rate: %d.%05d%%\n", int_part, frac_part);
           int_part  = (uint32_t)err_ref;
           frac_part = (uint32_t)((err_ref - int_part) * 100000);
  printf ("Ref error : %d.%05d%%\n", int_part, frac_part);
#else
  printf ("Error rate: %9.5f%%\n", err_rate);
  printf ("Ref error : %9.5f%%\n", err_ref);
#endif
  assert((err_rate > err_ref-ERR_BOUND) && (err_rate < err_ref+ERR_BOUND));
}


const uint32_t S_tab[] =  { 32,  32,  16,  16,   8,   8,    4,    1,    1};
const uint32_t M_tab[] =  {  3, 128, 128, 256, 256, 512, 8192, 1024, 1024};
const uint32_t N_tab[] =  {128, 128, 256, 256, 512, 512, 1024, 1024,   10};
const uint32_t widx_tab[] = {0,   3,   6,   9,  12,  15,   18,   21,   24};
const uint32_t kidx_tab[] = {1,   4,   7,  10,  13,  16,   19,   22,   25};
const uint32_t hidx_tab[] = {2,   5,   8,  11,  14,  17,   20,   23,   26};
const uint32_t pool_tab[] = {0,   1,   0,   1,   0,   1,    0,    0,    0};

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------
int main(int argc, char** argv) {
  uint32_t l           = __LAYER_NUMBER;
  bool     isSneakPath = __SNEAK_PATH;

  // Skip first one!
  for(int i = 1; i < argc; i++)
  {
    // Process arguments in the format:
    //     --args=%d
    START_ARGS_PARSER
    CHECK_ARGS_INT("--layer_id"   , l          );
    CHECK_ARGS_BOOL("--sneak_path", isSneakPath);
  }

  const uint32_t lconv = 6;
  
  printf("\nConfiguration:\n");
  printf("  Layer ID = %d\n", l);
  if (isSneakPath)
    printf("  Sneak path is enabled\n" );
  else
    printf("  Sneak path is disabled\n");
  printf("\n");

  // print some config numbers
  printf ("* WT_WORDS   = %u\n", WT_WORDS);
  printf ("* KH_WORDS   = %u\n", KH_WORDS);
  
  const uint32_t Si = (l <= lconv) ? S_tab[l-1] : 1;
  const uint32_t So = (l <= lconv) ? S_tab[l] : 1;
  const uint32_t M = M_tab[l-1];
  const uint32_t N = N_tab[l-1];
  const uint32_t data_i_size = (l==1) ? Si*Si : ((l<=lconv) ? M*Si*Si/WORD_SIZE : M/WORD_SIZE );
  const uint32_t data_o_size = (l<=lconv) ? N*So*So/WORD_SIZE : ((l!=9) ? N/WORD_SIZE : 1);
  const uint32_t wt_words    = (l<=lconv) ? WTS_TO_WORDS(M*N) : M*N/WORD_SIZE;
  assert(data_i_size <= DMEM_WORDS);
  assert(data_o_size <= DMEM_WORDS);

#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))
  Word volatile *data_o  = (Word volatile *)data_o_buf;
#else
  Word volatile *data_o  = (Word volatile *)malloc(data_o_size * sizeof(Word));
#endif
 
  Word* data_i;
  Word* bin_ref;
  Word* wt;
  Word* kh;
  
  printf ("## Testing Layer %u with %u outputs ##\n", l, N);
  
  // Load test data and weights based on the layer number
  printf ("## Loading test params and data ##\n");
  if (l == 1) {
    data_i = (Word*)data_layer0_uint32t;
    bin_ref = (Word*)data_layer1_uint32t;
    wt = (Word*) wt_layer1_uint32t;
    kh = (Word*) kh_layer1_uint32t;
  } else if (l == 2) {
    data_i = (Word*)data_layer1_uint32t;
    bin_ref = (Word*)data_layer2_uint32t;
    wt = (Word*) wt_layer2_uint32t;
    kh = (Word*) kh_layer2_uint32t;
  } else if (l == 3) {
    data_i = (Word*)data_layer2_uint32t;
    bin_ref = (Word*)data_layer3_uint32t;
    wt = (Word*) wt_layer3_uint32t;
    kh = (Word*) kh_layer3_uint32t;
  } else if (l == 4) {
    data_i = (Word*)data_layer3_uint32t;
    bin_ref = (Word*)data_layer4_uint32t;
    wt = (Word*) wt_layer4_uint32t;
    kh = (Word*) kh_layer4_uint32t;
  } else if (l == 5) {
    data_i = (Word*)data_layer4_uint32t;
    bin_ref = (Word*)data_layer5_uint32t;
    wt = (Word*) wt_layer5_uint32t;
    kh = (Word*) kh_layer5_uint32t;
  } else if (l == 6) {
    data_i = (Word*)data_layer5_uint32t;
    bin_ref = (Word*)data_layer6_uint32t;
    wt = (Word*) wt_layer6_uint32t;
    kh = (Word*) kh_layer6_uint32t;
  } else if (l == 7) {
    data_i = (Word*)data_dense_layer0_uint32t;
    bin_ref = (Word*)data_dense_layer1_uint32t;
    wt = (Word*) wt_layer7_uint32t;
    kh = (Word*) kh_layer7_uint32t;
  } else if (l == 8) {
    data_i = (Word*)data_dense_layer1_uint32t;
    bin_ref = (Word*)data_dense_layer2_uint32t;
    wt = (Word*) wt_layer8_uint32t;
    kh = (Word*) kh_layer8_uint32t;
  } else if (l == 9) {
    data_i = (Word*)data_dense_layer2_uint32t;
    bin_ref = (Word*)data_dense_layer3_uint32t;
    wt = (Word*) wt_layer9_uint32t;
    kh = (Word*) kh_layer9_uint32t;
  } else {
    assert(0);
  }

  // data_i
  LOAD_ARRAY(data_i, data_i_size, sizeof(Word));

  // data_o
  LOAD_ARRAY(data_o, data_o_size, sizeof(Word));

  // wt
  LOAD_ARRAY(wt    , wt_words   , sizeof(Word));

  // kh
#if defined(_RISCV) && defined(_ROCKET) && defined(_PK)
  asm volatile
  (
    "ld zero, %[mem_addr_kh]\n"
    :
    : [mem_addr_kh] "m"(kh[0])
    : "memory"
  );
#endif

  const float err_ref = bnn_layer_ref_err[l-1];

  if (l <= lconv) {
    test_conv_layer(
      wt, kh, data_i, data_o, bin_ref,
      M, N, Si,
      (l==1) ? 0 : 1,   // conv_mode
      pool_tab[l-1] ,   // max_pool
      err_ref,
      isSneakPath
    );
  } else {
    test_dense_layer(
      wt, kh, data_i, data_o, bin_ref,
      M, N,
      err_ref,
      isSneakPath
    );
  }

  printf ("Tests passed!\n");
#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))
  data_o = NULL;
#else
  free((void*)data_o);
#endif
  return 0;
}
