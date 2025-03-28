#------------------------------------------------------------
# Bespoke Systems Group
#------------------------------------------------------------
# File: filelist.tcl
#
# Do NOT arbitrarily change the order of files. Some module
# and macro definitions may be needed by the subsequent files
#------------------------------------------------------------

set bsg_ip_cores_dir $::env(BSG_IP_CORES_DIR)
set bsg_designs_dir $::env(BSG_DESIGNS_DIR)

set SVERILOG_SOURCE_FILES [join "
  $bsg_ip_cores_dir/bsg_misc/bsg_defines.v
  $bsg_ip_cores_dir/bsg_tag/bsg_tag_pkg.v
  $bsg_ip_cores_dir/bsg_misc/bsg_tielo.v
  $bsg_ip_cores_dir/bsg_misc/bsg_tiehi.v
  $bsg_ip_cores_dir/bsg_tag/bsg_tag_master.v
  $bsg_ip_cores_dir/bsg_tag/bsg_tag_client.v
  $bsg_ip_cores_dir/bsg_misc/bsg_counter_clear_up.v
  $bsg_ip_cores_dir/bsg_misc/bsg_dff_reset_en.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1rw_sync.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_byte.v
  $bsg_ip_cores_dir/bsg_misc/bsg_clkbuf.v
  $bsg_ip_cores_dir/bsg_async/bsg_launch_sync_sync.v
  $bsg_designs_dir/toplevels/bsg_two_tag_ram/v/bsg_chip.v
"]
