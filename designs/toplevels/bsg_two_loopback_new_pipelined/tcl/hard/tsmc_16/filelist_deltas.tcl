# TSMC_16 customization for bsg_two_loopback
#
# note: requires the following directories to be set
# bsg_ip_cores_dir
# bsg_chip_sub_design_dir
#

# list of files to replace
set asic_hard_filelist [join "
  $bsg_ip_cores_dir/hard/tsmc_16/bsg_async/bsg_launch_sync_sync.v
  $bsg_ip_cores_dir/hard/tsmc_16/bsg_async/bsg_sync_sync.v
"]

set NEW_SVERILOG_SOURCE_FILES [join "
"]

# list of NETLIST files to add
set NETLIST_SOURCE_FILES [join "
"]
