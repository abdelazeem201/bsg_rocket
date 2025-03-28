source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_tag_timing.tcl
source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_clk_gen_timing.tcl
source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_chip_timing_constraint.tcl

set JTAG_CLK_PERIOD 6.0
set OSC_PERIOD_INT 1.8

if { ${analysis_type} == "bc_wc" } {
  set CORE_CLOCK_PERIOD      5
  set MASTER_IO_CLOCK_PERIOD 5.5
} elseif { ${analysis_type} == "single_typical" } {
  set CORE_CLOCK_PERIOD      10
  set MASTER_IO_CLOCK_PERIOD 5.5
}

bsg_tag_clock_create bsg_tag_clk p_JTAG_TCK_i p_JTAG_TDI_i p_JTAG_TMS_i $JTAG_CLK_PERIOD 3.0
bsg_clk_gen_clock_create clk_gen_core_inst core_clk bsg_tag_clk $OSC_PERIOD_INT $CORE_CLOCK_PERIOD 5
bsg_clk_gen_clock_create clk_gen_iom_inst master_io_clk bsg_tag_clk $OSC_PERIOD_INT $MASTER_IO_CLOCK_PERIOD 5

create_clock -period $OSC_PERIOD_INT -name ext_clk p_misc_L_4_i
create_clock -period $OSC_PERIOD_INT -name clk_mux clk_out_mux_inst/data_o

set_max_transition 0.10 clk_mux
set_max_transition 0.10 ext_clk

bsg_chip_timing_constraint              \
  -package ucsd_bsg_332                 \
  -reset_port [get_ports p_reset_i]     \
  -core_clk_port clk_gen_core_inst/mux_inst/macro.b1_i/stack_b0/Y \
  -core_clk_name core_clk               \
  -core_clk_period ${CORE_CLOCK_PERIOD} \
  -master_io_clk_port clk_gen_iom_inst/mux_inst/macro.b1_i/stack_b0/Y        \
  -master_io_clk_name master_io_clk     \
  -master_io_clk_period ${MASTER_IO_CLOCK_PERIOD} \
  -create_core_clk 0                              \
  -create_master_clk 0                            \
  -input_cell_rise_fall_difference    [expr 1.37 - 1.15] \
  -output_cell_rise_fall_difference_A 0.8   \
  -output_cell_rise_fall_difference_B 0.67  \
  -output_cell_rise_fall_difference_C 0.17  \
  -output_cell_rise_fall_difference_D 0.34 

