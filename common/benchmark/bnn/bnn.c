//========================================================================
// bnn-full-xcel
//========================================================================
// This is a test, not really a ubmark. It runs a small randomized set of
// feature maps through the BNN convolution layer as well as through a 
// golden reference and compares the two.

#include "bnn_common.h"
#include "bnn_data.h"
#include "bnn_params.h"

const uint32_t T_tab[] =  {  0,   1,   1,   1,   1,   1,    2,    2,    3};
const uint32_t S_tab[] =  { 32,  32,  16,  16,   8,   8,    4,    1,    1};
const uint32_t M_tab[] =  {  3, 128, 128, 256, 256, 512, 8192, 1024, 1024};
const uint32_t N_tab[] =  {128, 128, 256, 256, 512, 512, 1024, 1024,   10};
const uint32_t widx_tab[] = {0,   3,   6,   9,  12,  15,   18,   21,   24};
const uint32_t kidx_tab[] = {1,   4,   7,  10,  13,  16,   19,   22,   25};
const uint32_t hidx_tab[] = {2,   5,   8,  11,  14,  17,   20,   23,   26};
const uint32_t pool_tab[] = {0,   1  , 0,   1,   0,   1,    0,    0,    0};

#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))

#define MAX_DATA_O 2048
static Word volatile data_o_buf[MAX_DATA_O];

#endif

#ifndef __SNEAK_PATH
#define __SNEAK_PATH false
#endif

#ifndef __NUM_IMAGES
#define __NUM_IMAGES 10
#endif

#ifndef __START_IDX
#define __START_IDX 0
#endif

int main(int argc, char** argv) {

  uint32_t n_imgs      = __NUM_IMAGES;
  uint32_t start_img   = __START_IDX ;
  bool     isSneakPath = __SNEAK_PATH;

  // Skip first one!
  for(int i = 1; i < argc; i++)
  {
    // Process arguments in the format:
    //     --args=%d
    START_ARGS_PARSER
    CHECK_ARGS_INT("--num_imgs"   , n_imgs     );
    CHECK_ARGS_INT("--start_img"  , start_img  );
    CHECK_ARGS_BOOL("--sneak_path", isSneakPath);
  }

  printf("\nConfiguration:\n");
  printf("  Starting image = %d\n", start_img);
  printf("  Number of images = %d\n", n_imgs);
  printf("  Images range = [%d, %d]\n", start_img, start_img + n_imgs - 1);
  if (isSneakPath)
    printf("  Sneak path is enabled\n" );
  else
    printf("  Sneak path is disabled\n");
  printf("\n");

  assert(n_imgs               >  0         );
  assert((start_img + n_imgs) <= N_IMGS_MAX);

  const uint32_t LAYERS = 9;
  const uint32_t lconv  = 6;  // last conv
  const uint32_t ldense = 8;  // last dense
  const uint32_t data_o_size = 16;

  // print some config numbers
  printf ("* WT_WORDS   = %u\n", WT_WORDS);
  printf ("* KH_WORDS   = %u\n", KH_WORDS);

  // Load input data
  printf ("## Loading input data ##\n");
  Word* inputs = (Word*)data_full_uint32t;
  uint32_t* labels = labels_full_uint32t;
  
  // allocate memories for data i/o for the accelerator
  Word          *data_i;
#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))
  Word volatile *data_o  = (Word volatile *)data_o_buf;
#else
  Word volatile *data_o  = (Word volatile *)malloc(data_o_size * sizeof(Word));
#endif
  
  if (!data_o) {
    fprintf (stderr, "**** ERROR: Alloc failed in %s\n", __FILE__);
    return (-2);
  }

  #if defined(_RISCV)
  // Force a page-fault for input data
  LOAD_STATIC_ARRAY(data_full_uint32t);

  // Same for output data
  LOAD_ARRAY(data_o, data_o_size, sizeof(Word));
  #endif

  // Load parameters
  printf ("## Loading parameters ##\n");
  Word* wt[LAYERS];
  Word* kh[LAYERS];
  for (uint32_t n = 0; n < LAYERS; ++n) {
    Word *temp_wt, *temp_kh;
    if (n == 0) {
      temp_wt = (Word*) wt_layer1_uint32t;
      temp_kh = (Word*) kh_layer1_uint32t;
    } else if (n == 1) {
      temp_wt = (Word*) wt_layer2_uint32t;
      temp_kh = (Word*) kh_layer2_uint32t;
    } else if (n == 2) {
      temp_wt = (Word*) wt_layer3_uint32t;
      temp_kh = (Word*) kh_layer3_uint32t;
    } else if (n == 3) {
      temp_wt = (Word*) wt_layer4_uint32t;
      temp_kh = (Word*) kh_layer4_uint32t;
    } else if (n == 4) {
      temp_wt = (Word*) wt_layer5_uint32t;
      temp_kh = (Word*) kh_layer5_uint32t;
    } else if (n == 5) {
      temp_wt = (Word*) wt_layer6_uint32t;
      temp_kh = (Word*) kh_layer6_uint32t;
    } else if (n == 6) {
      temp_wt = (Word*) wt_layer7_uint32t;
      temp_kh = (Word*) kh_layer7_uint32t;
    } else if (n == 7) {
      temp_wt = (Word*) wt_layer8_uint32t;
      temp_kh = (Word*) kh_layer8_uint32t;
    } else if (n == 8) {
      temp_wt = (Word*) wt_layer9_uint32t;
      temp_kh = (Word*) kh_layer9_uint32t;
    } else {
      assert(0);
    }
    
    wt[n] = temp_wt;
    kh[n] = temp_kh;
  }

  #if defined(_RISCV)
  // Force a page-fault for weights arrays
  LOAD_STATIC_ARRAY(wt_layer1_uint32t);
  LOAD_STATIC_ARRAY(wt_layer2_uint32t);
  LOAD_STATIC_ARRAY(wt_layer3_uint32t);
  LOAD_STATIC_ARRAY(wt_layer4_uint32t);
  LOAD_STATIC_ARRAY(wt_layer5_uint32t);
  LOAD_STATIC_ARRAY(wt_layer6_uint32t);
  LOAD_STATIC_ARRAY(wt_layer7_uint32t);
  LOAD_STATIC_ARRAY(wt_layer8_uint32t);
  LOAD_STATIC_ARRAY(wt_layer9_uint32t);

  // Same for KH arrays
  LOAD_STATIC_ARRAY(kh_layer1_uint32t);
  LOAD_STATIC_ARRAY(kh_layer2_uint32t);
  LOAD_STATIC_ARRAY(kh_layer3_uint32t);
  LOAD_STATIC_ARRAY(kh_layer4_uint32t);
  LOAD_STATIC_ARRAY(kh_layer5_uint32t);
  LOAD_STATIC_ARRAY(kh_layer6_uint32t);
  LOAD_STATIC_ARRAY(kh_layer7_uint32t);
  LOAD_STATIC_ARRAY(kh_layer8_uint32t);
  LOAD_STATIC_ARRAY(kh_layer9_uint32t);
  #endif

  uint32_t n_errors = 0;

  printf ("## Running BNN for %d images\n\n", n_imgs);

  //--------------------------------------------------------------
  // Run BNN
  //--------------------------------------------------------------
  for (uint32_t n = start_img; n < start_img + n_imgs; ++n) {

    // point to input image
    data_i = (Word *)&inputs[32 * 32 * n];

    printf("- Running bnn for image %d\n", n);

    // Stats
    test_stats_on();

    //------------------------------------------------------------
    // Execute conv layers
    //------------------------------------------------------------
    for (uint32_t l = 0; l < lconv; ++l) {
      // Parameters
      const uint32_t M           = M_tab   [l];
      const uint32_t N           = N_tab   [l];
      const uint32_t S           = S_tab   [l];
      const uint32_t layer_type  = T_tab   [l];
      const uint32_t max_pool    = pool_tab[l];
            uint32_t input_words = (l == 0) ? S * S : 0;

      run_layer(
          // data in   data out
          data_i     , data_o      ,
          // Weights   KH
          wt[l]      , kh[l]       ,
          // # Ins     # Outs
          M          , N           ,
          // Width     Layer Idx
          S          , l           ,
          // In wrds   Out wrds
          input_words, 0           ,
          // dmem_mode
          l % 2      ,
          // type      max pool
          layer_type , max_pool    ,
          // Sneak path activation
          isSneakPath 
      );
    }

    //------------------------------------------------------------
    // Execute dense layers
    //------------------------------------------------------------
    for (uint32_t l = lconv; l < ldense; ++l) {
      // Parameters
      const uint32_t M           = M_tab   [l];
      const uint32_t N           = N_tab   [l];
      const uint32_t S           = S_tab   [l];
      const uint32_t layer_type  = T_tab   [l];
      const uint32_t max_pool    = pool_tab[l];

      run_layer(
          // data in   data out
          data_i     , data_o      ,
          // Weights   KH
          wt[l]      , kh[l]       ,
          // # Ins     # Outs
          M          , N           ,
          // Width     Layer Idx
          S          , l           ,
          // In wrds   Out wrds
          0          , 0           ,
          // dmem_mode
          l % 2      ,
          // type      max pool
          layer_type , max_pool    ,
          // Sneak path activation
          isSneakPath 
      );
    }

    //------------------------------------------------------------
    // Execute last layer
    //------------------------------------------------------------
    // Parameters
    const uint32_t l           = ldense     ;
    const uint32_t M           = M_tab   [l];
    const uint32_t N           = N_tab   [l];
    const uint32_t S           = S_tab   [l];
    const uint32_t layer_type  = T_tab   [l];
    const uint32_t max_pool    = pool_tab[l];

    run_layer(
        // data in   data out
        data_i     , data_o      ,
        // Weights   KH
        wt[l]      , kh[l]       ,
        // # Ins     # Outs
        M          , N           ,
        // Width     Layer Idx
        S          , l           ,
        // In wrds   Out wrds
        0          , 1           ,
        // dmem_mode
        l % 2      ,
        // type      max pool
        layer_type , max_pool    ,
        // Sneak path activation
        isSneakPath 
    );

    // Stats
    test_stats_off();

    Word p = data_o[0];
    uint32_t prediction = (uint32_t)p;
    uint32_t label = labels[n];

    printf ("\tPred/Label:\t%2u/%2d\t[ %s ]\n\n", prediction, label,
        ((prediction==label)?"PASS":"FAIL"));

    n_errors += (prediction!=label);
  }

  printf ("\n");
  double err_rate = (double)n_errors * 100 / n_imgs;
#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))
  uint32_t int_part  = (uint32_t)err_rate;
  uint32_t frac_part = (uint32_t)((err_rate - int_part) * 1000);
  printf ("Errors: %u (%d.%03d%%)\n", n_errors, int_part, frac_part);
#else
  printf ("Errors: %u (%7.4f%%)\n", n_errors, err_rate);
#endif
  printf ("\n");

#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))
  data_o = NULL;
#else
  free((Word *)data_o);
#endif
  return 0;
}
