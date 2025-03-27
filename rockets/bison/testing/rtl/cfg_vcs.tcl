# scripts for creating filelist and library
source $::env(BSG_COMMON_DIR)/tcl/bsg_vcs_create_filelist_library.tcl

# chip source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/include.tcl

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
