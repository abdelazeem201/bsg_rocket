# TSMC_250 customization for bsg_two_loopback
#
# note: requires the following directories to be set
# bsg_ip_cores_dir
# bsg_chip_sub_design_dir
#

# list of files to replace
set asic_hard_filelist [join "
  $bsg_ip_cores_dir/hard/bsg_mem/bsg_mem_2r1w.v
  $bsg_ip_cores_dir/hard/bsg_mem/bsg_mem_1r1w.v
  $bsg_ip_cores_dir/hard/bsg_mem/bsg_mem_1rw_sync.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_tiehi.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_tielo.v
"]

set NEW_SVERILOG_SOURCE_FILES [join "
"]

# list of NETLIST files to add
set NETLIST_SOURCE_FILES [join "
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_TIEHI.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_TIELO.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_rf_w2_b62_1r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_rf_w4_b62_1r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_rf_w16_b62_1r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_rf_w32_b16_1r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_rf_w32_b8_1r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_rf_w32_b2_1r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_rf_w8_b8_1r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_rf_w2_b8_1r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_rf_w2_b64_1r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_rf_w2_b80_1r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_rf_w32_b32_2r1w.v
"]
