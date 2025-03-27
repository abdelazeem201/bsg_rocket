include ../../../../../cad/common/mk/cadenv.mk

MODEL := Top
CONFIG := Bsg1AccelVLSIConfig
TB := rocketTestHarness
ROCKET_NAME ?= bison_accum
BENCHMARK ?= bnn
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
export BSG_MANYCORE_DIR = $(abspath ../../../../../bsg_manycore)
export BSG_DESIGNS_TARGET_DIR = $(BSG_DESIGNS_DIR)/toplevels/bsg_two_$(ROCKET_NAME)

export BSG_PACKAGING_FOUNDRY=tsmc_180_250
export BSG_PACKAGE=ucsd_bga_332
export BSG_PINOUT=bsg_two
export BSG_PINOUT_FOUNDRY=tsmc_180
export BSG_PADMAPPING=experimental

export ASM_TESTS_DIR=asm_tests

#export BSG_DESIGNS_TARGET_DIR = $(BSG_DESIGNS_DIR)/toplevels/bsg_two_bison_manycore

CC = /opt/rh/devtoolset-2/root/usr/bin/gcc
CXX = /opt/rh/devtoolset-2/root/usr/bin/g++
CXXFLAGS := -O1

generated_dir = $(abspath ../../generated-src)
benchmark_dir = $(BSG_COMMON_DIR)/benchmark
riscv_bmark_dir = $(abspath ../../../../../bsg_riscv/rocket-chip/riscv-tools/riscv-tests/benchmarks)
manycore_bmark_dir = $(abspath ../../../../../bsg_manycore/software/spmd)

#Check if this is a manycore test case
ifneq (,$(findstring manycore,$(BENCHMARK)))
	MANYCORE_DEP=	$(benchmark_dir)/$(BENCHMARK)/manycore.vec.c 	\
					$(benchmark_dir)/$(BENCHMARK)/manycore.riscv64 	\
					$(benchmark_dir)/$(BENCHMARK)/manycore.cfg.h 	\
				 	$(riscv_bmark_dir)/bsg_rocket_manycore_common
else
	MANYCORE_DEP=
endif

-include $(generated_dir)/Top.$(CONFIG).d

default:
	@echo -e "\n----------------- bsg dependencies ---------------------"
	@echo -e "\n1. git clone bsg_ip_cores, bsg_designs, bsg_packaging, bsg_rocket, bsg_riscv, cad"
	@echo -e "2. Go to bsg_riscv"
	@echo -e "3. make checkout-all"
	@echo -e "4. make build-riscv-tools-newlib"
	@echo -e "5. Go to bsg_rocket/rockets/bison/testing/rtl"
	@echo -e "6. make build"
	@echo -e "7. make run BENCHMARK=accumulator"
	@echo -e "\n----------------- simulation options ---------------------"
	@echo -e "\na) make build - create accumulator hex image"
	@echo -e "b) make run BENCHMARK=X - run X benchmark, where X can be:"
	@echo -e "    1. dhrystone"
	@echo -e "    2. median"
	@echo -e "    3. mm"
	@echo -e "    4. mt-matmul"
	@echo -e "    5. mt-vvadd"
	@echo -e "    6. multiply"
	@echo -e "    7. qsort"
	@echo -e "    8. spmv"
	@echo -e "    9. towers"
	@echo -e "   10. vvadd"
	@echo -e "   11. accumulator"
	@echo -e "   12. bnn"
	@echo -e "c) make run_debug BENCHMARK=X - run X benchmark and generate waveform"
	@echo -e "d) make full - run all benchmark"
	@echo -e "e) make full_debug - run all benchmark and generate waveform"
	@echo -e "f) make view BENCHMARK=X - view waveform X benchmark\n"

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

$(BSG_OUT_DIR)/libdramsim.a: $(DRAMSIM_OBJS) | $(BSG_OUT_DIR)
	ar rcs $@ $(DRAMSIM_OBJS)

#---------------------------------------------------------------------
# Constants Header Files
#---------------------------------------------------------------------

params_file = $(generated_dir)/$(MODEL).$(CONFIG).prm
consts_header = $(BSG_OUT_DIR)/consts.$(CONFIG).h

$(consts_header): $(params_file) | $(BSG_OUT_DIR)
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

$(vcs_sram_config): | $(BSG_OUT_DIR)
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
$(vcs_config_files): | $(BSG_OUT_DIR)
	tclsh ./cfg_vcs.tcl

simv = $(BSG_OUT_DIR)/simv-$(MODEL)-$(CONFIG)
simv_debug = $(BSG_OUT_DIR)/simv-$(MODEL)-$(CONFIG)

$(simv): $(VCS_DEP)
	$(VCS_BIN)/vcs $(VCS_OPT) -o $@

$(simv_debug): $(VCS_DEP)
	$(VCS_BIN)/vcs $(VCS_OPT) +define+DEBUG -debug_pp -o $@

SIM_OPT = -q +ntb_random_seed_automatic +dramsim +verbose +max-cycles=$(TIMEOUT_CYCLES)

b_hex = $(wildcard $(benchmark_dir)/*.hex)
b_out = $(subst .hex,.out,$(subst $(benchmark_dir),$(BSG_OUT_DIR),$(b_hex)))
b_vpd = $(subst .hex,.vpd,$(subst $(benchmark_dir),$(BSG_OUT_DIR),$(b_hex)))

$(b_out): $(b_hex)
$(b_vpd): $(b_hex)

$(BSG_OUT_DIR)/$(BENCHMARK).riscv.out: $(benchmark_dir)/$(BENCHMARK).riscv.hex

$(BSG_OUT_DIR)/%.out: $(benchmark_dir)/%.hex $(simv) | $(BSG_OUT_DIR)
	$(simv) $(SIM_OPT) +loadmem=$< 3>&1 1>&2 2>&3 | spike-dasm > $@

ASM_TESTING_LOG?=asm_testing.log

$(BSG_OUT_DIR)/%.out: $(ASM_TESTS_DIR)/%.hex $(simv) | $(BSG_OUT_DIR)
	@echo -n '$(basename $(notdir $@)) ' | tee -a $(ASM_TESTING_LOG)
	@head -c $(shell echo -n $$(( 68 - $$(echo -n $(basename $(notdir $@)) | wc -m) )) ) /dev/zero | tr '\0' '.' | tee -a $(ASM_TESTING_LOG)
	@#printf '%.s.' {1..$(shell echo -n $$(( 68 - $$(echo -n $(basename $(notdir $@)) | wc -m) )) )}
	@echo -n ' ' | tee -a $(ASM_TESTING_LOG)
	@((( $(simv) $(SIM_OPT) +loadmem=$< 3>&1 1>&2 2>&3 | spike-dasm > $@ && [ $$PIPESTATUS -eq 0 ] ) \
	> $(BSG_OUT_DIR)/$(basename $(notdir $@)).log 2>&1 3>&1) \
	&& (echo -e '\033[0;32mPASS\033[0m' && (echo -e 'PASS' >> $(ASM_TESTING_LOG))) \
	|| (echo -e '\033[0;31mFAIL\033[0m' && (echo -e 'FAIL' >> $(ASM_TESTING_LOG))))

$(BSG_OUT_DIR)/%.vpd: $(benchmark_dir)/%.hex $(simv) | $(BSG_OUT_DIR)
	$(simv) $(SIM_OPT) +loadmem=$< +vcdplusfile=$@ 2>&1 | tee $(BSG_OUT_DIR)/$*.out

full: clean $(simv) $(b_out)
	@echo -e "\n*** [$@] simulation results"
	@grep --color=never -h "\*\*\* PASS" $(BSG_OUT_DIR)/*.out

run: clean $(simv) $(BSG_OUT_DIR)/$(BENCHMARK).riscv.out
	@echo -e "\n*** [$@] simulation results"
	@grep --color=never -h "\*\*\* PASS" $(BSG_OUT_DIR)/*.out

run_debug: clean $(simv_debug) $(BSG_OUT_DIR)/$(BENCHMARK).riscv.vpd
	@echo -e "\n*** [$@] simulation results"
	@grep --color=never -h "==" $(BSG_OUT_DIR)/*.out
	@grep --color=never -h "\*\*\* PASS" $(BSG_OUT_DIR)/*.out

view:
	$(DVE_BIN)/dve -full64 -vpd $(BSG_OUT_DIR)/$(BENCHMARK).riscv.vpd &

build: clean clean_$(BENCHMARK) $(benchmark_dir)/$(BENCHMARK).riscv.hex $(simv) $(BSG_OUT_DIR)


#Special target for manycore compilation
MANYCORE_OPT="-DROCKET_MANYCORE -O2"

$(manycore_bmark_dir)/$(BENCHMARK):
	cp -R $(benchmark_dir)/$(BENCHMARK)/manycore $@

$(benchmark_dir)/$(BENCHMARK)/manycore.vec.c: $(manycore_bmark_dir)/$(BENCHMARK)
	make -C $< main.vec.c RISCV_GCC_EXTRA_OPTS=$(MANYCORE_OPT)
	cp $</main.vec.c $@

$(benchmark_dir)/$(BENCHMARK)/manycore.riscv64: $(manycore_bmark_dir)/$(BENCHMARK)
	make -C $< main.riscv64 RISCV_GCC_EXTRA_OPTS=$(MANYCORE_OPT)
	cp $</main.riscv64 $@

$(benchmark_dir)/$(BENCHMARK)/manycore.cfg.h: $(manycore_bmark_dir)/$(BENCHMARK)
	make -C $< main.cfg.h RISCV_GCC_EXTRA_OPTS=$(MANYCORE_OPT)
	cp $</main.cfg.h $@

$(riscv_bmark_dir)/bsg_rocket_manycore_common:
	cp -R $(benchmark_dir)/bsg_rocket_manycore_common $@

#Dependency for riscv_benchmark
$(riscv_bmark_dir)/$(BENCHMARK): $(MANYCORE_DEP)
	ln -fs $(benchmark_dir)/$(BENCHMARK) $@
	#cp -r $(benchmark_dir)/$(BENCHMARK) $@

$(benchmark_dir)/$(BENCHMARK).riscv.hex: |$(riscv_bmark_dir)/$(BENCHMARK)
	# Patch the Makefile
	cp calc_hex_length.sh $(riscv_bmark_dir)
	[ -f $(riscv_bmark_dir)/Makefile.old ] || \
	  cp $(riscv_bmark_dir)/Makefile $(riscv_bmark_dir)/Makefile.old
	(patch --dry-run -N $(riscv_bmark_dir)/Makefile riscv.bmark.Makefile.patch) > /dev/null 2>&1 && \
	   patch -N $(riscv_bmark_dir)/Makefile riscv.bmark.Makefile.patch || \
	   echo "Patch already applied!"
	make -C $(riscv_bmark_dir) bmarks=$(BENCHMARK) bmarks_defs="-DPREALLOCATE=0 -DHOST_DEBUG=0"
	cp $|.riscv.hex $@

clean_$(BENCHMARK):
	make -C $(riscv_bmark_dir) clean
	-make -C $(riscv_bmark_dir) bmarks=$(BENCHMARK) clean
	-rm -rf $(riscv_bmark_dir)/$(BENCHMARK)
	-rm -rf $(manycore_bmark_dir)/$(BENCHMARK)
	-rm -rf $(benchmark_dir)/$(BENCHMARK).riscv.hex
	-rm -rf $(benchmark_dir)/$(BENCHMARK)/manycore.vec.c
	-rm -rf $(benchmark_dir)/$(BENCHMARK)/manycore.riscv64
	-rm -rf $(benchmark_dir)/$(BENCHMARK)/manycore.cfg.h
	-rm -rf $(riscv_bmark_dir)/bsg_rocket_manycore_common

clean:
	-rm -rf $(BSG_OUT_DIR) $(sram_library_file) vc_hdrs.h csrc ucli.key
	-rm -rf $(benchmark_dir)/*.out dramsim2_ini DVEfiles $(bsg_fsb_master_rom_v)
	-rm -rf $(ASM_TESTS_DIR)
	make -C $(BSG_RISCV_DIR)/rocket-chip/dramsim2 clean
