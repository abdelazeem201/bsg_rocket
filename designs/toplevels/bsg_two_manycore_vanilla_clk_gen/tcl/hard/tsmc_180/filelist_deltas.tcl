# process-customized files
#
# note: requires the following directories to be set
# bsg_ip_cores_dir
# bsg_chip_sub_design_dir
#

# list of files to replace
set asic_hard_filelist [join "
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_dff_gatestack.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_mux2_gatestack.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_muxi2_gatestack.v
  $bsg_ip_cores_dir/hard/bsg_mem/bsg_mem_2r1w_sync.v
  $bsg_ip_cores_dir/hard/bsg_mem/bsg_mem_1r1w.v
  $bsg_ip_cores_dir/hard/bsg_mem/bsg_mem_1rw_sync.v
  $bsg_ip_cores_dir/hard/bsg_mem/bsg_mem_1rw_sync_mask_write_byte.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_tiehi.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_tielo.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_clkbuf.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_dff.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_dff_en.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_dff_reset.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_dff_reset_en.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_and.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_buf.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_inv.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_nand.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_xor.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_xnor.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_nor3.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_mux.v
  $bsg_ip_cores_dir/hard/bsg_misc/bsg_reduce.v
  $bsg_ip_cores_dir/hard/bsg_clk_gen/bsg_clk_gen_osc.v
  $bsg_ip_cores_dir/hard/bsg_clk_gen/bsg_edge_balanced_mux4.v
"]

set NEW_SVERILOG_SOURCE_FILES [join "
"]

# list of NETLIST files to add
set NETLIST_SOURCE_FILES [join "
  $bsg_ip_cores_dir/hard/bsg_clk_gen/bsg_rp_clk_gen_fine_delay_tuner.v
  $bsg_ip_cores_dir/hard/bsg_clk_gen/bsg_rp_clk_gen_coarse_delay_tuner.v
  $bsg_ip_cores_dir/hard/bsg_clk_gen/bsg_rp_clk_gen_atomic_delay_tuner.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_rf_1r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_rf_w32_b32_2r1w.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_dff_nreset_s1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_dff_s1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_dff_s2.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_dff_s4.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/memory/bsg_rp_tsmc_250_dff_nreset_en_s2.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_mux_w2_b32.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_mux_w2_b33.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_TIEHI.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_TIELO.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_CLKBUF.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_MX2X1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_AND2X1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_NAND2X1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_XOR2X1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_XNOR2X1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_NOR3X1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_MXI4X4.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_MXI2X1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_CLKINVX16.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_BUFX8.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_INVX8.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_DFFNRX4.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_DFFX4.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_EDFF.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_DFFRX4.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_DFFRX2.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_DFFX1.v
  $bsg_chip_sub_design_dir/sources/ip/bsg/bsg_misc/bsg_rp_tsmc_250_reduce.v
"]
