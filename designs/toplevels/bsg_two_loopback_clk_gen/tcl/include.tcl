set bsg_ip_cores_dir $::env(BSG_IP_CORES_DIR)
set bsg_packaging_dir $::env(BSG_PACKAGING_DIR)

set bsg_package $::env(BSG_PACKAGE)
set bsg_pinout $::env(BSG_PINOUT)
set bsg_pinout_foundry $::env(BSG_PINOUT_FOUNDRY)
set bsg_padmapping $::env(BSG_PADMAPPING)

set SVERILOG_INCLUDE_PATHS [join "
  $bsg_ip_cores_dir/bsg_misc
  $bsg_ip_cores_dir/bsg_tag
  $bsg_ip_cores_dir/bsg_clk_gen
  $bsg_packaging_dir/common/verilog
  $bsg_packaging_dir/common/foundry/portable/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/common/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/$bsg_pinout_foundry/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/$bsg_pinout_foundry/verilog/padmappings/$bsg_padmapping
"]
