
set name "mem1/macro_mem"
set obj [get_cells -all $name]
set_attribute -quiet $obj origin {2210 2285}
set_attribute -quiet $obj is_placed true
set_attribute -quiet $obj is_fixed true
set_attribute -quiet $obj is_soft_fixed false
set_attribute -quiet $obj eco_status eco_reset
set_keepout_margin -type hard -outer {5 5 5 5} $obj

set macro_bbox [get_attribute $obj bbox]
set macro_ll_x [lindex [lindex $macro_bbox 0] 0]
set macro_ll_y [lindex [lindex $macro_bbox 0] 1]
set macro_ur_x [lindex [lindex $macro_bbox 1] 0]
set macro_ur_y [lindex [lindex $macro_bbox 1] 1]
set ex_macro_ll_x [expr $macro_ll_x - 5]
set ex_macro_ll_y [expr $macro_ll_y - 5]
set ex_macro_ur_x [expr $macro_ur_x + 5]
set ex_macro_ur_y [expr $macro_ur_y + 5]

create_route_guide \
  -name preroute_block_$name \
  -coordinate [list [list $ex_macro_ll_x $ex_macro_ll_y] [list $ex_macro_ur_x $ex_macro_ur_y]] \
  -no_preroute_layers {METAL1} \
  -no_snap

set_dont_touch_placement [all_macro_cells]

