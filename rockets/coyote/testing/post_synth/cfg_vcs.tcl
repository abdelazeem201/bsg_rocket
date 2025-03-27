# scripts for creating filelist and library
source $::env(BSG_COMMON_DIR)/tcl/bsg_vcs_create_filelist_library.tcl

# testing source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/include.tcl

# testing filelist
bsg_create_filelist $::env(BSG_TEST_FILELIST) \
                    $TESTING_SOURCE_FILES

# testing library
bsg_create_library $::env(BSG_TEST_LIB_NAME) \
                   $::env(BSG_TEST_LIB) \
                   $TESTING_SOURCE_FILES \
                   $TESTING_INCLUDE_PATHS
