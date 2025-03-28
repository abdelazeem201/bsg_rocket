#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

bnn_loopback_c_src =   \
	bnn_loopback.c \
	syscalls.c     \

bnn_loopback_riscv_src = \
	crt.S            \

bnn_loopback_c_objs     = $(patsubst %.c, %.o, $(bnn_loopback_c_src))
bnn_loopback_riscv_objs = $(patsubst %.S, %.o, $(bnn_loopback_riscv_src))

bmarks_extra_defs = -D_RISCV -D_ROCKET

bnn_loopback_host_bin = bnn_loopback.host
$(bnn_loopback_host_bin) : $(bnn_loopback_c_src)
	$(HOST_COMP) $^ -o $(bnn_loopback_host_bin)

bnn_loopback_riscv_bin = bnn_loopback.riscv
$(bnn_loopback_riscv_bin) : $(bnn_loopback_c_objs) $(bnn_loopback_riscv_objs)
	$(RISCV_LINK) $(bnn_loopback_c_objs) $(bnn_loopback_riscv_objs) -o $(bnn_loopback_riscv_bin) $(RISCV_LINK_OPTS)

junk += $(bnn_loopback_c_objs) $(bnn_loopback_riscv_objs) \
        $(bnn_loopback_host_bin) $(bnn_loopback_riscv_bin)
