# bsg_two_loopback_clk_gen constraints
#

source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_tag_timing.tcl
source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_clk_gen_timing.tcl
source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_chip_timing_constraint.tcl

set JTAG_CLK_PERIOD 6.0
set OSC_PERIOD_INT 1.8

# create clock for bsg_tag, using pin p_JTAG_TCK_i, 10 ns period, with 3.0 percent clock uncertainty
# or 0.30 ns (5 percent uncertainty results in a lot of excess gates being inserted to satisfy hold times)

bsg_tag_clock_create bsg_tag_clk p_JTAG_TCK_i p_JTAG_TDI_i p_JTAG_TMS_i $JTAG_CLK_PERIOD 3.0

# 4.0 ns is no problem worst case for core clock in synthesis
if { ${analysis_type} == "bc_wc" } {
  set CORE_CLOCK_PERIOD      3.77
  set MASTER_IO_CLOCK_PERIOD 4.0
} elseif { ${analysis_type} == "single_typical" } {
  set CORE_CLOCK_PERIOD      3.5
  set MASTER_IO_CLOCK_PERIOD 2.35
}


# create clocks for bsg_clk_gen,
#   - using clk_gen_core_inst as the path for the oscillator in the netlist.
#   - using osc_clk as the name
#   - using 1.6 ns as the (guaranteed not to exceed) period
#   - using 5% as the uncertainty
#

bsg_clk_gen_clock_create clk_gen_core_inst core_clk bsg_tag_clk $OSC_PERIOD_INT $CORE_CLOCK_PERIOD 5

bsg_clk_gen_clock_create clk_gen_iom_inst  master_io_clk bsg_tag_clk  $OSC_PERIOD_INT $MASTER_IO_CLOCK_PERIOD 5

# create a clock for the incoming external clock
# this is a little fast; but no logic is directly driven by it
create_clock -period $OSC_PERIOD_INT -name ext_clk p_misc_L_4_i

# create a clock for the outgoing clock that we can observe
# we want to observe up to the maximum oscillator frequency
create_clock -period $OSC_PERIOD_INT -name clk_mux clk_out_mux_inst/data_o

#
# keep the edges sharp on point-to-point clocks that tend to have long wires
# the practical effect of this is that it will insert a buffer every 0.5 mm of wire
#

set_max_transition 0.10 clk_mux
set_max_transition 0.10 ext_clk

# get_attribute ext_clk max_transition




bsg_chip_timing_constraint              \
  -package ucsd_bsg_332                 \
  -reset_port [get_ports p_reset_i]     \
  -core_clk_port clk_gen_core_inst/clk_o \
  -core_clk_name core_clk               \
  -core_clk_period ${CORE_CLOCK_PERIOD} \
  -master_io_clk_port clk_gen_iom_inst/clk_o        \
  -master_io_clk_name master_io_clk     \
  -master_io_clk_period ${MASTER_IO_CLOCK_PERIOD} \
  -create_core_clk 0                              \
  -create_master_clk 0                            \
  -input_cell_rise_fall_difference    [expr 1.37 - 1.15] \
  -output_cell_rise_fall_difference_A 0.8   \
  -output_cell_rise_fall_difference_B 0.67  \
  -output_cell_rise_fall_difference_C 0.17  \
  -output_cell_rise_fall_difference_D 0.34 

# the above numbers are computed using the
# timing numbers of the different I/O transitions
# propogation delays 180 WC (using cap=15)
# A: PRT12DGZ  (3.62, 3.12) + .02*cap --> 0.8
# B: PRT16DGZ  (4.47,4.07) + .017 *cap --> 0.665
# C: PDT12DGZ  (2.38, 2.21) --> 0.17
# D: PDT16DGZ  (2.74, 2.40) --> 0.34

#  -core_clk_port [get_ports p_misc_L_4_i]    \
# -master_io_clk_port [get_ports p_PLL_CLK_i] \
