include ../../../../../cad/common/mk/cadenv.mk

MODEL := Top
CONFIG := Bsg1AccelVLSIConfig
TB := test_five
#ROCKET_NAME ?=celerity
ROCKET_NAME ?=certus_soc
#coyote_5_manycore_xy_16_31_bnn_v1p5_sneakpath_pll_3_ldo_manycore_xy_2_5_pipelined_remote_load_amoswap

#BENCHMARK_0 ?= five/r0
#BENCHMARK_1 ?= five/r1
#BENCHMARK_2 ?= five/r2
#BENCHMARK_3 ?= five/r3
#BENCHMARK_4 ?= five/r4

ifeq ($(BENCHMARK_0),)
ifeq ($(BENCHMARK_1),)
ifeq ($(BENCHMARK_2),)
ifeq ($(BENCHMARK_3),)
ifeq ($(BENCHMARK_4),)
# Special case where no benchmark is specified
BENCHMARK_0 = five/r0
BENCHMARK_1 = five/r1
BENCHMARK_2 = five/r2
BENCHMARK_3 = five/r3
BENCHMARK_4 = five/r4
endif
endif
endif
endif
endif

# The variable to determing which core is tested for trace/replay
TR_CORE_ID ?= 0

# Check core 0
ifneq ($(BENCHMARK_0),)
ENABLE_ROCKET_0 = +enable_rocket_0
TR_CORE_ID =0
else
BENCHMARK_0 = five/r0
ENABLE_ROCKET_0 =
endif

# Check core 1
ifneq ($(BENCHMARK_1),)
ENABLE_ROCKET_1 = +enable_rocket_1
TR_CORE_ID =1
else
BENCHMARK_1 = five/r1
ENABLE_ROCKET_1 =
endif

# Check core 2
ifneq ($(BENCHMARK_2),)
TR_CORE_ID =2
ENABLE_ROCKET_2 = +enable_rocket_2
else
BENCHMARK_2 = five/r2
ENABLE_ROCKET_2 =
endif

# Check core 3
ifneq ($(BENCHMARK_3),)
ENABLE_ROCKET_3 = +enable_rocket_3
TR_CORE_ID =3
else
BENCHMARK_3 = five/r3
ENABLE_ROCKET_3 =
endif

# Check core 4
ifneq ($(BENCHMARK_4),)
ENABLE_ROCKET_4 = +enable_rocket_4
TR_CORE_ID =4
else
BENCHMARK_4 = five/r4
ENABLE_ROCKET_4 =
endif

$(warning using bsg_design $(ROCKET_NAME))

TIMEOUT_CYCLES ?= 100000000
RISCV ?= $(abspath ../../../../../bsg_riscv/riscv-install)

export BSG_PACKAGING_FOUNDRY=tsmc_16
export BSG_PACKAGE=ucsd_bga_332
export BSG_PINOUT ?= bsg_three
export BSG_PINOUT_FOUNDRY=tsmc_16
export BSG_PADMAPPING=one

export PATH:=$(RISCV)/bin:/opt/rh/devtoolset-2/root/usr/bin:$(PATH)
export BSG_OUT_DIR = $(abspath ./out)
export BSG_COMMON_DIR = $(abspath ../../../../common)
export BSG_RISCV_DIR = $(abspath ../../../../../bsg_riscv)
export BSG_PACKAGING_DIR = $(abspath ../../../../../bsg_packaging)
export BSG_IP_CORES_DIR = $(abspath ../../../../../bsg_ip_cores)
export BSG_DESIGNS_DIR = $(abspath ../../../../../bsg_designs)
export BSG_ROCKET_DIR = $(abspath ../../../../../bsg_rocket)
export BSG_MANYCORE_DIR = $(abspath ../../../../../bsg_manycore)
export BSG_DESIGNS_TARGET = $(BSG_PINOUT)_$(ROCKET_NAME)
export BSG_DESIGNS_TARGET_DIR = $(BSG_DESIGNS_DIR)/toplevels/$(BSG_DESIGNS_TARGET)

#export BSG_DESIGNS_TARGET_DIR = $(BSG_DESIGNS_DIR)/toplevels/bsg_two_bison_manycore


#CC = /opt/rh/devtoolset-2/root/usr/bin/gcc
CC =gcc
#CXX = /opt/rh/devtoolset-2/root/usr/bin/g++
CXX =g++
CXXFLAGS := -O1

generated_dir = $(abspath ../../generated-src)
benchmark_dir = $(BSG_COMMON_DIR)/benchmark
riscv_bmark_dir = $(abspath ../../../../../bsg_riscv/rocket-chip/riscv-tools/riscv-tests/benchmarks)
trace_out = $(BSG_OUT_DIR)/trace.out
waveform_vpd = $(BSG_OUT_DIR)/waveform.vpd

.PRECIOUS: $(waveform_vpd)


include Makefile.config
include Makefile.manycore

default:
	@echo -e "\n----------------- Directions ---------------------"
	@echo -e "\nEvery BENCHMARK_X correspond to a ROCKET_X, for example"
	@echo -e "if one wants to run towers in rocket[0], then one should"
	@echo -e "set BENCHMARK_0=towers"

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

ifneq "$(bsg_enable_replay)" "0"
bsg_fsb_MITM_stimulus_trace_in = ./fsb_node_$(TR_CORE_ID).stimulus.trace.in
bsg_fsb_MITM_response_trace_in = ./fsb_node_$(TR_CORE_ID).response.trace.in
else
bsg_fsb_MITM_stimulus_trace_in = $(bsg_fsb_trace_in) 
bsg_fsb_MITM_response_trace_in = $(bsg_fsb_trace_in) 
endif
## Pass the core id to the verilog 
VCS_OPT += +define+bsg_tr_core_id=$(TR_CORE_ID)
bsg_fsb_MITM_stimulus_rom_v = $(generated_dir)/bsg_fsb_MITM_stimulus_rom.v
bsg_fsb_MITM_response_rom_v = $(generated_dir)/bsg_fsb_MITM_response_rom.v

$(bsg_fsb_master_rom_v):
	$(BSG_IP_CORES_DIR)/bsg_mem/bsg_ascii_to_rom.py $(bsg_fsb_trace_in) bsg_fsb_master_rom > $@

gen_src: $(sram_library_file) $(bsg_fsb_master_rom_v)

$(bsg_fsb_MITM_stimulus_rom_v):
	$(BSG_IP_CORES_DIR)/bsg_mem/bsg_ascii_to_rom.py $(bsg_fsb_MITM_stimulus_trace_in) bsg_fsb_MITM_stimulus_rom > $@

$(bsg_fsb_MITM_response_rom_v):
	@if ! [ "${bsg_enable_replay}" -eq "0" ] ; then \
		echo " #Stop Simulation. Patched line from Makefile" >> $(bsg_fsb_MITM_response_trace_in); \
		echo " 0100____0000__0_000_00000000__00000000_00000000_00000000_00000000__00000000_00000000_00000000_00000000" >> $(bsg_fsb_MITM_response_trace_in); \
	fi
	$(BSG_IP_CORES_DIR)/bsg_mem/bsg_ascii_to_rom.py $(bsg_fsb_MITM_response_trace_in) bsg_fsb_MITM_response_rom > $@


#--------------------------------------------------------------------
# VCS
#--------------------------------------------------------------------

export BSG_CHIP_LIB_NAME = chip
export BSG_CHIP_LIB = $(BSG_OUT_DIR)/bsg_$(BSG_CHIP_LIB_NAME)_lib
export BSG_CHIP_FILELIST = $(BSG_OUT_DIR)/bsg_$(BSG_CHIP_LIB_NAME)_filelist

export BSG_TEST_LIB_NAME = test
export BSG_TEST_LIB = $(BSG_OUT_DIR)/bsg_$(BSG_TEST_LIB_NAME)_lib
export BSG_TEST_FILELIST = $(BSG_OUT_DIR)/bsg_$(BSG_TEST_LIB_NAME)_filelist

vcs_config_files = $(BSG_CHIP_LIB) $(BSG_CHIP_FILELIST) $(BSG_TEST_LIB) $(BSG_TEST_FILELIST)

sim_csrcs = \
	$(BSG_ROCKET_DIR)/common/csrc/vcs_main.$(TB).cc \
	$(BSG_ROCKET_DIR)/common/csrc/mm.cc \
	$(BSG_ROCKET_DIR)/common/csrc/mm_dramsim2.cc \

VCS_OPT += -notice -line +lint=all,noVCDE,noONGS,noUI -error=PCWM-L -quiet
VCS_OPT += -full64 +rad +vcs+lic+wait +vc+list +libext+.v -debug_pp
VCS_OPT += -sverilog
VCS_OPT += -timescale=1ps/1ps -diag timescale
VCS_OPT += -e vcs_main
VCS_OPT += -CC "-I$(VCS_HOME)/include"
VCS_OPT += -CC "-I$(RISCV)/include"
VCS_OPT += -CC "-I$(BSG_RISCV_DIR)/rocket-chip/dramsim2"
VCS_OPT += -CC "-I$(BSG_RISCV_DIR)/rocket-chip/csrc"
VCS_OPT += -CC "-I$(BSG_ROCKET_DIR)/common/csrc"
VCS_OPT += -CC "-I$(abspath .)/dramsim2_ini"
VCS_OPT += -CC "-std=c++11"
VCS_OPT += -CC "-Wl,-rpath,$(RISCV)/lib"
VCS_OPT += -CC "-include $(consts_header)"
VCS_OPT += -CC "-include $(generated_dir)/$(MODEL).$(CONFIG).scr_map.h"
VCS_OPT += +define+CORE_CLOCK_PERIOD_PS=500
VCS_OPT += +define+IO_CLOCK_PERIOD_PS=2000
VCS_OPT += +define+MANYCORE_CLOCK_PERIOD_PS=20
VCS_OPT += +define+ARM_UD_MODEL
VCS_OPT += +define+PRINTF_COND=$(TB).verbose
VCS_OPT += +define+BSG_CHIP_LIB_NAME=$(BSG_CHIP_LIB_NAME)
VCS_OPT += +define+BSG_TEST_LIB_NAME=$(BSG_TEST_LIB_NAME)
VCS_OPT += $(RISCV)/lib/libfesvr.so
VCS_OPT += $(BSG_OUT_DIR)/libdramsim.a
VCS_OPT += $(sim_csrcs)
VCS_OPT += -f $(BSG_CHIP_FILELIST)
VCS_OPT += -libmap $(BSG_CHIP_LIB)
VCS_OPT += -f $(BSG_TEST_FILELIST)
VCS_OPT += -libmap $(BSG_TEST_LIB)
VCS_OPT += -top cfg_rtl
VCS_OPT += ./cfg_rtl.v
#VCS_OPT += -xprop=xprop.cfg

# Switch pinout inside test_five_system.v
ifeq (bsg_two,$(BSG_PINOUT))
VCS_OPT += +define+BSG_TWO_PINOUT
else
ifeq (bsg_three,$(BSG_PINOUT))
VCS_OPT += +define+BSG_THREE_PINOUT
endif
endif

VCS_DEP += $(consts_header)
VCS_DEP += $(BSG_OUT_DIR)/libdramsim.a
VCS_DEP += $(sram_library_file)
VCS_DEP += $(bsg_fsb_master_rom_v)
VCS_DEP += $(bsg_fsb_MITM_stimulus_rom_v)
VCS_DEP += $(bsg_fsb_MITM_response_rom_v)

VCS_DEP += dramsim2_ini
VCS_DEP += $(vcs_config_files)
VCS_DEP += $(BSG_OUT_DIR)/bsg_ip_cores
VCS_DEP += $(BSG_OUT_DIR)/bsg_designs
VCS_DEP += $(BSG_OUT_DIR)/bsg_rocket
VCS_DEP += $(BSG_OUT_DIR)/bsg_manycore

$(BSG_OUT_DIR)/bsg_ip_cores: | $(BSG_OUT_DIR)
	ln -s $(BSG_IP_CORES_DIR) $|

$(BSG_OUT_DIR)/bsg_designs: | $(BSG_OUT_DIR)
	ln -s $(BSG_DESIGNS_DIR) $|

$(BSG_OUT_DIR)/bsg_rocket: | $(BSG_OUT_DIR)
	ln -s $(BSG_ROCKET_DIR) $|

$(BSG_OUT_DIR)/bsg_manycore: | $(BSG_OUT_DIR)
	ln -s $(BSG_MANYCORE_DIR) $|

# library and mapping generation
$(vcs_config_files): | $(BSG_OUT_DIR)
	tclsh ./cfg_vcs.tcl

simv = $(BSG_OUT_DIR)/simv-$(MODEL)-$(CONFIG)
simv_debug = $(BSG_OUT_DIR)/simv-$(MODEL)-$(CONFIG)

$(simv): $(VCS_DEP)
	$(VCS_BIN)/vcs $(VCS_OPT) -o $@

$(simv_debug): $(VCS_DEP)
	$(VCS_BIN)/vcs $(VCS_OPT) +define+DEBUG -debug_pp -o $@

bsg_riscv_dir=$(abspath ../../../../../bsg_riscv)
ucb_asm_bmark_dir=$(abspath $(bsg_riscv_dir)/riscv-install/riscv64-unknown-elf/share/riscv-tests/isa)

# Switch between ASM and normal benchmark
# Benchmark_0
ifneq ($(shell [ -f $(ucb_asm_bmark_dir)/$(BENCHMARK_0).hex ] && echo "exists"),)
BENCHMARK_ARG_0=+mem_0=$(ucb_asm_bmark_dir)/$(BENCHMARK_0).hex
else
BENCHMARK_ARG_0=+mem_0=$(benchmark_dir)/$(BENCHMARK_0).riscv.hex
endif

# Benchmark_1
ifneq ($(shell [ -f $(ucb_asm_bmark_dir)/$(BENCHMARK_1).hex ] && echo "exists"),)
BENCHMARK_ARG_1=+mem_1=$(ucb_asm_bmark_dir)/$(BENCHMARK_1).hex
else
BENCHMARK_ARG_1=+mem_1=$(benchmark_dir)/$(BENCHMARK_1).riscv.hex
endif

# Benchmark_2
ifneq ($(shell [ -f $(ucb_asm_bmark_dir)/$(BENCHMARK_2).hex ] && echo "exists"),)
BENCHMARK_ARG_2=+mem_2=$(ucb_asm_bmark_dir)/$(BENCHMARK_2).hex
else
BENCHMARK_ARG_2=+mem_2=$(benchmark_dir)/$(BENCHMARK_2).riscv.hex
endif

# Benchmark_3
ifneq ($(shell [ -f $(ucb_asm_bmark_dir)/$(BENCHMARK_3).hex ] && echo "exists"),)
BENCHMARK_ARG_3=+mem_3=$(ucb_asm_bmark_dir)/$(BENCHMARK_3).hex
else
BENCHMARK_ARG_3=+mem_3=$(benchmark_dir)/$(BENCHMARK_3).riscv.hex
endif

# Benchmark_4
ifneq ($(shell [ -f $(ucb_asm_bmark_dir)/$(BENCHMARK_4).hex ] && echo "exists"),)
BENCHMARK_ARG_4=+mem_4=$(ucb_asm_bmark_dir)/$(BENCHMARK_4).hex
else
BENCHMARK_ARG_4=+mem_4=$(benchmark_dir)/$(BENCHMARK_4).riscv.hex
endif

# sim options
SIM_OPT += -q +dramsim +mem_verbose +htif_verbose +max-cycles=$(TIMEOUT_CYCLES)
SIM_OPT += $(BENCHMARK_ARG_0)
SIM_OPT += $(BENCHMARK_ARG_1)
SIM_OPT += $(BENCHMARK_ARG_2)
SIM_OPT += $(BENCHMARK_ARG_3)
SIM_OPT += $(BENCHMARK_ARG_4)
SIM_OPT += $(ENABLE_ROCKET_0)
SIM_OPT += $(ENABLE_ROCKET_1)
SIM_OPT += $(ENABLE_ROCKET_2)
SIM_OPT += $(ENABLE_ROCKET_3)
SIM_OPT += $(ENABLE_ROCKET_4)
#SIM_OPT += +vcs+stop+80950750

$(trace_out): $(simv) | $(BSG_OUT_DIR)
	$(simv) $(SIM_OPT) 3>&1 1>&2 2>&3 | spike-dasm > $@ && [ $$PIPESTATUS -eq 0 ]

$(waveform_vpd): $(simv) | $(BSG_OUT_DIR)
	$(simv) $(SIM_OPT) +vcdplusfile=$@ 3>&1 1>&2 2>&3 | spike-dasm > $(trace_out) && [ $$PIPESTATUS -eq 0 ] && echo -ne "\n\n ***PASS"
	grep DONE $(trace_out) 

run_build_raw: $(simv_debug) | $(BSG_OUT_DIR)

run_debug_raw: 
	$(simv) $(SIM_OPT) +vcdplusfile=$(waveform_vpd)

run: clean $(simv) $(trace_out)
	@echo -e "\n*** [$@] simulation results"

run_debug: clean $(simv_debug) $(waveform_vpd)
	@echo -e "\n*** [$@] simulation results"

run_soft:
	$(simv) $(SIM_OPT) 3>&1 1>&2 2>&3 | spike-dasm > /dev/null && [ $$PIPESTATUS -eq 0 ]
	@echo -e "\n*** [$@] simulation results"
run_all:
	./regress.sh --run TEST_REORDER_ALL --design coyote_5_manycore_xy_16_31_bnn_v1p5_sneakpath_pll_3_ldo_manycore_xy_2_5_pipelined_remote_load_amoswap

run_manycore_loopback:
	./regress.sh --run TEST_MANYCORE_LOOPBACK --design coyote_5_manycore_xy_16_31_bnn_v1p5_sneakpath_pll_3_ldo_manycore_xy_2_5_pipelined_remote_load_amoswap

build: clean $(simv)

view:
	$(DVE_BIN)/dve -full64 -vpd $(waveform_vpd) &

clean_$(BENCHMARK_0):
	make -C $(riscv_bmark_dir) clean
	-make -C $(riscv_bmark_dir) bmarks=$(BENCHMARK_0) clean
	-rm -rf $(riscv_bmark_dir)/$(BENCHMARK_0)
	-rm -rf $(manycore_bmark_dir)/$(BENCHMARK_0)
	-rm -rf $(benchmark_dir)/$(BENCHMARK_0).riscv.hex
	-rm -rf $(benchmark_dir)/$(BENCHMARK_0)/manycore.vec.c
	-rm -rf $(benchmark_dir)/$(BENCHMARK_0)/manycore.riscv64
	-rm -rf $(benchmark_dir)/$(BENCHMARK_0)/manycore.cfg.h
	-rm -rf $(benchmark_dir)/$(BENCHMARK_0)/bsg_manycore_lib
	-rm -rf $(riscv_bmark_dir)/bsg_rocket_manycore_common

clean:
	-rm -rf $(BSG_OUT_DIR) $(sram_library_file) vc_hdrs.h csrc ucli.key
	-rm -rf $(benchmark_dir)/*.out dramsim2_ini DVEfiles 
	-rm -rf $(bsg_fsb_master_rom_v) $(bsg_fsb_MITM_stimulus_rom_v) $(bsg_fsb_MITM_response_rom_v)
	make -C $(BSG_RISCV_DIR)/rocket-chip/dramsim2 clean
clean_trace:
	-rm -f $(trace_out)
