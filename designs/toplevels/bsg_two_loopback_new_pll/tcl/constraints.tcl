source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hard/$::env(BSG_DESIGNS_HARD_TARGET)/constraints_include.tcl
source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_chip_timing_generated_clocks_constraint.tcl

## Create core clock on io pad
create_clock -period ${CORE_CLOCK_PERIOD} \
             -name core_pad_clk           \
             [get_ports p_misc_L_4_i]

## Create a generated core clock on the PLL output
create_generated_clock -name         core_clk                  \
                       -multiply_by  ${CORE_CLK_PLL_MULT}      \
                       -source       [get_ports p_misc_L_4_i]  \
                       -master_clock [get_clocks core_pad_clk] \
                       [get_pins core_clk_pll/out_clk]

## Create master_io clock on io pad
create_clock -period ${MASTER_IO_CLOCK_PERIOD} \
             -name master_io_pad_clk           \
             [get_ports p_PLL_CLK_i]

## Create a generated core clock on the PLL output
create_generated_clock -name         master_io_clk                  \
                       -multiply_by  ${MASTER_IO_CLK_PLL_MULT}      \
                       -source       [get_ports p_PLL_CLK_i]        \
                       -master_clock [get_clocks master_io_pad_clk] \
                       [get_pins io_master_clk_pll/out_clk]


## Timing constraints for the rest of the chip
bsg_chip_timing_generated_clocks_constraint \
  -package ucsd_bsg_332 \
  -reset_port [get_ports p_reset_i] \
  -core_clk_name    core_clk                                          \
  -core_clk_port    [get_attribute [get_generated_clocks core_clk] sources]     \
  -core_clk_period  [expr ${CORE_CLOCK_PERIOD}*${CORE_CLK_PLL_MULT}]  \
  -create_core_clk  0                                                 \
  -master_io_clk_name    master_io_clk                                               \
  -master_io_clk_port    [get_attribute [get_generated_clocks master_io_clk] sources]          \
  -master_io_clk_period  [expr ${MASTER_IO_CLOCK_PERIOD}*${MASTER_IO_CLK_PLL_MULT}]  \
  -create_master_clk     0                                                           \
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
