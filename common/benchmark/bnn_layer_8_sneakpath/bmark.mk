#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

bnn_layer_c_src =     \
	bnn_layer.c   \
	bnn_common.c  \
	syscalls.c    \

bnn_layer_cc_src =    \

bnn_layer_riscv_src = \
	crt.S         \

bnn_layer_c_objs        = $(patsubst %.c, %.o, $(bnn_layer_c_src))
bnn_layer_cc_objs       = $(patsubst %.cc, %.o, $(bnn_layer_cc_src))
bnn_layer_riscv_objs    = $(patsubst %.S, %.o, $(bnn_layer_riscv_src))

bmarks_extra_defs = -D_RISCV -D_ROCKET

bnn_layer_host_bin = bnn_layer_8_sneakpath.host
$(bnn_layer_host_bin) : $(bnn_layer_c_src)
	$(HOST_COMP) $^ -o $(bnn_layer_host_bin)

bnn_layer_riscv_bin = bnn_layer_8_sneakpath.riscv
$(bnn_layer_riscv_bin) : $(bnn_layer_c_objs) $(bnn_layer_cc_objs) $(bnn_layer_riscv_objs)
	$(RISCV_LINK) $(bnn_layer_cc_objs) $(bnn_layer_c_objs) $(bnn_layer_riscv_objs) -o $(bnn_layer_riscv_bin) $(RISCV_LINK_OPTS)

junk += $(bnn_layer_c_objs) $(bnn_layer_cc_objs) $(bnn_layer_riscv_objs) \
        $(bnn_layer_host_bin) $(bnn_layer_riscv_bin)
