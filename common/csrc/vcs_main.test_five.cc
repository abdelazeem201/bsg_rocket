// See LICENSE for license details.

#include "test_five.h"
#include "htif_emulator.h"
#include "mm.h"
#include "mm_dramsim2.h"
#include <DirectC.h>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <iostream>
#include <sstream>
#include <iterator>

extern "C" {

#define N_CORES 5

extern int vcs_main(int argc, char** argv);

static htif_emulator_t* htif[N_CORES];
static unsigned htif_bytes = HTIF_WIDTH / 8;
static mm_t* mm[N_CORES];
static const char* loadmem[N_CORES];
static bool dramsim = false;

void htif_fini(vc_handle failure)
{
  for (int i=0; i<N_CORES; i++) {
    delete htif[i];
    htif[i] = NULL;
  }
  exit(vc_getScalar(failure));
}

int main(int argc, char** argv)
{
  unsigned long memsz_mb = MEM_SIZE / (1024*1024);
  int mcnt = 0;

  for (int i = 1; i < argc; i++)
  {
    if (!strcmp(argv[i], "+dramsim"))
      dramsim = true;
    else if (!strncmp(argv[i], "+mem_0=", 7)) {
      mcnt = 0;
      loadmem[mcnt] = argv[i]+7;
      std::cout << "ROCKET[" << mcnt << "] loading memory image: " << loadmem[mcnt] << std::endl;
    }
    else if (!strncmp(argv[i], "+mem_1=", 7)) {
      mcnt = 1;
      loadmem[mcnt] = argv[i]+7;
      std::cout << "ROCKET[" << mcnt << "] loading memory image: " << loadmem[mcnt] << std::endl;
    }
    else if (!strncmp(argv[i], "+mem_2=", 7)) {
      mcnt = 2;
      loadmem[mcnt] = argv[i]+7;
      std::cout << "ROCKET[" << mcnt << "] loading memory image: " << loadmem[mcnt] << std::endl;
    }
    else if (!strncmp(argv[i], "+mem_3=", 7)) {
      mcnt = 3;
      loadmem[mcnt] = argv[i]+7;
      std::cout << "ROCKET[" << mcnt << "] loading memory image: " << loadmem[mcnt] << std::endl;
    }
    else if (!strncmp(argv[i], "+mem_4=", 7)) {
      mcnt = 4;
      loadmem[mcnt] = argv[i]+7;
      std::cout << "ROCKET[" << mcnt << "] loading memory image: " << loadmem[mcnt] << std::endl;
    }
  }

  for (int i=0; i<N_CORES; i++) {
    htif[i] = (htif_emulator_t*) (new htif_emulator_t(memsz_mb, std::vector<std::string>(argv + 1, argv + argc)));
  }

  for (int i=0; i<N_CORES; i++) {
    mm[i] = dramsim ? (mm_t*)(new mm_dramsim2_t) : (mm_t*)(new mm_magic_t);
    mm[i]->init(MEM_SIZE, MEM_DATA_BITS / 8, CACHE_BLOCK_BYTES);
  }

  void *mems[N_CORES];
  for (int i = 0; i < N_CORES; i++) {
    mems[i] = mm[i]->get_data();
    load_mem(mems, loadmem[i], CACHE_BLOCK_BYTES, i);
  }

  vcs_main(argc, argv);
  abort(); // should never get here
}

HTIF_TICK(htif_0_tick, 0)
HTIF_TICK(htif_1_tick, 1)
HTIF_TICK(htif_2_tick, 2)
HTIF_TICK(htif_3_tick, 3)
HTIF_TICK(htif_4_tick, 4)

MEMORY_TICK(memory_0_tick, 0)
MEMORY_TICK(memory_1_tick, 1)
MEMORY_TICK(memory_2_tick, 2)
MEMORY_TICK(memory_3_tick, 3)
MEMORY_TICK(memory_4_tick, 4)

}
