source -echo $::env(BSG_CAD_DIR)/util/bsg/bsg_place_clk_gen.tcl

bsg_place_clk_gen clk_gen_core_inst 2260 567
#bsg_place_clk_gen clk_gen_iom_inst  2260 800

bsg_place_comm_link 2980 2400 2980 2400 \
                    1810 1810 2510 2510 \
                    1969.94 2648.78 2777.77 3479.05
bsg_bound_creator_abs fsb_node 1969.94 1736.58 2777.77 2578.26
update_bounds -name fsb_node -add [get_flat_cells -quiet *n_0__clnt*]

