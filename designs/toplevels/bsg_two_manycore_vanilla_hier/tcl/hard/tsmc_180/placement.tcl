
set xDim [sizeof_collection [get_cells -hier *y_0__x_*__proc*]]
set yDim [sizeof_collection [get_cells -hier *y_*__x_0__proc*]]

puts "## BSG Detected X=${xDim} Y=${yDim} manycore"

if {$xDim == 1} {
    bsg_place_comm_link_rotate 2950 [expr $bsg_max_y-250] 2950 $bsg_min_y 1525 [expr $bsg_max_y-250] 1525 $bsg_min_y \
       	                       3475 [expr $bsg_max_y-95]  3475 $bsg_min_y 1074 [expr $bsg_max_y-95]  1074 $bsg_min_y \
                               [expr $bsg_max_x-350] 3383 [expr $bsg_max_x-350] 2030 $bsg_min_x 3383 $bsg_min_x 2030 \
  	                       1969.94 2648.78 2777.77 3479.05
} else {
    bsg_place_comm_link_rotate 2950 [expr $bsg_max_y-250] 3500 $bsg_min_y 1525 [expr $bsg_max_y-250] 1015 $bsg_min_y \
       	                       3475 [expr $bsg_max_y-95]  3950 $bsg_min_y 1074 [expr $bsg_max_y-95]  564 $bsg_min_y \
                               [expr $bsg_max_x-350] 2785 [expr $bsg_max_x-350] 2030 $bsg_min_x 2785 $bsg_min_x 2030 \
  	                       1969.94 2648.78 2777.77 3479.05

#    bsg_place_comm_link_rotate 2950 [expr $bsg_max_y-250] 3300 $bsg_min_y 1525 [expr $bsg_max_y-250] 1125 $bsg_min_y \
#       	                       3475 [expr $bsg_max_y-95]  3750 $bsg_min_y 1074 [expr $bsg_max_y-95]  674 $bsg_min_y \
#                               [expr $bsg_max_x-350] 3383 [expr $bsg_max_x-350] 2030 $bsg_min_x 3383 $bsg_min_x 2030 \
#  	                       1969.94 2648.78 2777.77 3479.05

}

#bsg_place_comm_link_guts 2150 2150 1
bsg_place_comm_link_guts 2150 2100 0

#bsg_place_comm_link 2880 2300 2880 2300 \
#                    1810 1810 2510 2510 \
#                    1969.94 2648.78 2777.77 3479.05



# here is the verilog hierarchy
#
# bm                 = bsg_manycore
#   bmm              = bsg_manycore_mesh
#     y_0__x_0__rtr  = bsg_manycore_mesh_node
#     y_1__x_0__rtr  = " "
#     link           = bsg_mesh_stitch (just buffers --> maybe just collapse this level of the hierarchy in synthesis?)
#   y_0__x_0_proc = bsg_manycore_hetero_socket
#   y_1__x_0_proc = " "
#

proc bsg_bound_manycore_tile { prefix x_pos y_pos x_cord y_cord } {

    bsg_bound_creator $prefix/y_${y_pos}__x_${x_pos}__proc/h_z/bnkd_xbar  [expr $x_cord - 480 + 915+10] [expr $y_cord - 767 + 788] 172 591

    bsg_bound_creator  $prefix/y_${y_pos}__x_${x_pos}__proc/h_z/endp/   [expr $x_cord - 480 + 1539 -30] [expr $y_cord - 767 + 789] 529  400
    bsg_bound_creator  $prefix/bmm/y_${y_pos}__x_${x_pos}__rtr          [expr $x_cord - 480 + 1539 -30] [expr $y_cord - 767 + 789] 529  400
    bsg_bound_creator  $prefix/y_${y_pos}__x_${x_pos}__proc             [expr $x_cord - 480 + 915 +10 ] [expr $y_cord - 767 + 789] 1113 591

}


proc bsg_bound_manycore_tile_reverse { prefix x_pos y_pos x_cord y_cord } {

    bsg_bound_creator $prefix/y_${y_pos}__x_${x_pos}__proc/h_z/bnkd_xbar  [expr 955+ $x_cord - 480 + 934 -10] [expr $y_cord - 767 + 788] 172 591

    bsg_bound_creator  $prefix/y_${y_pos}__x_${x_pos}__proc/h_z/endp/   [expr -600 + $x_cord - 480 + 1539+10] [expr $y_cord - 767 + 789] 529  400
    bsg_bound_creator  $prefix/bmm/y_${y_pos}__x_${x_pos}__rtr          [expr -600 + $x_cord - 480 + 1539+10] [expr $y_cord - 767 + 789] 529  400
    bsg_bound_creator  $prefix/y_${y_pos}__x_${x_pos}__proc             [expr $x_cord - 480 + 915 +35 ] [expr $y_cord - 767 + 788] 1103 591

}

proc bsg_bound_manycore_tile_square { prefix x_pos y_pos x_cord y_cord } {

#    bsg_bound_creator $prefix/y_${y_pos}__x_${x_pos}__proc/h_z/bnkd_xbar  [expr $x_cord - 480 + 915+10] [expr $y_cord - 767 + 788] 172 591

    bsg_bound_creator  $prefix/y_${y_pos}__x_${x_pos}__proc/h_z/endp/   [expr $x_cord - 480 + 1539 -30] [expr $y_cord - 767 + 789] 529  400
    bsg_bound_creator  $prefix/bmm/y_${y_pos}__x_${x_pos}__rtr          [expr $x_cord - 480 + 1539 -30] [expr $y_cord - 767 + 789] 529  400
    bsg_bound_creator  $prefix/y_${y_pos}__x_${x_pos}__proc             [expr $x_cord - 480 + 915 +10 ] [expr $y_cord - 767 + 789] 1113 591

}


proc bsg_bound_manycore_tile_square_reverse { prefix x_pos y_pos x_cord y_cord } {

#    bsg_bound_creator $prefix/y_${y_pos}__x_${x_pos}__proc/h_z/bnkd_xbar  [expr $x_cord - 480 + 915+10] [expr $y_cord - 767 + 788] 172 591
    bsg_bound_creator  $prefix/y_${y_pos}__x_${x_pos}__proc/h_z/endp/   [expr -600 + $x_cord - 480 + 1539+10] [expr $y_cord - 767 + 789] 529  400
    bsg_bound_creator  $prefix/bmm/y_${y_pos}__x_${x_pos}__rtr          [expr -600 + $x_cord - 480 + 1539+10] [expr $y_cord - 767 + 789] 529  400

    bsg_bound_creator  $prefix/y_${y_pos}__x_${x_pos}__proc             [expr $x_cord - 480 + 915 +10 ] [expr $y_cord - 767 + 789] 1113 591
}



# bound the channel tunnel

if {$xDim == 1} {
bsg_bound_creator_abs g/n_0__clnt_clnt/l2f 2274 432 2616 782
} else {
#    bsg_bound_creator_abs g/n_0__clnt_clnt/l2f 2174 432 2716 782
    bsg_bound_creator_abs g/n_0__clnt_clnt/l2f 2074 432 2906 760
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

	#                                           X   Y  X    Y
	if {$x < 1} {
	    if {$yDim-1-$y == 2} {
		bsg_bound_manycore_tile_square g/n_0__clnt_clnt/bm $x $y [expr 480 + 2025*($x)] [expr $y_gap+786 + 625*($yDim-1-$y)]
	    } else {
		bsg_bound_manycore_tile g/n_0__clnt_clnt/bm $x $y [expr 480 + 2025*($x)] [expr $y_gap+786 + 625*($yDim-1-$y)]
	    }
	} else {
	    if {$yDim-1-$y == 2} {
		bsg_bound_manycore_tile_square_reverse g/n_0__clnt_clnt/bm $x $y [expr 480 + 2025*($x)] [expr $y_gap+786 + 625*($yDim-1-$y)]
	    } else {
		bsg_bound_manycore_tile_reverse g/n_0__clnt_clnt/bm $x $y [expr 480 + 2025*($x)] [expr $y_gap+ 786 + 625*($yDim-1-$y)]
	    }
	}
    }
}
#bsg_bound_creator g/comm_link/fsb/fsb_node_0 1930 1990 1800 450

# PLL Voltage Area Movebounds
#
#bsg_place_clk_gen clk_gen_core_inst 515 2554
#bsg_place_clk_gen clk_gen_iom_inst  515 2438.2
