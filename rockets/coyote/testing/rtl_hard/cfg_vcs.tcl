# scripts for creating filelist and library
source $::env(BSG_COMMON_DIR)/tcl/bsg_vcs_create_filelist_library.tcl

# chip source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/include.tcl

set bsg_chip_sub_design_dir $::env(BSG_CHIP_SUB_DESIGN_DIR)
source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hard/$::env(BSG_DESIGNS_HARD_TARGET)/filelist_deltas.tcl

proc bsg_get_module_name {module_path} {

  regexp {[A-Za-z0-9_]+\.v} $module_path module_name

  return $module_name
}

set asic_hard_module_list [list]

foreach f $asic_hard_filelist {
  lappend asic_hard_module_list [bsg_get_module_name $f]
}

foreach f $SVERILOG_SOURCE_FILES {

  set asic_module_name [bsg_get_module_name $f]
  set idx [lsearch $asic_hard_module_list $asic_module_name]

  # replacement occurs here
  if {$idx == -1} {
    lappend tmp_list $f
  } else {
    lappend tmp_list [lindex $asic_hard_filelist $idx]
  }

}

set SVERILOG_SOURCE_FILES [concat $tmp_list $NEW_SVERILOG_SOURCE_FILES]
set SVERILOG_SOURCE_FILES [concat $SVERILOG_SOURCE_FILES $NETLIST_SOURCE_FILES]

# testing source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/include.tcl

# chip filelist
bsg_create_filelist $::env(BSG_CHIP_FILELIST) \
                    $SVERILOG_SOURCE_FILES

# chip library
bsg_create_library $::env(BSG_CHIP_LIB_NAME) \
                   $::env(BSG_CHIP_LIB) \
                   $SVERILOG_SOURCE_FILES \
                   $SVERILOG_INCLUDE_PATHS

# testing filelist
bsg_create_filelist $::env(BSG_TEST_FILELIST) \
                    $TESTING_SOURCE_FILES

# testing library
bsg_create_library $::env(BSG_TEST_LIB_NAME) \
                   $::env(BSG_TEST_LIB) \
                   $TESTING_SOURCE_FILES \
                   $TESTING_INCLUDE_PATHS
