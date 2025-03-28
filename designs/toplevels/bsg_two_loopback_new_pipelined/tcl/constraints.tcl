source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hard/$::env(BSG_DESIGNS_HARD_TARGET)/constraints_include.tcl
source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_chip_timing_constraint.tcl

bsg_chip_timing_constraint \
  -package ucsd_bsg_332 \
  -reset_port [get_ports p_reset_i] \
  -core_clk_port [get_ports p_misc_L_4_i] \
  -core_clk_name core_clk \
  -core_clk_period ${CORE_CLOCK_PERIOD} \
  -master_io_clk_port [get_ports p_PLL_CLK_i] \
  -master_io_clk_name master_io_clk \
  -master_io_clk_period ${MASTER_IO_CLOCK_PERIOD} \
  -create_core_clk 1   \
  -create_master_clk 1 \
  -input_cell_rise_fall_difference    $INPUT_CELL_RISE_FALL_DIFF \
  -output_cell_rise_fall_difference_A $OUTPUT_CELL_RISE_FALL_DIFF_A \
  -output_cell_rise_fall_difference_B $OUTPUT_CELL_RISE_FALL_DIFF_B \
  -output_cell_rise_fall_difference_C $OUTPUT_CELL_RISE_FALL_DIFF_C \
  -output_cell_rise_fall_difference_D $OUTPUT_CELL_RISE_FALL_DIFF_D

# TODO (stdavids):
# These shouled be moved to common/bsg_chip_timing_constraint.tcl
# but they are here for now while in development as to not disturb
# other bsg_designs
set_propagated_clock [get_clocks sdi_A_sclk]
set_propagated_clock [get_clocks sdi_B_sclk]
set_propagated_clock [get_clocks sdi_C_sclk]
set_propagated_clock [get_clocks sdi_D_sclk]
