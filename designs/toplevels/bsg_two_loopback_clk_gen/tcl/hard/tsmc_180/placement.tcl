source -echo $::env(BSG_CAD_DIR)/util/bsg/bsg_place_clk_gen.tcl

bsg_place_clk_gen clk_gen_core_inst 567 2490
bsg_place_clk_gen clk_gen_iom_inst  567 2352
bsg_place_clk_gen_mux 1050 2500
bsg_place_clk_gen_btm 1050 2300


bsg_place_comm_link_rotate 2850 [expr $bsg_max_y-288] 2850 $bsg_min_y 1625 [expr $bsg_max_y-288] 1625 $bsg_min_y \
                           3375 [expr $bsg_max_y-95]  3375 $bsg_min_y 1174 [expr $bsg_max_y-95]  1174 $bsg_min_y \
                           [expr $bsg_max_x-700] 3383 [expr $bsg_max_x-700] 1553 $bsg_min_x 3383 $bsg_min_x 1553 \
                           1969.94 2648.78 2777.77 3479.05

bsg_place_comm_link_guts 2200 2100

#bsg_bound_creator_abs fsb_node 1969.94 1736.58 2777.77 2578.26

#update_bounds -name fsb_node -add [get_flat_cells -quiet *n_0__clnt*]

