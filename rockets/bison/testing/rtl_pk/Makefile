include ../../../../../cad/common/mk/cadenv.mk

MODEL := Top
CONFIG := Bsg1AccelVLSIConfig
TB := rocketTestHarness
ROCKET_NAME ?= bison_accum
BENCHMARK ?= median
TIMEOUT_CYCLES ?= 100000000
RISCV ?= $(abspath ../../../../../bsg_riscv/riscv-install)

export PATH:=$(RISCV)/bin:/opt/rh/devtoolset-2/root/usr/bin:$(PATH)
export BSG_OUT_DIR = $(abspath ./out)
export BSG_COMMON_DIR = $(abspath ../../../../common)
export BSG_RISCV_DIR = $(abspath ../../../../../bsg_riscv)
export BSG_PACKAGING_DIR = $(abspath ../../../../../bsg_packaging)
export BSG_IP_CORES_DIR = $(abspath ../../../../../bsg_ip_cores)
export BSG_DESIGNS_DIR = $(abspath ../../../../../bsg_designs)
export BSG_ROCKET_DIR = $(abspath ../../../../../bsg_rocket)
export BSG_DESIGNS_TARGET_DIR = $(BSG_DESIGNS_DIR)/toplevels/bsg_two_$(ROCKET_NAME)

export BSG_PACKAGING_FOUNDRY=tsmc_180_250
export BSG_PACKAGE=ucsd_bga_332
export BSG_PINOUT=bsg_two
export BSG_PINOUT_FOUNDRY=tsmc_180
export BSG_PADMAPPING=experimental

CC = /opt/rh/devtoolset-2/root/usr/bin/gcc
CXX = /opt/rh/devtoolset-2/root/usr/bin/g++
CXXFLAGS := -O1

generated_dir = $(abspath ../../generated-src)
benchmark_dir = $(BSG_COMMON_DIR)/benchmark

# hawajkm: If the chosen benchmark does not exist in UCB's repo, choose BSG's benchmark directory
UCB_BENCHMARK_DIR = $(abspath ../../../../../bsg_riscv/rocket-chip/riscv-tools/riscv-tests/benchmarks)
BSG_BENCHMARK_DIR = $(benchmark_dir)
ifeq (exists, $(shell [ -d  $(UCB_BENCHMARK_DIR)/$(BENCHMARK) ] && echo exists))

  riscv_bmark_dir = $(UCB_BENCHMARK_DIR)

else

  ifeq (exists, $(shell [ -d  $(abspath $(BSG_BENCHMARK_DIR)/$(BENCHMARK)) ] && echo exists))

    riscv_bmark_dir = $(BSG_BENCHMARK_DIR)

  else

    $(error "ERROR: cannot find benchmark $(BENCHMARK)")

  endif

endif

default:
	@echo -e "\n----------------- bsg dependencies ---------------------"
	@echo -e "\n1. git clone bsg_ip_cores, bsg_designs, bsg_packaging, bsg_rocket, bsg_riscv, cad"
	@echo -e "2. Go to bsg_riscv"
	@echo -e "3. make checkout-all"
	@echo -e "4. make build-riscv-tools-newlib"
	@echo -e "5. Go to bsg_rocket/rockets/bison/testing/rtl_pk"
	@echo -e "6. make build"
	@echo -e "7. make run BENCHMARK=X"
	@echo -e "\n----------------- PK simulation options ---------------------"
	@echo -e "\na) make build - compile rtl and generate vcs-binary"
	@echo -e "b) make run BENCHMARK=X - run X benchmark, where X can be:"
	@echo -e "    1. dhrystone"
	@echo -e "    2. median"
	@echo -e "    3. multiply"
	@echo -e "    4. qsort"
	@echo -e "    5. spmv"
	@echo -e "    6. towers"
	@echo -e "    7. vvadd"
	@echo -e "    8. memcpy_pk"
	@echo -e "    9. memcpy_xcel_pk"
	@echo -e "   10. memcpy_xcel_fixed_pk"

#--------------------------------------------------------------------
# Output dir
#--------------------------------------------------------------------

$(BSG_OUT_DIR):
	mkdir -p $@

#--------------------------------------------------------------------
# DRAMSim2 init file
#--------------------------------------------------------------------

dramsim2_ini:
	ln -s $(BSG_RISCV_DIR)/rocket-chip/emulator/dramsim2_ini $@

#--------------------------------------------------------------------
# DRAMSim2
#--------------------------------------------------------------------

DRAMSIM_OBJS := $(patsubst %.cpp,%.o,$(wildcard $(BSG_RISCV_DIR)/rocket-chip/dramsim2/*.cpp))

$(DRAMSIM_OBJS): %.o: %.cpp
	$(CXX) $(CXXFLAGS) -DNO_STORAGE -DNO_OUTPUT -Dmain=nomain -c -o $@ $<

$(BSG_OUT_DIR)/libdramsim.a: $(DRAMSIM_OBJS) $(BSG_OUT_DIR)
	ar rcs $@ $(DRAMSIM_OBJS)

#---------------------------------------------------------------------
# Constants Header Files
#---------------------------------------------------------------------

params_file = $(generated_dir)/$(MODEL).$(CONFIG).prm
consts_header = $(BSG_OUT_DIR)/consts.$(CONFIG).h

$(consts_header): $(params_file) $(BSG_OUT_DIR)
	echo "#ifndef __CONST_H__" > $@
	echo "#define __CONST_H__" >> $@
	sed -r 's/\(([A-Za-z0-9_]+),([A-Za-z0-9_]+)\)/#define \1 \2/' $< >> $@
	echo "#define TBFRAG \"$(MODEL).$(CONFIG).tb.cpp\"" >> $@
	echo "#endif // __CONST_H__" >> $@

#--------------------------------------------------------------------
# Sram generation
#--------------------------------------------------------------------

sram_library_file = $(generated_dir)/sram.v

$(sram_library_file): $(generated_dir)/$(MODEL).$(CONFIG).conf
	$(BSG_COMMON_DIR)/scripts/bsg_vlsi_mem_gen $< > $@

#--------------------------------------------------------------------
# FSB rom generation
#--------------------------------------------------------------------

bsg_fsb_trace_in = $(BSG_DESIGNS_DIR)/modules/bsg_guts/trace_replay/testing/bsg_fsb_master_rom.rocket.trace.in
bsg_fsb_master_rom_v = $(generated_dir)/bsg_fsb_master_rom.v

$(bsg_fsb_master_rom_v):
	$(BSG_IP_CORES_DIR)/bsg_mem/bsg_ascii_to_rom.py $(bsg_fsb_trace_in) bsg_fsb_master_rom > $@

#--------------------------------------------------------------------
# VCS
#--------------------------------------------------------------------

vcs_sram_config = $(BSG_OUT_DIR)/vcs_sram_config

export BSG_CHIP_LIB_NAME = chip
export BSG_CHIP_LIB = $(BSG_OUT_DIR)/bsg_$(BSG_CHIP_LIB_NAME)_lib
export BSG_CHIP_FILELIST = $(BSG_OUT_DIR)/bsg_$(BSG_CHIP_LIB_NAME)_filelist

export BSG_TEST_LIB_NAME = test
export BSG_TEST_LIB = $(BSG_OUT_DIR)/bsg_$(BSG_TEST_LIB_NAME)_lib
export BSG_TEST_FILELIST = $(BSG_OUT_DIR)/bsg_$(BSG_TEST_LIB_NAME)_filelist

vcs_config_files = $(BSG_CHIP_LIB) $(BSG_CHIP_FILELIST) $(BSG_TEST_LIB) $(BSG_TEST_FILELIST)

$(vcs_sram_config): $(BSG_OUT_DIR)
	@echo "module bsg_mem_1rw_sync_synth random" > $@
	@echo "module bsg_mem_1rw_sync_mask_write_bit_synth random" >> $@
	@echo "module bsg_mem_1r1w_sync_mask_write_bit_synth random" >> $@

sim_csrcs = \
	$(BSG_RISCV_DIR)/rocket-chip/csrc/vcs_main.$(TB).cc \
	$(BSG_RISCV_DIR)/rocket-chip/csrc/mm.cc \
	$(BSG_RISCV_DIR)/rocket-chip/csrc/mm_dramsim2.cc \

VCS_OPT += -notice -line +lint=all,noVCDE,noONGS,noUI -error=PCWM-L -quiet
VCS_OPT += -full64 +rad +v2k +vcs+lic+wait +vc+list +libext+.v -debug_pp
VCS_OPT += -v2k_generate -sverilog
VCS_OPT += -timescale=1ps/1ps -diag timescale
VCS_OPT += -e vcs_main
VCS_OPT += -CC "-I$(VCS_HOME)/include"
VCS_OPT += -CC "-I$(RISCV)/include"
VCS_OPT += -CC "-I$(BSG_RISCV_DIR)/rocket-chip/dramsim2"
VCS_OPT += -CC "-I$(abspath .)/dramsim2_ini"
VCS_OPT += -CC "-std=c++11"
VCS_OPT += -CC "-Wl,-rpath,$(RISCV)/lib"
VCS_OPT += -CC "-include $(consts_header)"
VCS_OPT += -CC "-include $(generated_dir)/$(MODEL).$(CONFIG).scr_map.h"
VCS_OPT += +define+CORE_CLOCK_PERIOD_PS=500
VCS_OPT += +define+IO_CLOCK_PERIOD_PS=2000
VCS_OPT += +define+MANYCORE_CLOCK_PERIOD_PS=2000
VCS_OPT += +define+ARM_UD_MODEL
VCS_OPT += +define+PRINTF_COND=$(TB).verbose
VCS_OPT += +define+BSG_CHIP_LIB_NAME=$(BSG_CHIP_LIB_NAME)
VCS_OPT += +define+BSG_TEST_LIB_NAME=$(BSG_TEST_LIB_NAME)
VCS_OPT += $(RISCV)/lib/libfesvr.so
VCS_OPT += $(BSG_OUT_DIR)/libdramsim.a
VCS_OPT += +vcs+initreg+config+$(vcs_sram_config)
VCS_OPT += $(sim_csrcs)
VCS_OPT += -f $(BSG_CHIP_FILELIST)
VCS_OPT += -libmap $(BSG_CHIP_LIB)
VCS_OPT += -f $(BSG_TEST_FILELIST)
VCS_OPT += -libmap $(BSG_TEST_LIB)
VCS_OPT += -top cfg_rtl
VCS_OPT += ./cfg_rtl.v

VCS_DEP += $(consts_header)
VCS_DEP += $(BSG_OUT_DIR)/libdramsim.a
VCS_DEP += $(sram_library_file)
VCS_DEP += $(bsg_fsb_master_rom_v)
VCS_DEP += $(vcs_sram_config)
VCS_DEP += dramsim2_ini
VCS_DEP += $(vcs_config_files)
VCS_DEP += $(BSG_OUT_DIR)/bsg_ip_cores
VCS_DEP += $(BSG_OUT_DIR)/bsg_designs
VCS_DEP += $(BSG_OUT_DIR)/bsg_rocket

$(BSG_OUT_DIR)/bsg_ip_cores: | $(BSG_OUT_DIR)
	ln -s $(BSG_IP_CORES_DIR) $|

$(BSG_OUT_DIR)/bsg_designs: | $(BSG_OUT_DIR)
	ln -s $(BSG_DESIGNS_DIR) $|

$(BSG_OUT_DIR)/bsg_rocket: | $(BSG_OUT_DIR)
	ln -s $(BSG_ROCKET_DIR) $|

# library and mapping generation
$(vcs_config_files): $(BSG_OUT_DIR)
	tclsh ./cfg_vcs.tcl

simv = $(BSG_OUT_DIR)/simv-$(MODEL)-$(CONFIG)-$(ROCKET_NAME)

$(simv): $(VCS_DEP)
	$(VCS_BIN)/vcs $(VCS_OPT) -o $@

build: clean $(simv)

SIM_OPT = -q +ntb_random_seed_automatic +dramsim +verbose +max-cycles=$(TIMEOUT_CYCLES)
c_src = $(wildcard $(riscv_bmark_dir)/$(BENCHMARK)/*.c)

$(BSG_OUT_DIR)/%.rv: $(BSG_OUT_DIR)
	$(RISCV)/bin/riscv64-unknown-elf-gcc \
	-DHOST_DEBUG=1 -DPREALLOCATE=0 -U__riscv \
	-I$(UCB_BENCHMARK_DIR)/common -I$(riscv_bmark_dir)/$(BENCHMARK) \
	$(c_src) -o $@

$(BSG_OUT_DIR)/%.out: $(BSG_OUT_DIR)/%.rv  $(simv) $(BSG_OUT_DIR)
	$(simv) $(SIM_OPT) $(RISCV)/riscv64-unknown-elf/bin/pk $< 3>&1 1>&2 2>&3 | $(RISCV)/bin/spike-dasm > $@

run: $(BSG_OUT_DIR) $(BSG_OUT_DIR)/$(BENCHMARK).out

clean:
	-rm -rf $(BSG_OUT_DIR) $(sram_library_file) vc_hdrs.h csrc ucli.key
	-rm -rf dramsim2_ini DVEfiles $(bsg_fsb_master_rom_v)
	make -C $(BSG_RISCV_DIR)/rocket-chip/dramsim2 clean
