#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

bnn_random_pool_c_src =     \
	bnn_random_pool.c   \
	bnn_common.c        \
	syscalls.c          \

bnn_random_pool_cc_src =    \

bnn_random_pool_riscv_src = \
	crt.S               \

bnn_random_pool_c_objs        = $(patsubst %.c, %.o, $(bnn_random_pool_c_src))
bnn_random_pool_cc_objs       = $(patsubst %.cc, %.o, $(bnn_random_pool_cc_src))
bnn_random_pool_riscv_objs    = $(patsubst %.S, %.o, $(bnn_random_pool_riscv_src))

bmarks_extra_defs = -D_RISCV -D_ROCKET

bnn_random_pool_host_bin = bnn_random_pool_8_sneakpath.host
$(bnn_random_pool_host_bin) : $(bnn_random_pool_c_src)
	$(HOST_COMP) $^ -o $(bnn_random_pool_host_bin)

bnn_random_pool_riscv_bin = bnn_random_pool_8_sneakpath.riscv
$(bnn_random_pool_riscv_bin) : $(bnn_random_pool_c_objs) $(bnn_random_pool_cc_objs) $(bnn_random_pool_riscv_objs)
	$(RISCV_LINK) $(bnn_random_pool_cc_objs) $(bnn_random_pool_c_objs) $(bnn_random_pool_riscv_objs) -o $(bnn_random_pool_riscv_bin) $(RISCV_LINK_OPTS)

junk += $(bnn_random_pool_c_objs) $(bnn_random_pool_cc_objs) $(bnn_random_pool_riscv_objs) \
        $(bnn_random_pool_host_bin) $(bnn_random_pool_riscv_bin)
