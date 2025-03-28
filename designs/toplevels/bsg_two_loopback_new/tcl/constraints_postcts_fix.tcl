remove_clock_uncertainty [all_clocks]
remove_propagated_clock  [get_attribute [all_clocks] sources]
set_propagated_clock [remove_from_collection [all_clocks] [get_clocks *_cdc]]
