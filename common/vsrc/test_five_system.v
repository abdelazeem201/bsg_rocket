`include "bsg_rocket_pkg.vh"
`include "bsg_fsb_pkg.v"

module test_five_system
  import bsg_rocket_pkg::*;
  import bsg_fsb_pkg::*;
# (parameter num_rockets_gp=5)
  (input                       core_clk_i
  ,input                       io_clk_i
  ,input                       manycore_clk_i

  // resets
  ,input                       reset
  ,input                       gateway_async_reset_i
  ,output                      boot_done_o

  // host in
  ,input  [num_rockets_gp-1:0] host_valid_i
  ,input            bsg_host_t host_data_i [num_rockets_gp-1:0]
  ,output [num_rockets_gp-1:0] host_ready_o
  // host out
  ,output [num_rockets_gp-1:0] host_valid_o
  ,output           bsg_host_t host_data_o [num_rockets_gp-1:0]
  ,input  [num_rockets_gp-1:0] host_ready_i

  // aw out
  ,output [num_rockets_gp-1:0] nasti_aw_valid_o
  ,output      bsg_nasti_a_pkt nasti_aw_data_o [num_rockets_gp-1:0]
  ,input  [num_rockets_gp-1:0] nasti_aw_ready_i
  // w out
  ,output [num_rockets_gp-1:0] nasti_w_valid_o
  ,output      bsg_nasti_w_pkt nasti_w_data_o [num_rockets_gp-1:0]
  ,input  [num_rockets_gp-1:0] nasti_w_ready_i
  // b out
  ,input  [num_rockets_gp-1:0] nasti_b_valid_i
  ,input       bsg_nasti_b_pkt nasti_b_data_i [num_rockets_gp-1:0]
  ,output [num_rockets_gp-1:0] nasti_b_ready_o
  // ar out
  ,output [num_rockets_gp-1:0] nasti_ar_valid_o
  ,output      bsg_nasti_a_pkt nasti_ar_data_o [num_rockets_gp-1:0]
  ,input  [num_rockets_gp-1:0] nasti_ar_ready_i
  // r in
  ,input  [num_rockets_gp-1:0] nasti_r_valid_i
  ,input       bsg_nasti_r_pkt nasti_r_data_i [num_rockets_gp-1:0]
  ,output [num_rockets_gp-1:0] nasti_r_ready_o);

  localparam num_channels_p=4;
  localparam channel_width_p=8;
  localparam ring_bytes_p=10;
  localparam ring_width_p=ring_bytes_p*channel_width_p;

  wire host_reset;
  wire chip_reset;

  wire  [num_channels_p-1:0] gw_link_clk;
  wire  [num_channels_p-1:0] gw_link_valid;
  wire [channel_width_p-1:0] gw_link_data [num_channels_p-1:0];
  wire  [num_channels_p-1:0] chip_link_token;

  wire  [num_channels_p-1:0] chip_link_clk;
  wire  [num_channels_p-1:0] chip_link_valid;
  wire [channel_width_p-1:0] chip_link_data [num_channels_p-1:0];
  wire  [num_channels_p-1:0] gw_link_token;

  wire                    gw_v;
  wire [ring_width_p-1:0] gw_data;
  wire                    gw_yumi;

  wire                    zb_v;
  wire [ring_width_p-1:0] zb_data;
  wire                    zb_ready;

  bsg_zedboard_chip #
    (.num_rockets_gp(num_rockets_gp))
  zb
    (.clk_i(core_clk_i)
    ,.reset_i(host_reset)
    ,.boot_done_o(boot_done_o)
    // host in
    ,.host_valid_i(host_valid_i)
    ,.host_data_i(host_data_i)
    ,.host_ready_o(host_ready_o)
    // host out
    ,.host_valid_o(host_valid_o)
    ,.host_data_o(host_data_o)
    ,.host_ready_i(host_ready_i)
    // aw out
    ,.nasti_aw_valid_o(nasti_aw_valid_o)
    ,.nasti_aw_data_o(nasti_aw_data_o)
    ,.nasti_aw_ready_i(nasti_aw_ready_i)
    // w out
    ,.nasti_w_valid_o(nasti_w_valid_o)
    ,.nasti_w_data_o(nasti_w_data_o)
    ,.nasti_w_ready_i(nasti_w_ready_i)
    // b in
    ,.nasti_b_valid_i(nasti_b_valid_i)
    ,.nasti_b_data_i(nasti_b_data_i)
    ,.nasti_b_ready_o(nasti_b_ready_o)
    // ar out
    ,.nasti_ar_valid_o(nasti_ar_valid_o)
    ,.nasti_ar_data_o(nasti_ar_data_o)
    ,.nasti_ar_ready_i(nasti_ar_ready_i)
    // r in
    ,.nasti_r_valid_i(nasti_r_valid_i)
    ,.nasti_r_data_i(nasti_r_data_i)
    ,.nasti_r_ready_o(nasti_r_ready_o)
    // in
    ,.v_i(gw_v)
    ,.data_i(gw_data)
    ,.yumi_o(gw_yumi)
    // out
    ,.v_o(zb_v)
    ,.data_o(zb_data)
    ,.ready_i(zb_ready));

  bsg_gateway_chip gw
    (.core_clk_i(core_clk_i)
    ,.io_master_clk_i(io_clk_i)
    ,.async_reset_i(gateway_async_reset_i)
    // in
    ,.v_i(zb_v)
    ,.data_i(zb_data)
    ,.ready_o(zb_ready)
    // out
    ,.v_o(gw_v)
    ,.data_o(gw_data)
    ,.yumi_i(gw_yumi)
    // ctrl
    ,.p_chip_reset_o(chip_reset)
    ,.p_host_reset_o(host_reset)
    // in
    ,.p_sdo_sclk_i(chip_link_clk)
    ,.p_sdo_ncmd_i(chip_link_valid)
    ,.p_sdo_A_data_i(chip_link_data[0])
    ,.p_sdo_B_data_i(chip_link_data[1])
    ,.p_sdo_C_data_i(chip_link_data[2])
    ,.p_sdo_D_data_i(chip_link_data[3])
    ,.p_sdo_token_o(gw_link_token)
    // out
    ,.p_sdi_sclk_o(gw_link_clk)
    ,.p_sdi_ncmd_o(gw_link_valid)
    ,.p_sdi_A_data_o(gw_link_data[0])
    ,.p_sdi_B_data_o(gw_link_data[1])
    ,.p_sdi_C_data_o(gw_link_data[2])
    ,.p_sdi_D_data_o(gw_link_data[3])
    ,.p_sdi_token_i(chip_link_token));

  bsg_chip chip
    `ifdef BSG_TWO_PINOUT
      (.p_PLL_CLK_i(core_clk_i)
      ,.p_misc_L_4_i(io_clk_i)
      ,.p_misc_L_5_i(manycore_clk_i)
      ,.p_reset_i(chip_reset)
      // in
      ,.p_sdi_sclk_i(gw_link_clk)
      ,.p_sdi_ncmd_i(gw_link_valid)
      ,.p_sdi_A_data_i(gw_link_data[0])
      ,.p_sdi_B_data_i(gw_link_data[1])
      ,.p_sdi_C_data_i(gw_link_data[2])
      ,.p_sdi_D_data_i(gw_link_data[3])
      ,.p_sdi_token_o(chip_link_token)
      // out
      ,.p_sdo_sclk_o(chip_link_clk)
      ,.p_sdo_ncmd_o(chip_link_valid)
      ,.p_sdo_A_data_o(chip_link_data[0])
      ,.p_sdo_B_data_o(chip_link_data[1])
      ,.p_sdo_C_data_o(chip_link_data[2])
      ,.p_sdo_D_data_o(chip_link_data[3])
      ,.p_sdo_token_i(gw_link_token));

    `elsif BSG_THREE_PINOUT
      (.p_PLL_SECTION_1_REF_i(core_clk_i)
      ,.p_PLL_SECTION_2_REF_i(io_clk_i)
      ,.p_PLL_SECTION_3_REF_i(manycore_clk_i)
      ,.p_reset_i(chip_reset)

      ,.p_PLL_1_CLK_BKP_i(core_clk_i)
      ,.p_PLL_1_CLK_SEL_i(1'b1)

      ,.p_PLL_2_CLK_BKP_i(io_clk_i)
      ,.p_PLL_2_CLK_SEL_i(1'b1)

      ,.p_PLL_3_CLK_BKP_i(manycore_clk_i)
      ,.p_PLL_3_CLK_SEL_i(1'b1)

      // in
      ,.p_sdi_sclk_i(gw_link_clk)
      ,.p_sdi_ncmd_i(gw_link_valid)
      ,.p_sdi_A_data_i(gw_link_data[0])
      ,.p_sdi_B_data_i(gw_link_data[1])
      ,.p_sdi_C_data_i(gw_link_data[2])
      ,.p_sdi_D_data_i(gw_link_data[3])
      ,.p_sdi_token_o(chip_link_token)
      // out
      ,.p_sdo_sclk_o(chip_link_clk)
      ,.p_sdo_ncmd_o(chip_link_valid)
      ,.p_sdo_A_data_o(chip_link_data[0])
      ,.p_sdo_B_data_o(chip_link_data[1])
      ,.p_sdo_C_data_o(chip_link_data[2])
      ,.p_sdo_D_data_o(chip_link_data[3])
      ,.p_sdo_token_i(gw_link_token));

    `else
      // Force compiler error
      Unkown or undefined pinout!

    `endif

endmodule
