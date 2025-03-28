#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

bnn_pk_c_src = \
	bnn_main.c   \
	bnn_common.c \
	syscalls.c   \

bnn_pk_riscv_src = \
	crt.S \

bnn_pk_c_objs     = $(patsubst %.c, %.o, $(bnn_pk_c_src))
bnn_pk_riscv_objs = $(patsubst %.S, %.o, $(bnn_pk_riscv_src))

bnn_pk_host_bin = bnn_pk.host
$(bnn_pk_host_bin) : $(bnn_pk_c_src)
	$(HOST_COMP) $^ -o $(bnn_pk_host_bin)

bnn_pk_riscv_bin = bnn_pk.riscv
$(bnn_pk_riscv_bin) : $(bnn_pk_c_objs) $(bnn_pk_riscv_objs)
	$(RISCV_LINK) $(bnn_pk_c_objs) $(bnn_pk_riscv_objs) -o $(bnn_pk_riscv_bin) $(RISCV_LINK_OPTS)

junk += $(bnn_pk_c_objs) $(bnn_pk_riscv_objs) \
        $(bnn_pk_host_bin) $(bnn_pk_riscv_bin)
