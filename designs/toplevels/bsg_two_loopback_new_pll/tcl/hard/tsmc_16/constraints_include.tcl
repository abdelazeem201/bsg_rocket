# Constraints for TSMC_16

if { ${analysis_type} == "bc_wc" } {
  set CORE_CLOCK_PERIOD         15000
  set CORE_CLK_PLL_MULT         1
  set MASTER_IO_CLOCK_PERIOD    14000
  set MASTER_IO_CLK_PLL_MULT    1
} elseif { ${analysis_type} == "single_typical" } {
  set CORE_CLOCK_PERIOD         15000
  set CORE_CLK_PLL_MULT         1
  set MASTER_IO_CLOCK_PERIOD    14000
  set MASTER_IO_CLK_PLL_MULT    1
}

set INPUT_CELL_RISE_FALL_DIFF       [expr 292.8 - 224.6]
set OUTPUT_CELL_RISE_FALL_DIFF_A    [expr 854.1 - 645.5]
set OUTPUT_CELL_RISE_FALL_DIFF_B    [expr 854.1 - 645.5]
set OUTPUT_CELL_RISE_FALL_DIFF_C    [expr 854.1 - 645.5]
set OUTPUT_CELL_RISE_FALL_DIFF_D    [expr 854.1 - 645.5]

