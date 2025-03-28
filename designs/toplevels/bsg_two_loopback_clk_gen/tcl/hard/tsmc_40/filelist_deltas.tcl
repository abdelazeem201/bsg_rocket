# TSMC_250 customization for bsg_two_loopback
#
# note: requires the following directories to be set
# bsg_ip_cores_dir
# bsg_chip_sub_design_dir
#

# list of files to replace
set asic_hard_filelist [join "
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_clk_gen/bsg_clk_gen_osc.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_clk_gen/bsg_edge_balanced_mux4.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_misc/bsg_dff_en.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_misc/bsg_dff_reset_en.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_misc/bsg_dff.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_misc/bsg_dff_reset.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_misc/bsg_mux.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_misc/bsg_and.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_misc/bsg_tiehi.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_misc/bsg_tielo.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_misc/bsg_buf.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_misc/bsg_clkbuf.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_misc/bsg_nand.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_misc/bsg_xor.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_misc/bsg_xnor.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_misc/bsg_nor3.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_misc/bsg_reduce.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_mem/bsg_mem_1r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_dff_gatestack.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_muxi2_gatestack.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_mux2_gatestack.v
"]

set NEW_SVERILOG_SOURCE_FILES [join "
"]

# list of NETLIST files to add
set NETLIST_SOURCE_FILES [join "
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_clk_gen/bsg_rp_clk_gen_fine_delay_tuner.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_clk_gen/bsg_rp_clk_gen_coarse_delay_tuner.v
  $bsg_ip_cores_dir/hard/tsmc_40/bsg_clk_gen/bsg_rp_clk_gen_atomic_delay_tuner.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_40_dff_s1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_MX2X1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_TIEHI.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_TIELO.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_AND2X1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_NAND2X1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_XOR2X1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_XNOR2X1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_NOR3X1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_MXI4X4.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_MXI2X1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_CLKINVX16.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_BUFX8.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_CLKBUF.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_DFFNRX4.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_DFFX4.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_EDFF.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_DFFRX4.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_DFFRX2.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_DFFX1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_40_reduce.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_40_dff_s4.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_40_dff_s2.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_40_dff_nreset_en_s2.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_40_rf_1r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_40_rf_w32_b32_2r1w.v
"]
