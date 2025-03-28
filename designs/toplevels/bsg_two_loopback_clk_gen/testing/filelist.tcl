set bsg_designs_dir $::env(BSG_TESTING_BASE_DIR)/bsg_designs
set bsg_designs_target_dir $bsg_designs_dir/toplevels/$::env(BSG_DESIGNS_TARGET)
set bsg_boards_dir $::env(BSG_TESTING_BASE_DIR)/board/pcb/double_trouble/v
set bsg_packaging_pinout_dir $::env(BSG_TESTING_BASE_DIR)/bsg_packaging/$::env(BSG_PACKAGE)/pinouts/$::env(BSG_PINOUT)
set bsg_ip_cores_dir $::env(BSG_TESTING_BASE_DIR)/bsg_ip_cores

set TESTING_SOURCE_FILES [join "
  $bsg_ip_cores_dir/bsg_misc/bsg_defines.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_pkg.v
  $bsg_ip_cores_dir/bsg_misc/bsg_cycle_counter.v
  $bsg_ip_cores_dir/bsg_test/bsg_nonsynth_clock_gen.v
  $bsg_ip_cores_dir/bsg_test/bsg_nonsynth_reset_gen.v
  $bsg_ip_cores_dir/bsg_test/test_bsg_data_gen.v
  $bsg_ip_cores_dir/bsg_comm_link/test_bsg_comm_link_checker.v
  $bsg_boards_dir/bsg_double_trouble_pcb.v
  $bsg_boards_dir/bsg_two/bsg_gateway_socket.v
  $bsg_boards_dir/bsg_two/bsg_asic_socket.v
  $bsg_designs_target_dir/testing/bsg_gateway_chip.v
  $bsg_ip_cores_dir/testing/bsg_clk_gen/bsg_nonsynth_clk_gen_tester.v
  $bsg_ip_cores_dir/bsg_clk_gen/bsg_nonsynth_clk_watcher.v
  $bsg_designs_dir/modules/bsg_guts/loopback/bsg_test_node_master.v
  $bsg_designs_dir/modules/bsg_guts/bsg_guts.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_channel_control_master.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_channel_control_master_master.v
  $bsg_ip_cores_dir/bsg_misc/bsg_wait_cycles.v
  $bsg_ip_cores_dir/bsg_misc/bsg_wait_after_reset.v
  $bsg_ip_cores_dir/bsg_test/bsg_nonsynth_val_watcher_1p.v
  $bsg_ip_cores_dir/bsg_misc/bsg_circular_ptr.v
  $bsg_ip_cores_dir/bsg_misc/bsg_scan.v
  $bsg_ip_cores_dir/bsg_misc/bsg_dff.v
  $bsg_ip_cores_dir/bsg_misc/bsg_rotate_right.v
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
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_narrow.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1r1w_narrowed.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_tracker.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1r1w_small.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_murn_gateway.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_front_side_bus_hop_in.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_front_side_bus_hop_out.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1r1w.v
"]
