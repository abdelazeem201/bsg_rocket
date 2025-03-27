proc bsg_highlight_rocket {} {
    gui_change_highlight -color light_blue -collection [get_flat_cells -quiet {*FPU*}]
    gui_change_highlight -color green -collection [get_flat_cells -quiet {*dcache*}]
    gui_change_highlight -color yellow -collection [get_flat_cells -quiet {*icache*}]
    gui_change_highlight -color orange -collection [get_flat_cells -quiet {*comm_link*}]
    gui_change_highlight -color light_orange -collection [get_flat_cells -quiet {*uncore*}]
    gui_change_highlight -color light_red -collection [get_flat_cells -quiet {*/core*}]

    gui_change_highlight -color purple -collection [get_flat_cells -quiet {*rocket/Queue*}]
#    gui_change_highlight -color red -collection [get_flat_cells -quiet {*bdiom*}]
#    gui_change_highlight -color blue -collection [get_flat_cells -quiet {*dmem_cache*}]


#    gui_change_highlight -color light_green -collection [get_flat_cells -quiet {*proc/rf*}]
#    gui_change_highlight -color red -collection [get_flat_cells -quiet {*proc/fu*}]

#    gui_change_highlight -color light_red -collection [get_flat_cells -quiet {*int_divider*}]
#    gui_change_highlight -color yellow -collection [get_flat_cells -quiet {*hp_dynamic_network*}]
}
