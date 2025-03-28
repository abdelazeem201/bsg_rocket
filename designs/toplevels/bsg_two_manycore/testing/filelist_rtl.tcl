set bsg_designs_target_dir $::env(BSG_DESIGNS_TARGET_DIR)
set bsg_designs_dir $::env(BSG_DESIGNS_DIR)
set bsg_boards_dir $::env(BSG_BOARDS_DIR)
set bsg_manycore_dir $::env(BSG_MANYCORE_DIR)
set bsg_packaging_pinout_dir $::env(BSG_PACKAGING_PINOUT_DIR)
set bsg_ip_cores_dir $::env(BSG_IP_CORES_DIR)

set TESTING_SOURCE_FILES [join "
 $bsg_ip_cores_dir/bsg_misc/bsg_defines.v
 $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_pkg.v
 $bsg_manycore_dir/testbenches/common/v/bsg_nonsynth_manycore_io_complex.v
 $bsg_manycore_dir/testbenches/common/v/bsg_manycore_spmd_loader.v
 $bsg_manycore_dir/testbenches/common/v/bsg_nonsynth_manycore_monitor.v
 $bsg_manycore_dir/testbenches/common/v/bsg_manycore_vscale_pipeline_trace.v
 $bsg_designs_target_dir/testing/bsg_manycore_io_complex_rom.v
 $bsg_ip_cores_dir/bsg_misc/bsg_cycle_counter.v
 $bsg_ip_cores_dir/bsg_test/bsg_nonsynth_clock_gen.v
 $bsg_ip_cores_dir/bsg_test/bsg_nonsynth_reset_gen.v
 $bsg_ip_cores_dir/bsg_test/test_bsg_data_gen.v
 $bsg_ip_cores_dir/bsg_comm_link/test_bsg_comm_link_checker.v
 $bsg_boards_dir/bsg_double_trouble_pcb.v
 $bsg_boards_dir/bsg_two/bsg_gateway_socket.v
 $bsg_boards_dir/bsg_two/bsg_asic_socket.v
 $bsg_designs_target_dir/testing/bsg_gateway_chip.v
 $bsg_designs_target_dir/testing/bsg_test_node_master.v
 $bsg_designs_dir/modules/bsg_guts/bsg_guts.v
 $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_channel_control_master.v
 $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_channel_control_master_master.v
 $bsg_ip_cores_dir/bsg_misc/bsg_wait_cycles.v
 $bsg_ip_cores_dir/bsg_misc/bsg_wait_after_reset.v
 $bsg_ip_cores_dir/bsg_test/bsg_nonsynth_val_watcher_1p.v
 $bsg_ip_cores_dir/bsg_dataflow/bsg_flatten_2D_array.v
 $bsg_ip_cores_dir/bsg_dataflow/bsg_make_2D_array.v
 $bsg_ip_cores_dir/bsg_comm_link/bsg_comm_link.v
  $bsg_ip_cores_dir/bsg_misc/bsg_circular_ptr.v
  $bsg_ip_cores_dir/bsg_misc/bsg_scan.v
  $bsg_ip_cores_dir/bsg_misc/bsg_thermometer_count.v
  $bsg_ip_cores_dir/bsg_misc/bsg_popcount.v
  $bsg_ip_cores_dir/bsg_misc/bsg_gray_to_binary.v
  $bsg_ip_cores_dir/bsg_misc/bsg_binary_plus_one_to_gray.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_credit_counter.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_fifo.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_ptr_gray.v
  $bsg_ip_cores_dir/bsg_async/bsg_launch_sync_sync.v
  $bsg_ip_cores_dir/bsg_async/bsg_sync_sync.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_assembler_in.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_assembler_out.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_comm_link.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_channel_control_slave.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_input.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_output.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_flatten_2D_array.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_make_2D_array.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_round_robin_fifo_to_fifo.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_sbox.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_scatter_gather.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_two_fifo.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_murn_gateway.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_front_side_bus_hop_in.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_front_side_bus_hop_out.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1r1w.v
"]

set TESTING_INCLUDE_PATHS [join "
  $bsg_packaging_pinout_dir/verilog
"]
