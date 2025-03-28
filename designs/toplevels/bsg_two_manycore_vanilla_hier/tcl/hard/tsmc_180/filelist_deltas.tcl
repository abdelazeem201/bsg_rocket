# process-customized files
#
# note: requires the following directories to be set
# bsg_ip_cores_dir
# bsg_chip_sub_design_dir
#

# list of files to replace
set asic_hard_filelist [join "
  $bsg_ip_cores_dir/hard/bsg_mem/bsg_mem_2r1w_sync.v
  $bsg_ip_cores_dir/hard/bsg_mem/bsg_mem_1r1w.v
  $bsg_ip_cores_dir/hard/bsg_mem/bsg_mem_1rw_sync.v
  $bsg_ip_cores_dir/hard/bsg_mem/bsg_mem_1rw_sync_mask_write_byte.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_tiehi.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_tielo.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_clkbuf.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_dff_reset.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_dff_reset_en.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_dff.v
"]

set NEW_SVERILOG_SOURCE_FILES [join "
"]

# list of NETLIST files to add
set NETLIST_SOURCE_FILES [join "
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_TIEHI.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_TIELO.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_CLKBUF.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_rf_1r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_rf_w32_b32_2r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_dff_nreset_s1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_dff_s1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_dff_s2.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_dff_s4.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_dff_nreset_en_s2.v
"]
