#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

accumulator_c_src = \
	accumulator_main.c \
	syscalls.c \

accumulator_riscv_src = \
	crt.S \

accumulator_c_objs     = $(patsubst %.c, %.o, $(accumulator_c_src))
accumulator_riscv_objs = $(patsubst %.S, %.o, $(accumulator_riscv_src))

accumulator_host_bin = accumulator.host
$(accumulator_host_bin) : $(accumulator_c_src)
	$(HOST_COMP) $^ -o $(accumulator_host_bin)

accumulator_riscv_bin = accumulator.riscv
$(accumulator_riscv_bin) : $(accumulator_c_objs) $(accumulator_riscv_objs)
	$(RISCV_LINK) $(accumulator_c_objs) $(accumulator_riscv_objs) -o $(accumulator_riscv_bin) $(RISCV_LINK_OPTS)

junk += $(accumulator_c_objs) $(accumulator_riscv_objs) \
        $(accumulator_host_bin) $(accumulator_riscv_bin)
