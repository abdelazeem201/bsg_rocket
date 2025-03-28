#ifndef UBMARK_BNN_COMMON
#define UBMARK_BNN_COMMON


#include "common.h"
#include <inttypes.h>
#include "xcel_protocol.h"


//------------------------------------------------------------------------
// Debugging
//------------------------------------------------------------------------
#ifndef DEBUG_LEVEL
#define DEBUG_LEVEL 1
#endif

#ifdef DEBUG_LEVEL

  #define DB(lvl, x) if (lvl <= DEBUG_LEVEL) {x;}
  #define DB_PRINT(lvl, ...) \
    if (lvl <= DEBUG_LEVEL) \
      printf (__VA_ARGS__)

#else
  
  #define DB(lvl, x)   
  #define DB_PRINT(lvl, ...)

#endif

//------------------------------------------------------------------------
// BNN architectural parameters
//------------------------------------------------------------------------
#define CONVOLVERS      (2)

#define WORD_SIZE       (64)
#define WT_SIZE         (9)
#define CONV_W_PER_WORD (7)
#define KH_PER_WORD     (2)
#define K               (3)
#define WT_L            (16*4*512 + CONV_W_PER_WORD-1) // parameter to control wt mem size
#define C_WT_WORDS      ((WT_L/CONV_W_PER_WORD + CONVOLVERS-1) / CONVOLVERS) // wt words per convolver
#define WT_WORDS        (C_WT_WORDS*CONVOLVERS)
#define KH_WORDS        (WT_L/128*32 / WORD_SIZE)

#define DMEM_WORDS      (128*32*32 / WORD_SIZE)
#define C_DMEM_WORDS    (DMEM_WORDS / CONVOLVERS)

#define PIX_PER_PHASE   (2*32*32)
#define WORDS_PER_PHASE (PIX_PER_PHASE / WORD_SIZE)

#define MAX_WIDTH       (32)

#define CONV_ROWS       (3)
#define CONV_COLS       (10)
#define CONV_BANKS      (4)

#define POOL_WIDTH      (2)

#define M_INT           (32767)

enum LayerTypeEnum {LAYER_CONV1, LAYER_CONV, LAYER_DENSE, LAYER_LAST};

#define __SNEAK_PATH_MAGICAL_ADDRESS 0x80000000

//------------------------------------------------------------------------
// BNN typedefs
//------------------------------------------------------------------------
typedef signed char Bit;
typedef signed char TwoBit;
typedef float KType;
typedef float HType;
typedef float NormOutput;
typedef uint64_t Word;
typedef int WtType;
typedef uint32_t Address;
typedef int ConvSum;
typedef int ConvOut;
typedef uint32_t IdxType;
typedef int32_t NormComp;

const static Word m1  = 0x5555555555555555LL;
const static Word m2  = 0x3333333333333333LL;
const static Word m4  = 0x0f0f0f0f0f0f0f0fLL;
const static Word h01 = 0x0101010101010101LL;

//------------------------------------------------------------------------
// Helper functions
//------------------------------------------------------------------------
// Simple hash used to generate random data
uint32_t simple_hash(uint32_t x);
// Simple log function for powers for 2 only
//uint32_t log2(uint32_t x);
// count number of 1's in a Word
uint32_t popcount1(Word x);
uint32_t popcount2(Word x);
// set a bit in a Word array
inline void set_bit(Word array[], uint32_t bit_idx, Bit val) {
  Address idx = bit_idx / WORD_SIZE;
  Address offset = bit_idx % WORD_SIZE;
  Word mask  = (Word)0x1 << offset;
  Word value = ((Word)val & 0x1) << offset;
  array[idx] = (array[idx] & ~mask) | value;
}
// get a bit in a Word array
inline Bit get_bit(volatile Word array[], uint32_t bit_idx) {
  Address idx = bit_idx / WORD_SIZE;
  Address offset = bit_idx % WORD_SIZE;
  Bit result = (array[idx] >> offset) & 0x1llu;
  return result;
}

//------------------------------------------------------------------------
// Print helper functions. S = image dim and R/C = rows/cols to print
//------------------------------------------------------------------------
void print_mat(int64_t in[], uint32_t S, uint32_t R, uint32_t C);
void print_mat3d(int64_t in[], uint32_t M, uint32_t num, uint32_t S, uint32_t R, uint32_t C);
void print_bits(volatile Word* in, uint32_t bit_offset, uint32_t S, uint32_t R, uint32_t C);
void print_bits3d(volatile Word* in, uint32_t M, uint32_t num, uint32_t S, uint32_t R, uint32_t C);
void print_params3d(Word in[], uint32_t M, uint32_t num);

//------------------------------------------------------------------------
// Useful helper functions
//------------------------------------------------------------------------
// Padded 2d convolution, this is the golden reference
void conv2d_padded(Word in[], Word w[], int64_t conv_out[], uint32_t M, uint32_t S);

// number of Words allocated to store n weights
uint32_t WTS_TO_WORDS(const uint32_t n);

// returns the hardcoded KH values for random testing
void get_reference_kh(KType *ki, HType *hi, unsigned idx);

//------------------------------------------------------------------------
// Proxy function to run a layer
//------------------------------------------------------------------------
void run_layer(
           Word     *data_i       ,
  volatile Word     *data_o       ,
           Word     *wt_array     ,
           Word     *kh_array     ,
           uint32_t  n_inputs     ,
           uint32_t  n_outputs    ,
           uint32_t  width        ,
           uint32_t  layer_idx    ,
           uint32_t  input_words  ,
           uint32_t  output_words ,
           uint32_t  dmem_mode    ,
  const    uint32_t  layer_type   , // 0=conv1, 1=conv, 2=dense, 3=last
  const    uint32_t  max_pool     ,
           bool      isSneakPath
);

//------------------------------------------------------------------------
// Find how many images can be computed in a single xcel call
//------------------------------------------------------------------------
unsigned find_conv_batch_size(unsigned width, unsigned width_o,
                              unsigned n_inputs, unsigned n_outputs);
unsigned find_dense_batch_size(unsigned n_inputs, unsigned n_outputs);

//------------------------------------------------------------------------
// BNN software model
//------------------------------------------------------------------------

void bnn(
    Word*            wt_i,
    Word*            kh_i,
    Word*            dmem_i,
    Word*            dmem_o,

    const Address    n_inputs          ,
    const Address    n_outputs         ,
    const Address    input_words       ,
    const Address    output_words      ,

    const uint32_t   layer_mode        , // [0]='new layer', [2:1]='conv1,conv,dense,last'
    const uint32_t   dmem_mode         , // 0 means dmem[0] is input
    const uint32_t   width_mode        , // 0=8'b, 1=16'b, 2=32'b
    const uint32_t   norm_mode           // 0='do nothing', 1='do norm', 2='do pool'
);

// -----------------------------------------------------------------------
// Function for calling the bnn xcel
// -----------------------------------------------------------------------
__attribute__ ((noinline))
void bnn_xcel( Word *wt, Word *kh, Word *data_i, volatile Word *data_o,
               uint32_t n_inputs,     uint32_t n_outputs,
               uint32_t input_words,  uint32_t output_words,
               uint32_t wt_bits,      uint32_t wt_offset,
               uint32_t layer_mode,   uint32_t dmem_mode,
               uint32_t width_mode,   uint32_t norm_mode);

#endif
