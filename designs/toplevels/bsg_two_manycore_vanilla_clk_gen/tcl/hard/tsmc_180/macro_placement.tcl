proc bsg_place_macro { name x_origin y_origin orientation {x_cord 0} {y_cord 0} } {
    set obj [get_cells -all $name]
    set_attribute -quiet $obj origin [list $x_origin $y_origin ]
    set_attribute -quiet $obj orientation $orientation
    set_attribute -quiet $obj is_placed true
    set_attribute -quiet $obj is_fixed true
    set_attribute -quiet $obj is_soft_fixed false
    set_attribute -quiet $obj eco_status eco_reset

    set macro_bbox [get_attribute $obj bbox]
    set macro_ll_x [lindex [lindex $macro_bbox 0] 0]
    set macro_ll_y [lindex [lindex $macro_bbox 0] 1]
    set macro_ur_x [lindex [lindex $macro_bbox 1] 0]
    set macro_ur_y [lindex [lindex $macro_bbox 1] 1]

    set pr_blk_pad 10.0
    create_route_guide \
      -name preroute_block_$name \
      -coordinate [list [expr $macro_ll_x - $pr_blk_pad] [expr $macro_ll_y - $pr_blk_pad] [expr $macro_ur_x + $pr_blk_pad] [expr $macro_ur_y + $pr_blk_pad]] \
      -no_preroute_layers {METAL1} \
      -no_snap

    set place_blk_pad 10.0
		create_placement_blockage \
      -coordinate [list [expr $macro_ll_x - $place_blk_pad] [expr $macro_ll_y - $place_blk_pad] [expr $macro_ur_x + $place_blk_pad] [expr $macro_ll_y]] \
      -name "${name}_x_${x_cord}_y_${y_cord}_bottom_blockage"
		create_placement_blockage \
      -coordinate [list [expr $macro_ll_x - $place_blk_pad] [expr $macro_ur_y] [expr $macro_ur_x + $place_blk_pad] [expr $macro_ur_y + $place_blk_pad]] \
      -name "${name}_x_${x_cord}_y_${y_cord}_top_blockage"
		create_placement_blockage \
      -coordinate [list [expr $macro_ll_x - $place_blk_pad] [expr $macro_ll_y - $place_blk_pad] [expr $macro_ll_x] [expr $macro_ur_y + $place_blk_pad]] \
      -name "${name}_x_${x_cord}_y_${y_cord}_left_blockage"
		create_placement_blockage \
      -coordinate [list [expr $macro_ur_x] [expr $macro_ll_y - $place_blk_pad] [expr $macro_ur_x + $place_blk_pad] [expr $macro_ur_y + $place_blk_pad]] \
      -name "${name}_x_${x_cord}_y_${y_cord}_right_blockage"
}

proc bsg_place_manycore_tile_macros { prefix x_pos y_pos x_cord y_cord } {
    bsg_place_macro "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/vanilla_core/imem_0/macro_mem"      [expr 2045 - 480 + $x_cord] [expr 1393 - 767 + $y_cord] E $x_cord $y_cord
#   bsg_place_macro "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/bnkd_xbar/z_1__m1rw_mask/macro_mem" [expr 919 - 480 + $x_cord]  [expr 1410 - 767 + $y_cord] W $x_cord $y_cord
    bsg_place_macro "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/bnkd_xbar/z_0__m1rw_mask/macro_mem" [expr 918 - 480 + $x_cord]  [expr 790  - 767 + $y_cord] W $x_cord $y_cord

    bsg_place_macro "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/vanilla_core/rf_0/rf_mem/macro_mem0" [expr 1581 - 480 + $x_cord - 100] [expr 1350 - 767 + $y_cord] E $x_cord $y_cord
    bsg_place_macro "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/vanilla_core/rf_0/rf_mem/macro_mem1" [expr 1581 - 480 + $x_cord - 100] [expr 1000 - 767 + $y_cord] E $x_cord $y_cord
}

proc bsg_place_manycore_tile_macros_mirror { prefix x_pos y_pos x_cord y_cord } {
    set tile_width 2000
    bsg_place_macro "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/vanilla_core/imem_0/macro_mem"      [expr $tile_width -(2045 - 480) + $x_cord] [expr -594+1393 - 767 + $y_cord] W $x_cord $y_cord
#   bsg_place_macro "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/bnkd_xbar/z_1__m1rw_mask/macro_mem" [expr $tile_width -(930 - 480) + $x_cord]  [expr 600+1410 - 767 + $y_cord] E $x_cord $y_cord
    bsg_place_macro "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/bnkd_xbar/z_0__m1rw_mask/macro_mem" [expr $tile_width -(930 - 480) + $x_cord]  [expr 600+790  - 767 + $y_cord] E $x_cord $y_cord

    bsg_place_macro "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/vanilla_core/rf_0/rf_mem/macro_mem0" [expr $tile_width -(1581 - 480) + $x_cord + 100] [expr -200+1350 - 767 + $y_cord] W $x_cord $y_cord
    bsg_place_macro "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/vanilla_core/rf_0/rf_mem/macro_mem1" [expr $tile_width -(1581 - 480) + $x_cord + 100] [expr -200+1000 - 767 + $y_cord] W $x_cord $y_cord
}


proc bsg_place_manycore_tile_macros_square { prefix x_pos y_pos x_cord y_cord } {
    set tile_width 2000
    bsg_place_macro "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/vanilla_core/imem_0/macro_mem"      [expr $tile_width -(2045 - 480) + $x_cord ] [expr -594+1393 - 767 + $y_cord +590 -15] N $x_cord $y_cord
#   bsg_place_macro "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/bnkd_xbar/z_1__m1rw_mask/macro_mem" [expr $tile_width -(930 - 480) + $x_cord]  [expr 600+1410 - 767 + $y_cord] E $x_cord $y_cord
    bsg_place_macro "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/bnkd_xbar/z_0__m1rw_mask/macro_mem" [expr $tile_width -(930 - 480) + $x_cord - 510]  [expr 600+790  - 767 + $y_cord -15 ] N $x_cord $y_cord

    bsg_place_macro "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/vanilla_core/rf_0/rf_mem/macro_mem0" [expr $tile_width -(1581 - 480) + $x_cord + 100] [expr -200+1350 - 767 + $y_cord] W $x_cord $y_cord
    bsg_place_macro "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/vanilla_core/rf_0/rf_mem/macro_mem1" [expr $tile_width -(1581 - 480) + $x_cord + 100] [expr -200+1000 - 767 + $y_cord] W $x_cord $y_cord

    # add a placement blockage between rams
    set imem_bbox [get_attribute [get_cells -all "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/vanilla_core/imem_0/macro_mem"] bbox]
    set dmem_bbox [get_attribute [get_cells -all "${prefix}/y_${y_pos}__x_${x_pos}__proc/h_z/bnkd_xbar/z_0__m1rw_mask/macro_mem"] bbox]
		create_placement_blockage \
      -coordinate [list [lindex [lindex $imem_bbox 1] 0] [expr [lindex [lindex $imem_bbox 0] 1] - 10.0] [lindex [lindex $dmem_bbox 0] 0] [expr [lindex [lindex $dmem_bbox 1] 1] + 10.0]] \
      -name "square_core__x_${x_pos}__y_${y_pos}__blockage"
}



# this places the channel tunnel logic

set xDim [sizeof_collection [get_cells -hier *y_0__x_*__proc*]]
set yDim [sizeof_collection [get_cells -hier *y_*__x_0__proc*]]

puts "## BSG Detected X=${xDim} Y=${yDim} manycore"

if {$xDim==1} {
    bsg_place_macro "g/n_0__clnt_clnt/l2f/bct/bcti/b1_ntf/rof_0__psdlrg_fifo/big1p/mem_1srw/macro_mem" 2270 448 W
    bsg_place_macro "g/n_0__clnt_clnt/l2f/bct/bcti/b1_ntf/rof_1__psdlrg_fifo/big1p/mem_1srw/macro_mem" 2618 768.18 E
} else {
    bsg_place_macro "g/n_0__clnt_clnt/l2f/bct/bcti/b1_ntf/rof_0__psdlrg_fifo/big1p/mem_1srw/macro_mem" 1750 448 W
    bsg_place_macro "g/n_0__clnt_clnt/l2f/bct/bcti/b1_ntf/rof_1__psdlrg_fifo/big1p/mem_1srw/macro_mem" 2050 448 W
    bsg_place_macro "g/n_0__clnt_clnt/l2f/bct/bcti/b1_ntf/rof_2__psdlrg_fifo/big1p/mem_1srw/macro_mem" 2918 768.18 E
    bsg_place_macro "g/n_0__clnt_clnt/l2f/bct/bcti/b1_ntf/rof_3__psdlrg_fifo/big1p/mem_1srw/macro_mem" 3218 768.18 E

#    bsg_place_macro "g/n_0__clnt_clnt/l2f/bct/bcti/b1_ntf/rof_0__psdlrg_fifo/big1p/mem_1srw/macro_mem" 1870 448 W
#    bsg_place_macro "g/n_0__clnt_clnt/l2f/bct/bcti/b1_ntf/rof_1__psdlrg_fifo/big1p/mem_1srw/macro_mem" 2170 448 W
#    bsg_place_macro "g/n_0__clnt_clnt/l2f/bct/bcti/b1_ntf/rof_2__psdlrg_fifo/big1p/mem_1srw/macro_mem" 2718 754 E
#    bsg_place_macro "g/n_0__clnt_clnt/l2f/bct/bcti/b1_ntf/rof_3__psdlrg_fifo/big1p/mem_1srw/macro_mem" 3018 754 E

}


# loop and stamp out tiles
for {set x 0 } {$x < $xDim} {incr x} {
    for {set y 0 } {$y < $yDim} {incr y} {
        if {$yDim-1-$y >=3} {
            set y_gap 430
            puts "y_gap is ${y_gap}"
        } else {
            set y_gap 0
            puts "y_gap is ${y_gap}"
        }
        #                                           X Y  X    Y
        if {$x < 1} {
	    if {$yDim-1-$y == 2} {
		bsg_place_manycore_tile_macros_square  g/n_0__clnt_clnt/bm $x $y [expr 480+($x)*2050] [expr 777 + 625*($yDim-1-$y) + $y_gap]
	    } else {
		bsg_place_manycore_tile_macros         g/n_0__clnt_clnt/bm $x $y [expr 480+($x)*2050] [expr 777 + 625*($yDim-1-$y) + $y_gap]
	    }
        } else {
	    if {$yDim-1-$y == 2} {
		bsg_place_manycore_tile_macros_square  g/n_0__clnt_clnt/bm $x $y [expr 480+($x)*2050] [expr 777 + 625*($yDim-1-$y) + $y_gap]
	    } else {
		bsg_place_manycore_tile_macros_mirror  g/n_0__clnt_clnt/bm $x $y [expr 480+($x)*2050] [expr 777 + 625*($yDim-1-$y) + $y_gap]
		create_placement_blockage -coordinate [list [expr -40 + 480+($x)*2050] [expr 40+ 767 + $y_gap + 625*($yDim-1-$y)]  [expr 480+($x)*2050] [expr 40+580+ 767 + 625*($yDim-1-$y) + $y_gap]] -name "L1i_blockage${x}${y}"
	    }
	}
        #bsg_place_manycore_tile  g/n_0__clnt_clnt/bm 0 1
    }
    }
create_placement_blockage -coordinate {{449.710 1380.140} {930.850 1420.460}} -name L1_data_blockage


set_dont_touch_placement [all_macro_cells]




