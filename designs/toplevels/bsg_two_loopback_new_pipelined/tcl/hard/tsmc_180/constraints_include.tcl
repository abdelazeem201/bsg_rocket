# Constraints for TSMC_180

if { ${analysis_type} == "bc_wc" } {
  set CORE_CLOCK_PERIOD      4.5
  set MASTER_IO_CLOCK_PERIOD 4.0
} elseif { ${analysis_type} == "single_typical" } {
  set CORE_CLOCK_PERIOD      3.5
  set MASTER_IO_CLOCK_PERIOD 2.35
}

set INPUT_CELL_RISE_FALL_DIFF       [expr 1.37 - 1.15]
set OUTPUT_CELL_RISE_FALL_DIFF_A    0.8
set OUTPUT_CELL_RISE_FALL_DIFF_B    0.67
set OUTPUT_CELL_RISE_FALL_DIFF_C    0.17
set OUTPUT_CELL_RISE_FALL_DIFF_D    0.34

