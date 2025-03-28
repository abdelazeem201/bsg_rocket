# TSMC_250 customization for bsg_two_loopback
#
# note: requires the following directories to be set
# bsg_ip_cores_dir
# bsg_chip_sub_design_dir
#

# list of files to replace
set asic_hard_filelist [join "
  $bsg_ip_cores_dir/hard/bsg_mem/bsg_mem_1rw_sync_mask_write_byte.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_clkbuf.v
"]

set NEW_SVERILOG_SOURCE_FILES [join "
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_dff_gatestack.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_mux2_gatestack.v
"]

# list of NETLIST files to add
set NETLIST_SOURCE_FILES [join "
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_CLKBUF.v
"]
