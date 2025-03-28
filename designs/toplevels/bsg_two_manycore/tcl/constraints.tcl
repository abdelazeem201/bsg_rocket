source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_chip_timing_constraint.tcl

if { ${analysis_type} == "bc_wc" } {
  set CORE_CLOCK_PERIOD      10
  set MASTER_IO_CLOCK_PERIOD 5.5
} elseif { ${analysis_type} == "single_typical" } {
  set CORE_CLOCK_PERIOD      10
  set MASTER_IO_CLOCK_PERIOD 5.5
}

bsg_chip_timing_constraint \
  -package ucsd_bsg_332 \
  -reset_port [get_ports p_reset_i] \
  -core_clk_port [get_ports p_misc_L_4_i] \
  -core_clk_name core_clk \
  -core_clk_period ${CORE_CLOCK_PERIOD} \
  -master_io_clk_port [get_ports p_PLL_CLK_i] \
  -master_io_clk_name master_io_clk \
  -master_io_clk_period ${MASTER_IO_CLOCK_PERIOD}
