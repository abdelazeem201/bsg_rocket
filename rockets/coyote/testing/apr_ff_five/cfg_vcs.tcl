# scripts for creating filelist and library
source $::env(BSG_COMMON_DIR)/tcl/bsg_vcs_create_filelist_library.tcl

# testing source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/include.tcl

# pdk filelist
set pdk_files [join "
  $::env(ARM_STD_CELLS_V)
  $::env(ARM_IO_CELLS_V)
  $::env(ARM_PMK_CELLS_V)
  $::env(ALL_MEM_V)
"]

bsg_create_filelist $::env(PDK_FILELIST) \
                    $pdk_files
bsg_create_library $::env(PDK_LIB_NAME) \
                   $::env(PDK_LIB) \
                   $pdk_files \
                   ""

# manycore filelist
set manycore_files [join "
  $::env(CHIP_DIR)/blocks/manycore_hierarchical/export/bsg_manycore_tile.vcs.v
  $::env(CHIP_DIR)/blocks/manycore_hierarchical/export/bsg_manycore.vcs.v
"]

bsg_create_filelist $::env(MANYCORE_FILELIST) \
                    $manycore_files

bsg_create_library $::env(MANYCORE_LIB_NAME) \
                   $::env(MANYCORE_LIB) \
                   $manycore_files \
                   ""

# dcdc_manycore filelist
set dcdc_manycore_files [join "
  $::env(CHIP_DIR)/blocks/dcdc_manycore/export/bsg_manycore_tile_1024_1_1024_1_3_32_20_0_00000000_00000000_0.vcs.v
  $::env(CHIP_DIR)/blocks/dcdc_manycore/export/dcdc_manycore.vcs.v
"]

bsg_create_filelist $::env(DCDC_MANYCORE_FILELIST) \
                    $dcdc_manycore_files

bsg_create_library $::env(DCDC_MANYCORE_LIB_NAME) \
                   $::env(DCDC_MANYCORE_LIB) \
                   $dcdc_manycore_files \
                   ""

# coyote filelist
set coyote_files [join "
  $::env(CHIP_DIR)/blocks/coyote_node/export/bsg_rocket_node_client_rocc.vcs.v
"]

bsg_create_filelist $::env(COYOTE_FILELIST) \
                    $coyote_files

bsg_create_library $::env(COYOTE_LIB_NAME) \
                   $::env(COYOTE_LIB) \
                   $coyote_files \
                   ""

# bnn filelist
set bnn_files [join "
  $::env(CHIP_DIR)/blocks/bnn/export/bsg_rocket_accelerator_bnn.vcs.v
"]

bsg_create_filelist $::env(BNN_FILELIST) \
                    $bnn_files

bsg_create_library $::env(BNN_LIB_NAME) \
                   $::env(BNN_LIB) \
                   $bnn_files \
                   ""

# chip filelist
set bsg_chip_files [join "
  $::env(CHIP_DIR)/results/innovus/bsg_chip.vcs.v
  $::env(CHIP_DIR)/../bsg_designs/toplevels/bsg_three_certus_soc/v/analog/pll.v
  $::env(CHIP_DIR)/../bsg_designs/toplevels/bsg_three_certus_soc/v/analog/dc_dc_ldo.v
"]

bsg_create_filelist $::env(BSG_CHIP_FILELIST) \
                    $bsg_chip_files

bsg_create_library $::env(BSG_CHIP_LIB_NAME) \
                   $::env(BSG_CHIP_LIB) \
                   $bsg_chip_files \
                   ""

# testing filelist
bsg_create_filelist $::env(BSG_TEST_FILELIST) \
                    $TESTING_SOURCE_FILES

# testing library
bsg_create_library $::env(BSG_TEST_LIB_NAME) \
                   $::env(BSG_TEST_LIB) \
                   $TESTING_SOURCE_FILES \
                   $TESTING_INCLUDE_PATHS

