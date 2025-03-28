#include "bnn_common.h"

uint32_t simple_hash(uint32_t x) {
  uint32_t temp = (((x)*(x+3)*(x+11)) % 47);
  return (((temp ^ (temp >> 2)) ^ (temp >> 4)) ^ (temp >> 6)) & 1;
}

uint32_t popcount1(Word x) {
  Word mask = 0x1;
  uint32_t res = 0;
  for (uint32_t i = 0; i < WORD_SIZE; ++i) {
    res += (mask & x) ? 1 : 0;
    mask = mask << 1;
  }
  return res;
}

uint32_t popcount2(Word x) {
  x -= (x >> 1) & m1;
  x = (x & m2) + ((x >> 2) & m2);
  x = (x + (x >> 4)) & m4;
  x += x >> 8;
  x += x >> 16;
  x += x >> 32;
  x = x & 0x7f;
  return (uint32_t)x;
}

/*
#if defined(_RISCV) && (!defined(_ROCKET) || (defined(_ROCKET) && !defined(_PK)))
uint32_t atoi(char *num)
{
  uint32_t res = 0;

  while(*num && *num >= '0' && *num < '9')
    res = (res * 10) + ((*num) - '0');

  return res;
}
#endif
*/

//------------------------------------------------------------------------
// Print helper functions
//------------------------------------------------------------------------
void print_mat(int64_t in[], uint32_t S, uint32_t R, uint32_t C) {
  R = (R >= S) ? S : R;
  C = (C >= S) ? S : C;
  for (uint32_t r = 0; r < R; ++r) {
    for (uint32_t c = 0; c < C; ++c)
      printf ("%4d ", (int)in[r*S+c]);
    printf ("\n");
  }
}

void print_mat3d(int64_t in[], uint32_t M, uint32_t num, uint32_t S, uint32_t R, uint32_t C) {
  for (uint32_t m = M; m < M+num; ++m) {
    print_mat(in+m*S*S, S, R, C);
    printf ("--%u--\n", m+1);
  }
}

void print_bits(volatile Word *in, uint32_t bit_offset, uint32_t S, uint32_t R, uint32_t C) {
  R = (R >= S) ? S : R;
  C = (C >= S) ? S : C;
  for (uint32_t r = 0; r < R; ++r) {
    for (uint32_t c = 0; c < C; ++c)
      printf ("%2d ", get_bit(in, bit_offset+r*S+c));
    printf ("\n");
  }
}

void print_bits3d(volatile Word *in, uint32_t M, uint32_t num, uint32_t S, uint32_t R, uint32_t C) {
  for (uint32_t m = M; m < M+num; ++m) {
    print_bits(in, m*S*S, S, R, C);
    printf ("--%u--\n", m+1);
  }
}

void print_params3d(Word in[], uint32_t M, uint32_t num) {
  uint32_t addr = M / CONV_W_PER_WORD;
  uint32_t off = M % CONV_W_PER_WORD;
  for (uint32_t n = M; n < M+num; ++n) {
    print_bits(in, addr*WORD_SIZE+off*9, 3, 3, 3);
    printf ("--%u--\n", n+1);
    if (++off == CONV_W_PER_WORD) {
      off = 0;
      addr++;
    }
  }
}

//-------------------------------------------------------------------
// Useful helper functions
//-------------------------------------------------------------------
// Padded 2d convolution, this is the golden reference
void conv2d_padded(Word in[], Word w[], int64_t conv_out[], uint32_t M, uint32_t S) {
  for (uint32_t r = 0; r < S; ++r) {
  for (uint32_t c = 0; c < S; ++c) {
    conv_out[r*S + c] = 0;
  }}

  for (uint32_t m = 0; m < M; ++m) {
    for (uint32_t r = 0; r < S; ++r) {
    for (uint32_t c = 0; c < S; ++c) {
      int res = 0;

      Address kaddr = m/CONV_W_PER_WORD;
      IdxType koff = m%CONV_W_PER_WORD;
      Word wt_word = w[kaddr];

      for (uint32_t kr = 0; kr < K; ++kr) {
      for (uint32_t kc = 0; kc < K; ++kc) {
        TwoBit pix = 0;
        int _r = r+kr-K/2;
        int _c = c+kc-K/2;
        if (_r >= 0 && _c >= 0 && _r < (int)S && _c < (int)S)
          pix = get_bit(in, m*S*S+_r*S+_c) == 0 ? 1 : -1;

        Word wt_temp = wt_word >> (koff*K*K + (2-kr)*K + (2-kc));
        Bit k = wt_temp & 0x1;

        res += (k!=0) ? (TwoBit)(-pix) : pix;
      } }
      conv_out[r*S + c] += res;
    } }
  }
}

// number of Words allocated to store n weights
uint32_t WTS_TO_WORDS(const uint32_t n) {
  // divide n weights by W_PER_WORD
  const uint32_t words = (n + CONV_W_PER_WORD-1) / CONV_W_PER_WORD;
  // round up to nearest convolvers
  return ((words+CONVOLVERS-1) / CONVOLVERS) * CONVOLVERS;
}

//-------------------------------------------------------------------
// returns the hardcoded KH values for random testing
//-------------------------------------------------------------------
void get_reference_kh(KType *ki, HType *hi, unsigned idx) {
  *ki = 0.01;
  *hi = -0.025*idx;
}

//-------------------------------------------------------------------
// Compute and execute an xcel schedule
//-------------------------------------------------------------------
void run_layer(
           Word     *data_i      ,
  volatile Word     *data_o      ,
           Word     *wt_array    ,
           Word     *kh_array    ,
           uint32_t  n_inputs    ,
           uint32_t  n_outputs   ,
           uint32_t  width       ,
           uint32_t  layer_idx   ,
           uint32_t  input_words ,
           uint32_t  output_words,
           uint32_t  dmem_mode   ,
  const    uint32_t  layer_type  , // 0=conv1, 1=conv, 2=dense, 3=last
  const    uint32_t  max_pool    ,
           bool      isSneakPath
){
  assert (wt_array != NULL);
  assert (kh_array != NULL);
  const uint32_t width_mode = width >> 4;

  // for conv layers
  uint32_t width_o = 0;
  // imgs_per_batch is the number of output images to compute per batch
  uint32_t imgs_per_batch = 0;

  uint32_t n_batches;

  if (layer_type < LAYER_DENSE) {
    width_o = (max_pool==0) ? width : width / 2;
    imgs_per_batch = find_conv_batch_size(width, width_o, n_inputs, n_outputs);
  }
  else {
    width_o = 1;
    imgs_per_batch = find_dense_batch_size(n_inputs, n_outputs);
  }
  n_batches = n_outputs / imgs_per_batch;

  assert (imgs_per_batch != 0);
  assert (n_outputs % imgs_per_batch == 0); // TODO: this should not be necessary

  uint32_t o = 0;
  for (uint32_t batch = 0; batch < n_batches; batch++) {
    // layer_mode[0] is 1 iff first invocation of a layer
    // layer_mode[2:1] is the layer_type
    uint32_t layer_mode = ((layer_type & 0x3) << 1) | ((o == 0) ? 1 : 0);
    uint32_t wt_idx;
    uint32_t wt_offset;

    Word *wt = NULL;
    Word *kh = NULL;

    uint32_t quant     = 0;
    uint32_t wt_bits   = 0;

    if (layer_type == LAYER_CONV1) {
      wt_bits   = n_inputs * imgs_per_batch * WT_SIZE;
      quant     = CONV_W_PER_WORD;
    }
    else if (layer_type == LAYER_CONV) {
      wt_bits   = n_inputs * imgs_per_batch * WT_SIZE;
      quant     = CONV_W_PER_WORD;
    }
    else {
      wt_bits   = n_inputs * imgs_per_batch;
      quant     = WORD_SIZE;
    }

    wt_idx    =  (o * n_inputs) / quant           ;
    wt_offset = ((o * n_inputs) % quant) * WT_SIZE;

    // Weights
    if (isSneakPath)
      wt = (Word*)__SNEAK_PATH_MAGICAL_ADDRESS;
    else
      wt = &wt_array[wt_idx];

    // KH
    kh = &kh_array[o / KH_PER_WORD];

    uint32_t i_words = (batch == 0            ) ? input_words  : 0;
    uint32_t o_words = (batch == n_batches - 1) ? output_words : 0;

    bnn_xcel(
        wt           , kh              ,
        data_i       , data_o          ,
        n_inputs     , imgs_per_batch  ,
        i_words      , o_words         ,
        wt_bits      , wt_offset       ,
        layer_mode   , dmem_mode       ,
        width_mode   , max_pool + 1
    );

    o += imgs_per_batch;
  }
}

// -----------------------------------------------------------------------
// Determine how many images can be computed in a single xcel call
// -----------------------------------------------------------------------
unsigned find_divisible_batch_size(unsigned n_outputs, unsigned imgs_per_batch) {
  // input imgs_per_batch is an upper limit
  // Find n_batches, and linearly search for an integer value of
  // n_batches which divides n_outputs
  // We use n_batches because it is typically smaller than imgs_per_batch
  unsigned n_batches = n_outputs / imgs_per_batch;
  if (n_outputs % imgs_per_batch != 0) {
    // The line below rounds n_batches "up", so imgs_per_batch isn't
    // larger than the established bounds
    n_batches = n_batches + 1;

    while (n_outputs % n_batches != 0) {
      n_batches = n_batches + 1;
    }
  }

  imgs_per_batch = n_outputs / n_batches;
  assert(imgs_per_batch != 0);
  return imgs_per_batch;
}

unsigned find_conv_batch_size(unsigned width, unsigned width_o,
                         unsigned n_inputs, unsigned n_outputs) {
  const unsigned input_bsize = DMEM_WORDS*WORD_SIZE / (width*width);
  const unsigned wt_bsize = WT_WORDS*CONV_W_PER_WORD /  n_inputs;
  const unsigned kh_bsize = KH_WORDS*KH_PER_WORD;
  unsigned imgs_per_batch = DMEM_WORDS*WORD_SIZE / (width_o*width_o);

  // adjust output batch size to fit into memories cleanly
  if (imgs_per_batch > n_outputs) imgs_per_batch = n_outputs;
  if (imgs_per_batch > wt_bsize) imgs_per_batch = wt_bsize;
  if (imgs_per_batch > kh_bsize) imgs_per_batch = kh_bsize;

  imgs_per_batch = find_divisible_batch_size(n_outputs, imgs_per_batch);

  DB_PRINT(2, ">> (Wt, KH) batch: (%u %u)\n", wt_bsize, kh_bsize);
  DB_PRINT(2, ">> Final batch: %u\n", imgs_per_batch);

  // We are going to assume the following:
  //  1. We have space for all the input feature maps in dmem
  //  2. We have space for at least n_inputs parameters in wt_i
  assert(n_inputs <= input_bsize);
  assert(wt_bsize != 0);

  return imgs_per_batch;
}

unsigned find_dense_batch_size(unsigned n_inputs, unsigned n_outputs) {
  assert(WT_WORDS*WORD_SIZE >= n_inputs);
  const unsigned wt_bsize = WT_WORDS*WORD_SIZE / n_inputs;
  const unsigned kh_bsize = KH_WORDS*KH_PER_WORD;
  unsigned bits_per_batch = DMEM_WORDS*WORD_SIZE;

  // adjust output batch size to fit into memories cleanly
  if (bits_per_batch > n_outputs) bits_per_batch = n_outputs;
  if (bits_per_batch > wt_bsize) bits_per_batch = wt_bsize;
  if (bits_per_batch > kh_bsize) bits_per_batch = kh_bsize;

  bits_per_batch = find_divisible_batch_size(n_outputs, bits_per_batch);

  DB_PRINT(2, ">> (Wt, KH) bits batch: (%u %u)\n", wt_bsize, kh_bsize);
  DB_PRINT(2, ">> Final bits batch: %u\n", bits_per_batch);

  return bits_per_batch;
}

// -----------------------------------------------------------------------
// Function for calling the bnn xcel
// -----------------------------------------------------------------------
__attribute__ ((noinline))
void bnn_xcel( Word *wt, Word *kh,
               Word *data_i, volatile Word *data_o,
               uint32_t n_inputs,     uint32_t n_outputs,
               uint32_t input_words,  uint32_t output_words,
               uint32_t wt_bits,      uint32_t wt_offset,
               uint32_t layer_mode,   uint32_t dmem_mode,
               uint32_t width_mode,   uint32_t norm_mode)
{
  //printf ("  In bnn_xcel:\n");
  //printf ("    wt = %p\n", wt);
  //printf ("    kh = %p\n", kh);
  //printf ("    data_i = %p\n", data_i);
  //printf ("    data_o = %p\n", data_o);
  //printf ("    n_inputs=%4d, n_outputs=%4d\n", n_inputs, n_outputs);
  //printf ("    i_words=%4d, o_words=%4d\n", input_words, output_words);
  //printf ("    wt_bits=%6d, wt_offset=%6d\n", wt_bits, wt_offset);
  //printf ("    layer_mode=%2d, dmem_mode=%2d\n", layer_mode, dmem_mode);
  //printf ("    width_mode=%2d, norm_mode=%2d\n", width_mode, norm_mode);

  int go = 1;

#if defined(_RISCV)
  asm volatile (
    // rd, rs1, rs2, funct

    "fence \n"

    "custom0 %[layer_mode_reg]  , %[layer_mode]  , 0          , 1\n"
    "custom0 %[width_mode_reg]  , %[width_mode]  , 0          , 1\n"
    "custom0 %[n_inputs_reg]    , %[n_inputs]    , 0          , 1\n"
    "custom0 %[dmem_mode_reg]   , %[dmem_mode]   , 0          , 1\n"
    "custom0 %[input_words_reg] , %[input_words] , 0          , 1\n"
    "custom0 %[n_outputs_reg]   , %[n_outputs]   , 0          , 1\n"
    "custom0 %[norm_mode_reg]   , %[norm_mode]   , 0          , 1\n"
    "custom0 %[output_words_reg], %[output_words], 0          , 1\n"
    "custom0 %[wt_bits_reg]     , %[wt_bits]     , 0          , 1\n"
    "custom0 %[wt_offset_reg]   , %[wt_offset]   , 0          , 1\n"
    "custom0 %[weights_addr_reg], %[wt]          , 0          , 1\n"
    "custom0 %[kh_addr_reg]     , %[kh]          , 0          , 1\n"
    "custom0 %[datain_addr_reg] , %[data_i]      , 0          , 1\n"
    "custom0 %[dataout_addr_reg], %[data_o]      , 0          , 1\n"
  //"custom0 %[funct_reg]       , %[go]          , 0          , 1\n"
    "custom0 0                  , %[go]          , 0          , 1\n"
    "custom0 %[go]              , 0              , 0          , 0\n"
    "and     %[go]              , %[go]          , %[go]         \n"

    "fence \n"

    // Outputs from the inline assembly block

    : [go  ] "+r"(go  )

    // Inputs to the inline assembly block

    : [layer_mode]      "r"(layer_mode)         ,
      [width_mode]      "r"(width_mode)         ,
      [n_inputs]        "r"(n_inputs)           ,
      [dmem_mode]       "r"(dmem_mode)          ,
      [input_words]     "r"(input_words)        ,
      [n_outputs]       "r"(n_outputs)          ,
      [norm_mode]       "r"(norm_mode)          ,
      [output_words]    "r"(output_words)       ,
      [wt_bits]         "r"(wt_bits)            ,
      [wt_offset]       "r"(wt_offset)          ,
      [wt]              "r"(wt)                 ,
      [kh]              "r"(kh)                 ,
      [data_i]          "r"(data_i)             ,
      [data_o]          "r"(data_o)             ,

      [layer_mode_reg]  "n"(LAYER_MODE_REG_ID)  ,
      [width_mode_reg]  "n"(WIDTH_MODE_REG_ID)  ,
      [n_inputs_reg]    "n"(N_INPUTS_REG_ID)    ,
      [dmem_mode_reg]   "n"(DMEM_MODE_REG_ID)   ,
      [input_words_reg] "n"(INPUT_WORDS_REG_ID) ,
      [n_outputs_reg]   "n"(N_OUTPUTS_REG_ID)   ,
      [norm_mode_reg]   "n"(NORM_MODE_REG_ID)   ,
      [output_words_reg]"n"(OUTPUT_WORDS_REG_ID),
      [wt_bits_reg]     "n"(WT_WORDS_REG_ID)    ,
      [wt_offset_reg]   "n"(WT_OFFSET_REG_ID)   ,
      [weights_addr_reg]"n"(WEIGHTS_ADDR_REG_ID),
      [kh_addr_reg]     "n"(KH_ADDR_REG_ID)     ,
      [datain_addr_reg] "n"(DATAIN_ADDR_REG_ID) ,
      [dataout_addr_reg]"n"(DATAOUT_ADDR_REG_ID)//,
    //  [funct_reg]       "n"(FUNCT_REG_ID)

    // Tell the compiler this accelerator read/writes memory

    : "memory"

  );

#else

  asm volatile ( "" ::: "memory");

#endif
}
