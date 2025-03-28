set bsg_designs_dir $::env(BSG_TESTING_BASE_DIR)/bsg_designs
set bsg_designs_target_dir $bsg_designs_dir/toplevels/$::env(BSG_DESIGNS_TARGET)
set bsg_boards_dir $::env(BSG_TESTING_BASE_DIR)/board/pcb/double_trouble/v
set bsg_packaging_pinout_dir $::env(BSG_TESTING_BASE_DIR)/bsg_packaging/$::env(BSG_PACKAGE)/pinouts/$::env(BSG_PINOUT)
set bsg_ip_cores_dir $::env(BSG_TESTING_BASE_DIR)/bsg_ip_cores

set TESTING_SOURCE_FILES [join "
 $bsg_ip_cores_dir/bsg_misc/bsg_defines.v
 $bsg_boards_dir/bsg_double_trouble_pcb.v
 $bsg_boards_dir/bsg_two/bsg_gateway_socket.v
 $bsg_boards_dir/bsg_two/bsg_asic_socket.v
 $bsg_designs_target_dir/testing/bsg_gateway_chip.v
 $bsg_ip_cores_dir/bsg_test/bsg_nonsynth_clock_gen.v
 $bsg_ip_cores_dir/bsg_clk_gen/bsg_nonsynth_clk_watcher.v
 $bsg_ip_cores_dir/testing/bsg_clk_gen/bsg_nonsynth_clk_gen_tester.v
"]
