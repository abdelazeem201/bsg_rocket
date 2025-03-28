//========================================================================
// bnn-xcel-loopback
//========================================================================
// Loopback test for BNN. This writes to some registers in BNN and reads
// them back to confirm that the accelerator exists.

#include "bnn_common.h"

// Input data
uint64_t messages [][4] = {

  // Zero all registers
  {LAYER_MODE_REG_ID  , 0x0       , 1, 0x0       },
  {WIDTH_MODE_REG_ID  , 0x0       , 1, 0x0       },
  {N_INPUTS_REG_ID    , 0x0       , 1, 0x0       },
  {DMEM_MODE_REG_ID   , 0x0       , 1, 0x0       },
  {INPUT_WORDS_REG_ID , 0x0       , 1, 0x0       },
  {N_OUTPUTS_REG_ID   , 0x0       , 1, 0x0       },
  {NORM_MODE_REG_ID   , 0x0       , 1, 0x0       },
  {OUTPUT_WORDS_REG_ID, 0x0       , 1, 0x0       },
  {WT_WORDS_REG_ID    , 0x0       , 1, 0x0       },
  {WT_OFFSET_REG_ID   , 0x0       , 1, 0x0       },
  {WEIGHTS_ADDR_REG_ID, 0x0       , 1, 0x0       },
  {KH_ADDR_REG_ID     , 0x0       , 1, 0x0       },
  {DATAIN_ADDR_REG_ID , 0x0       , 1, 0x0       },
  {DATAOUT_ADDR_REG_ID, 0x0       , 1, 0x0       },

  // Read zero'd registers
  {LAYER_MODE_REG_ID  , 0x0       , 0, 0x0       },
  {WIDTH_MODE_REG_ID  , 0x0       , 0, 0x0       },
  {N_INPUTS_REG_ID    , 0x0       , 0, 0x0       },
  {DMEM_MODE_REG_ID   , 0x0       , 0, 0x0       },
  {INPUT_WORDS_REG_ID , 0x0       , 0, 0x0       },
  {N_OUTPUTS_REG_ID   , 0x0       , 0, 0x0       },
  {NORM_MODE_REG_ID   , 0x0       , 0, 0x0       },
  {OUTPUT_WORDS_REG_ID, 0x0       , 0, 0x0       },
  {WT_WORDS_REG_ID    , 0x0       , 0, 0x0       },
  {WT_OFFSET_REG_ID   , 0x0       , 0, 0x0       },
  {WEIGHTS_ADDR_REG_ID, 0x0       , 0, 0x0       },
  {KH_ADDR_REG_ID     , 0x0       , 0, 0x0       },
  {DATAIN_ADDR_REG_ID , 0x0       , 0, 0x0       },
  {DATAOUT_ADDR_REG_ID, 0x0       , 0, 0x0       },

  // Write random data
  {LAYER_MODE_REG_ID  , 0x6       , 1, 0x0       },
  {WIDTH_MODE_REG_ID  , 0x2       , 1, 0x0       },
  {N_INPUTS_REG_ID    , 0xcf0c17fa, 1, 0x0       },
  {DMEM_MODE_REG_ID   , 0x1       , 1, 0x0       },
  {INPUT_WORDS_REG_ID , 0x246220aa, 1, 0x0       },
  {N_OUTPUTS_REG_ID   , 0x278339bd, 1, 0x0       },
  {NORM_MODE_REG_ID   , 0x3       , 1, 0x0       },
  {OUTPUT_WORDS_REG_ID, 0x32c59710, 1, 0x0       },
  {WT_WORDS_REG_ID    , 0x48226c4b, 1, 0x0       },
  {WT_OFFSET_REG_ID   , 0x2       , 1, 0x0       },
  {WEIGHTS_ADDR_REG_ID, 0xc3348043, 1, 0x0       },
  {KH_ADDR_REG_ID     , 0x75b5ee27, 1, 0x0       },
  {DATAIN_ADDR_REG_ID , 0x2b206173, 1, 0x0       },
  {DATAOUT_ADDR_REG_ID, 0xe1374457, 1, 0x0       },

  // Read random data
  {LAYER_MODE_REG_ID  , 0x0       , 0, 0x6       },
  {WIDTH_MODE_REG_ID  , 0x0       , 0, 0x2       },
  {N_INPUTS_REG_ID    , 0x0       , 0, 0xcf0c17fa},
  {DMEM_MODE_REG_ID   , 0x0       , 0, 0x1       },
  {INPUT_WORDS_REG_ID , 0x0       , 0, 0x246220aa},
  {N_OUTPUTS_REG_ID   , 0x0       , 0, 0x278339bd},
  {NORM_MODE_REG_ID   , 0x0       , 0, 0x3       },
  {OUTPUT_WORDS_REG_ID, 0x0       , 0, 0x32c59710},
  {WT_WORDS_REG_ID    , 0x0       , 0, 0x48226c4b},
  {WT_OFFSET_REG_ID   , 0x0       , 0, 0x2       },
  {WEIGHTS_ADDR_REG_ID, 0x0       , 0, 0xc3348043},
  {KH_ADDR_REG_ID     , 0x0       , 0, 0x75b5ee27},
  {DATAIN_ADDR_REG_ID , 0x0       , 0, 0x2b206173},
  {DATAOUT_ADDR_REG_ID, 0x0       , 0, 0xe1374457},

};

#define NUMBER_OF_INPUTS (sizeof(messages) / sizeof(uint64_t) / 4)

// Helper method to write and read from the accelerator
uint64_t xcelreq(uint32_t dest, uint64_t val, bool wr)
{
  uint64_t reg = 0;

  if(wr)
  {
    switch (dest)
    {
      case 0:
        asm volatile (
          "custom0 0, %[value], 0, 1\n"

          :
          : [value] "r"(val)
          : "memory"
        );
        break;

      case 1:
        asm volatile (
          "custom0 1, %[value], 0, 1\n"

          :
          : [value] "r"(val)
          : "memory"
        );
        break;

      case 2:
        asm volatile (
          "custom0 2, %[value], 0, 1\n"

          :
          : [value] "r"(val)
          : "memory"
        );
        break;
 
      case 3:
        asm volatile (
          "custom0 3, %[value], 0, 1\n"

          :
          : [value] "r"(val)
          : "memory"
        );
        break;
 
      case 4:
        asm volatile (
          "custom0 4, %[value], 0, 1\n"

          :
          : [value] "r"(val)
          : "memory"
        );
        break;
 
      case 5:
        asm volatile (
          "custom0 5, %[value], 0, 1\n"

          :
          : [value] "r"(val)
          : "memory"
        );
        break;
 
      case 6:
        asm volatile (
          "custom0 6, %[value], 0, 1\n"

          :
          : [value] "r"(val)
          : "memory"
        );
        break;
 
      case 7:
        asm volatile (
          "custom0 7, %[value], 0, 1\n"

          :
          : [value] "r"(val)
          : "memory"
        );
        break;
 
      case 8:
        asm volatile (
          "custom0 8, %[value], 0, 1\n"

          :
          : [value] "r"(val)
          : "memory"
        );
        break;
 
      case 9:
        asm volatile (
          "custom0 9, %[value], 0, 1\n"

          :
          : [value] "r"(val)
          : "memory"
        );
        break;
 
      case 10:
        asm volatile (
          "custom0 10, %[value], 0, 1\n"

          :
          : [value] "r"(val)
          : "memory"
        );
        break;
 
      case 11:
        asm volatile (
          "custom0 11, %[value], 0, 1\n"

          :
          : [value] "r"(val)
          : "memory"
        );
        break;
 
      case 12:
        asm volatile (
          "custom0 12, %[value], 0, 1\n"

          :
          : [value] "r"(val)
          : "memory"
        );
        break;
 
      case 13:
        asm volatile (
          "custom0 13, %[value], 0, 1\n"

          :
          : [value] "r"(val)
          : "memory"
        );
        break;
    }
  }
  else
  {
    switch (dest)
    {
      case 0:
        asm volatile (
          "custom0 %[reg] , 0, 0, 0\n"

          : [reg]  "=r"(reg)
          :
          : "memory"
        );

        break;

      case 1:
        asm volatile (
          "custom0 %[reg] , 0, 1, 0\n"

          : [reg]  "=r"(reg)
          :
          : "memory"
        );

        break;

      case 2:
        asm volatile (
          "custom0 %[reg] , 0, 2, 0\n"

          : [reg]  "=r"(reg)
          :
          : "memory"
        );

        break;

      case 3:
        asm volatile (
          "custom0 %[reg] , 0, 3, 0\n"

          : [reg]  "=r"(reg)
          :
          : "memory"
        );

        break;

      case 4:
        asm volatile (
          "custom0 %[reg] , 0, 4, 0\n"

          : [reg]  "=r"(reg)
          :
          : "memory"
        );

        break;

      case 5:
        asm volatile (
          "custom0 %[reg] , 0, 5, 0\n"

          : [reg]  "=r"(reg)
          :
          : "memory"
        );

        break;

      case 6:
        asm volatile (
          "custom0 %[reg] , 0, 6, 0\n"

          : [reg]  "=r"(reg)
          :
          : "memory"
        );

        break;

      case 7:
        asm volatile (
          "custom0 %[reg] , 0, 7, 0\n"

          : [reg]  "=r"(reg)
          :
          : "memory"
        );

        break;

      case 8:
        asm volatile (
          "custom0 %[reg] , 0, 8, 0\n"

          : [reg]  "=r"(reg)
          :
          : "memory"
        );

        break;

      case 9:
        asm volatile (
          "custom0 %[reg] , 0, 9, 0\n"

          : [reg]  "=r"(reg)
          :
          : "memory"
        );

        break;

      case 10:
        asm volatile (
          "custom0 %[reg] , 0, 10, 0\n"

          : [reg]  "=r"(reg)
          :
          : "memory"
        );

        break;

      case 11:
        asm volatile (
          "custom0 %[reg] , 0, 11, 0\n"

          : [reg]  "=r"(reg)
          :
          : "memory"
        );

        break;

      case 12:
        asm volatile (
          "custom0 %[reg] , 0, 12, 0\n"

          : [reg]  "=r"(reg)
          :
          : "memory"
        );

        break;

      case 13:
        asm volatile (
          "custom0 %[reg] , 0, 13, 0\n"

          : [reg]  "=r"(reg)
          :
          : "memory"
        );

        break;
    }
  }

  return reg;
}

int main(int argc, char** argv)
{
  // Iterate through an array of input messages and compare to expected output
  printf("Running loopback for %u message(s).", (unsigned int)NUMBER_OF_INPUTS);

  //for(uint32_t i = 0; i < NUMBER_OF_INPUTS; i++)
  for(uint32_t i = 0; i < 52; i++)
  {
    // Send message
    uint64_t ret = xcelreq(messages[i][0], messages[i][1], messages[i][2] != 0);

    if(ret != messages[i][3])
    {
      printf("\n\t[ TEST FAILED ]");
      printf("\n\n\tERROR: Failed at message %d.", i);
      printf("\n\tReturned value of 0x%" PRIx64 " does not match expected value of 0x%" PRIx64 ".\n\n", ret, messages[i][3]);
      return (i + 1);
    }
  }

  printf("\n\t[ TEST PASSED ]\n\n");
  return 0;
}
