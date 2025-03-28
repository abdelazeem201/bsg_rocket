#------------------------------------------------------------
# Do NOT arbitrarily change the order of files. Some module
# and macro definitions may be needed by the subsequent files
#------------------------------------------------------------

set bsg_ip_cores_dir $::env(BSG_IP_CORES_DIR)
set bsg_designs_dir $::env(BSG_DESIGNS_DIR)

set SVERILOG_SOURCE_FILES [join "
  $bsg_ip_cores_dir/bsg_misc/bsg_defines.v
  $bsg_ip_cores_dir/bsg_tag/bsg_tag_pkg.v
  $bsg_ip_cores_dir/bsg_misc/bsg_strobe.v
  $bsg_ip_cores_dir/bsg_misc/bsg_counter_clock_downsample.v
  $bsg_ip_cores_dir/bsg_misc/bsg_counter_clear_up.v
  $bsg_ip_cores_dir/bsg_misc/bsg_dff_en.v
  $bsg_ip_cores_dir/bsg_misc/bsg_tiehi.v
  $bsg_ip_cores_dir/bsg_misc/bsg_tielo.v
  $bsg_ip_cores_dir/bsg_misc/bsg_dff_reset_en.v
  $bsg_ip_cores_dir/bsg_misc/bsg_dff.v
  $bsg_ip_cores_dir/bsg_misc/bsg_dff_reset.v
  $bsg_ip_cores_dir/bsg_misc/bsg_dff_negedge_reset.v
  $bsg_ip_cores_dir/bsg_misc/bsg_mux.v
  $bsg_ip_cores_dir/bsg_misc/bsg_and.v
  $bsg_ip_cores_dir/bsg_misc/bsg_buf.v
  $bsg_ip_cores_dir/bsg_misc/bsg_clkbuf.v
  $bsg_ip_cores_dir/bsg_misc/bsg_nand.v
  $bsg_ip_cores_dir/bsg_misc/bsg_nor3.v
  $bsg_ip_cores_dir/bsg_misc/bsg_xor.v
  $bsg_ip_cores_dir/bsg_misc/bsg_xnor.v
  $bsg_ip_cores_dir/bsg_misc/bsg_reduce.v
  $bsg_ip_cores_dir/bsg_clk_gen/bsg_clk_gen_osc.v
  $bsg_ip_cores_dir/bsg_tag/bsg_tag_client.v
  $bsg_ip_cores_dir/bsg_tag/bsg_tag_master.v
  $bsg_ip_cores_dir/bsg_clk_gen/bsg_clk_gen.v
  $bsg_ip_cores_dir/bsg_async/bsg_launch_sync_sync.v
  $bsg_ip_cores_dir/bsg_async/bsg_sync_sync.v
  $bsg_ip_cores_dir/bsg_misc/bsg_circular_ptr.v
  $bsg_ip_cores_dir/bsg_misc/bsg_scan.v
  $bsg_ip_cores_dir/bsg_misc/bsg_rotate_right.v
  $bsg_ip_cores_dir/bsg_misc/bsg_thermometer_count.v
  $bsg_ip_cores_dir/bsg_misc/bsg_popcount.v
  $bsg_ip_cores_dir/bsg_misc/bsg_gray_to_binary.v
  $bsg_ip_cores_dir/bsg_misc/bsg_binary_plus_one_to_gray.v
  $bsg_ip_cores_dir/bsg_misc/bsg_dff_gatestack.v
  $bsg_ip_cores_dir/bsg_misc/bsg_muxi2_gatestack.v
  $bsg_ip_cores_dir/bsg_misc/bsg_mux2_gatestack.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_credit_counter.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_fifo.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_ptr_gray.v
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
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_pkg.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_murn_gateway.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_front_side_bus_hop_in.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_front_side_bus_hop_out.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1r1w.v
  $bsg_designs_dir/modules/bsg_guts/loopback/bsg_test_node_client.v
  $bsg_designs_dir/modules/bsg_guts/bsg_guts.v
  $bsg_designs_dir/toplevels/bsg_two_loopback_clk_gen/v/bsg_chip.v
"]
