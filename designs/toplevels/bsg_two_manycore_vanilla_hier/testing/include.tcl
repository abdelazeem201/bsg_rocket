set bsg_packaging_pinout_dir $::env(BSG_TESTING_BASE_DIR)/bsg_packaging/$::env(BSG_PACKAGE)/pinouts/$::env(BSG_PINOUT)/common
set bsg_ip_cores_dir $::env(BSG_TESTING_BASE_DIR)/bsg_ip_cores
set bsg_manycore_dir $::env(BSG_MANYCORE_DIR)

set TESTING_INCLUDE_PATHS [join "
  $bsg_ip_cores_dir/bsg_misc
  $bsg_ip_cores_dir/bsg_tag
  $bsg_ip_cores_dir/bsg_noc
  $bsg_ip_cores_dir/bsg_clk_gen
  $bsg_packaging_pinout_dir/verilog
  $bsg_manycore_dir/v
"]
