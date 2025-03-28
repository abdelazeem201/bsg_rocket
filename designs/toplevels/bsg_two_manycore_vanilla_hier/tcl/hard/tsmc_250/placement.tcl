// note to be replaced with
// placement/floorplanning helper script for vanilla core
proc bsg_place_vcore { base_x base_y } {

    set banks 4
    set masks 4

    # merge related bits into a row
    for {set j 0} {$j < $banks} {incr j} {
        create_rp_group vcore_bank_${j} -design bsg_chip -columns $banks -rows 1
        for {set i 0} {$i < $masks} {incr i} {
            add_to_rp_group bsg_chip::vcore_bank_${j} -hier [get_attribute  g/n_0__ode/bm/y_0__x_0__proc/h_z/bnkd_xbar/z_${j}__m1rw_mask/bk_${i}__mem_1rw_sync/z_s1r1w_mem/macro_w32_b8/reg_w10_b2 rp_group_name] -column $i -row 0
        }

        bsg_bound_creator g/n_0__ode/bm/y_0__x_0__proc/h_z/bnkd_xbar/z_${j}__m1rw_mask [expr $base_x+($j&1)*900] [expr $base_y+260*($j>>1)] 900 260
    }

    bsg_bound_creator g/n_0__ode/bm/y_0__x_0__proc/h_z/core/vscale/regfile/rf [expr $base_x] [expr $base_y+1375] 1000 225

    suppress_message MWUI-710
    bsg_bound_creator g/n_0__ode/bm/y_0__x_0__proc/h_z/bnkd_xbar $base_x $base_y  1800 520
#    bsg_bound_creator g/n_0__ode/bm/y_0__x_0__proc/h_z/core/vscale/md [expr $base_x+1800] [expr $base_y+550] 350 825
    bsg_bound_creator g/n_0__ode/bm/y_0__x_0__proc/h_z          [expr $base_x] [expr $base_y+550] 1800 825
    unsuppress_message MWUI-710

    bsg_bound_creator g/n_0__ode/bm/bmm/y_0__x_0__rtr  [expr $base_x+1000] [expr $base_y+1375] 350 350

}

bsg_place_comm_link 2880 2300 2880 2300 \
                    1810 1810 2510 2510 \
                    1969.94 2648.78 2777.77 3479.05

bsg_bound_creator g/n_0__ode/l2f 1930 1990 1800 450
bsg_bound_creator g/comm_link/fsb/fsb_node_0 1930 1990 1800 450

bsg_place_vcore 570 620

