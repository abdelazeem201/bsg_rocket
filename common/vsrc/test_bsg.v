`include "bsg_rocket_pkg.vh"
`include "bsg_fsb_pkg.v"

module test_bsg
  import bsg_rocket_pkg::*;
  import bsg_fsb_pkg::*;
  (input core_clk_i
  ,input io_clk_i
  ,input manycore_clk_i

  // resets
  ,input reset
  ,input gateway_async_reset_i
  ,output boot_done_o

  // BEGIN host client

  // host in
  ,output        io_host_in_ready
  ,input         io_host_in_valid
  ,input  [15:0] io_host_in_bits
  // host out
  ,input         io_host_out_ready
  ,output        io_host_out_valid
  ,output [15:0] io_host_out_bits

  // END host client

  // BEGIN nasti(axi) master

  // aw out
  ,input         io_mem_0_aw_ready
  ,output        io_mem_0_aw_valid
  ,output [31:0] io_mem_0_aw_bits_addr
  ,output  [7:0] io_mem_0_aw_bits_len
  ,output  [2:0] io_mem_0_aw_bits_size
  ,output  [1:0] io_mem_0_aw_bits_burst
  ,output        io_mem_0_aw_bits_lock
  ,output  [3:0] io_mem_0_aw_bits_cache
  ,output  [2:0] io_mem_0_aw_bits_prot
  ,output  [3:0] io_mem_0_aw_bits_qos
  ,output  [3:0] io_mem_0_aw_bits_region
  ,output  [5:0] io_mem_0_aw_bits_id
  // w out
  ,input         io_mem_0_w_ready
  ,output        io_mem_0_w_valid
  ,output [63:0] io_mem_0_w_bits_data
  ,output        io_mem_0_w_bits_last
  ,output  [7:0] io_mem_0_w_bits_strb
  // b out
  ,output        io_mem_0_b_ready
  ,input         io_mem_0_b_valid
  ,input   [1:0] io_mem_0_b_bits_resp
  ,input   [5:0] io_mem_0_b_bits_id
  // ar out
  ,input         io_mem_0_ar_ready
  ,output        io_mem_0_ar_valid
  ,output [31:0] io_mem_0_ar_bits_addr
  ,output  [7:0] io_mem_0_ar_bits_len
  ,output  [2:0] io_mem_0_ar_bits_size
  ,output  [1:0] io_mem_0_ar_bits_burst
  ,output        io_mem_0_ar_bits_lock
  ,output  [3:0] io_mem_0_ar_bits_cache
  ,output  [2:0] io_mem_0_ar_bits_prot
  ,output  [3:0] io_mem_0_ar_bits_qos
  ,output  [3:0] io_mem_0_ar_bits_region
  ,output  [5:0] io_mem_0_ar_bits_id
  // r in
  ,output        io_mem_0_r_ready
  ,input         io_mem_0_r_valid
  ,input   [1:0] io_mem_0_r_bits_resp
  ,input  [63:0] io_mem_0_r_bits_data
  ,input         io_mem_0_r_bits_last
  ,input   [5:0] io_mem_0_r_bits_id

  // END nasti(axi) master

  // BEGIN unused

  ,output        io_mem_0_aw_bits_user
  ,output        io_mem_0_w_bits_user
  ,input         io_mem_0_b_bits_user
  ,output        io_mem_0_ar_bits_user
  ,input         io_mem_0_r_bits_user
  ,output        io_host_clk
  ,output        io_host_clk_edge
  ,output        io_host_debug_stats_csr
  ,input         io_mem_backup_ctrl_en
  ,input         io_mem_backup_ctrl_in_valid
  ,input         io_mem_backup_ctrl_out_ready
  ,output        io_mem_backup_ctrl_out_valid
  ,input         init);

  // END unused

  // Simulation notes:
  // 1. Unused inputs and outputs tie to ground
  // 2. The host-interface uses the same global clock or (io_host_clk = core_clk_i),
  //    in order to make this work, the UseBackupMemoryPort must be set to
  //    false so the SlowIO module inside rocketchip is not created. This is
  //    set in rocket-chip/src/main/scala/Configs.scala. Also, this io_host_clock
  //    is being used by the vcs-pli-htif module, therefore if this is not set
  //    simulation wont work

  assign io_host_clk = core_clk_i;

  assign io_host_debug_stats_csr      = 1'b0;
  assign io_mem_backup_ctrl_out_valid = 1'b0;
  assign io_mem_0_aw_bits_user        = 1'b0;
  assign io_mem_0_w_bits_user         = 1'b0;
  assign io_mem_0_ar_bits_user        = 1'b0;

  localparam num_channels_p=4;
  localparam channel_width_p=8;
  localparam ring_bytes_p=10;
  localparam ring_width_p=ring_bytes_p*channel_width_p;

  wire gw_async_reset;

  wire [num_channels_p-1:0] gw_link_clk;
  wire [num_channels_p-1:0] gw_link_valid;
  wire [channel_width_p-1:0] gw_link_data [num_channels_p-1:0];
  wire [num_channels_p-1:0] chip_link_token;

  wire [num_channels_p-1:0] chip_link_clk;
  wire [num_channels_p-1:0] chip_link_valid;
  wire [channel_width_p-1:0] chip_link_data [num_channels_p-1:0];
  wire [num_channels_p-1:0] gw_link_token;

  // rocketTestHarness waits for 1, then waits for 0 to finally deassert reset
  wire boot_done;
  wire gw_core_reset;

  wire       gw_host_in_valid;
  bsg_host_t gw_host_in_data;
  wire       gw_host_in_ready;

  wire       gw_host_out_valid;
  bsg_host_t gw_host_out_data;
  wire       gw_host_out_ready;

  wire            gw_aw_valid;
  bsg_nasti_a_pkt gw_aw_data;
  wire            gw_aw_ready;

  wire            gw_w_valid;
  bsg_nasti_w_pkt gw_w_data;
  wire            gw_w_ready;

  wire            gw_b_valid;
  bsg_nasti_b_pkt gw_b_data;
  wire            gw_b_ready;

  wire            gw_ar_valid;
  bsg_nasti_a_pkt gw_ar_data;
  wire            gw_ar_ready;

  wire            gw_r_valid;
  bsg_nasti_r_pkt gw_r_data;
  wire            gw_r_ready;

  wire                    gw_v;
  wire [ring_width_p-1:0] gw_data;
  wire                    gw_yumi;

  wire                    zb_v;
  wire [ring_width_p-1:0] zb_data;
  wire                    zb_ready;

  bsg_zedboard_chip zb
    (.clk_i(core_clk_i)
    ,.reset_i(gw_core_reset)
    ,.boot_done_o(boot_done)
    // host in
    ,.host_valid_i(gw_host_in_valid)
    ,.host_data_i(gw_host_in_data)
    ,.host_ready_o(gw_host_in_ready)
    // host out
    ,.host_valid_o(gw_host_out_valid)
    ,.host_data_o(gw_host_out_data)
    ,.host_ready_i(gw_host_out_ready)
    // aw out
    ,.nasti_aw_valid_o(gw_aw_valid)
    ,.nasti_aw_data_o(gw_aw_data)
    ,.nasti_aw_ready_i(gw_aw_ready)
    // w out
    ,.nasti_w_valid_o(gw_w_valid)
    ,.nasti_w_data_o(gw_w_data)
    ,.nasti_w_ready_i(gw_w_ready)
    // b in
    ,.nasti_b_valid_i(gw_b_valid)
    ,.nasti_b_data_i(gw_b_data)
    ,.nasti_b_ready_o(gw_b_ready)
    // ar out
    ,.nasti_ar_valid_o(gw_ar_valid)
    ,.nasti_ar_data_o(gw_ar_data)
    ,.nasti_ar_ready_i(gw_ar_ready)
    // r in
    ,.nasti_r_valid_i(gw_r_valid)
    ,.nasti_r_data_i(gw_r_data)
    ,.nasti_r_ready_o(gw_r_ready)
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
    ,.p_chip_reset_o(gw_async_reset)
    ,.p_host_reset_o(gw_core_reset)
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
    (.p_PLL_CLK_i(core_clk_i)
    ,.p_misc_L_4_i(io_clk_i)
    ,.p_misc_L_5_i(manycore_clk_i)
    ,.p_reset_i(gw_async_reset)
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

  // reset

  assign boot_done_o = boot_done;

  // host

  assign gw_host_in_valid = io_host_in_valid;
  assign gw_host_in_data  = io_host_in_bits;
  assign io_host_in_ready      = gw_host_in_ready;

  assign io_host_out_valid      = gw_host_out_valid;
  assign io_host_out_bits       = gw_host_out_data;
  assign gw_host_out_ready = io_host_out_ready;

  // nasti

  // ar
  assign io_mem_0_ar_valid       = gw_ar_valid;
  assign io_mem_0_ar_bits_addr   = gw_ar_data.addr;
  assign io_mem_0_ar_bits_len    = gw_ar_data.len;
  assign io_mem_0_ar_bits_size   = gw_ar_data.size;
  assign io_mem_0_ar_bits_burst  = gw_ar_data.burst;
  assign io_mem_0_ar_bits_lock   = gw_ar_data.lock;
  assign io_mem_0_ar_bits_cache  = gw_ar_data.cache;
  assign io_mem_0_ar_bits_prot   = gw_ar_data.prot;
  assign io_mem_0_ar_bits_qos    = gw_ar_data.qos;
  assign io_mem_0_ar_bits_region = gw_ar_data.region;
  assign io_mem_0_ar_bits_id     = gw_ar_data.id;
  assign gw_ar_ready        = io_mem_0_ar_ready;

  // aw
  assign io_mem_0_aw_valid       = gw_aw_valid;
  assign io_mem_0_aw_bits_addr   = gw_aw_data.addr;
  assign io_mem_0_aw_bits_len    = gw_aw_data.len;
  assign io_mem_0_aw_bits_size   = gw_aw_data.size;
  assign io_mem_0_aw_bits_burst  = gw_aw_data.burst;
  assign io_mem_0_aw_bits_lock   = gw_aw_data.lock;
  assign io_mem_0_aw_bits_cache  = gw_aw_data.cache;
  assign io_mem_0_aw_bits_prot   = gw_aw_data.prot;
  assign io_mem_0_aw_bits_qos    = gw_aw_data.qos;
  assign io_mem_0_aw_bits_region = gw_aw_data.region;
  assign io_mem_0_aw_bits_id     = gw_aw_data.id;
  assign gw_aw_ready        = io_mem_0_aw_ready;

  // w
  assign io_mem_0_w_valid     = gw_w_valid;
  assign io_mem_0_w_bits_data = gw_w_data.data;
  assign io_mem_0_w_bits_last = gw_w_data.last;
  assign io_mem_0_w_bits_strb = gw_w_data.strb;
  assign gw_w_ready      = io_mem_0_w_ready;

  // b
  assign gw_b_valid     = io_mem_0_b_valid;
  assign gw_b_data.resp = io_mem_0_b_bits_resp;
  assign gw_b_data.id   = io_mem_0_b_bits_id;
  assign io_mem_0_b_ready    = gw_b_ready;

  // r
  assign gw_r_valid     = io_mem_0_r_valid;
  assign gw_r_data.resp = io_mem_0_r_bits_resp;
  assign gw_r_data.data = io_mem_0_r_bits_data;
  assign gw_r_data.last = io_mem_0_r_bits_last;
  assign gw_r_data.id   = io_mem_0_r_bits_id;
  assign io_mem_0_r_ready    = gw_r_ready;

  // debug

  `ifdef BSG_ROCKET_DEBUG

  `define CLIENT_MONITOR chip.g.clnt.r2f

  bsg_rocket_monitor monitor
    (.clk_i(core_clk_i)
    ,.reset_i(reset) // longer reset
    // client host in
    ,.client_host_in_valid(`CLIENT_MONITOR.host_in_valid)
    ,.client_host_in_data(`CLIENT_MONITOR.host_in_data)
    ,.client_host_in_ready(`CLIENT_MONITOR.host_in_ready)
    // client host out
    ,.client_host_out_valid(`CLIENT_MONITOR.host_out_valid)
    ,.client_host_out_data(`CLIENT_MONITOR.host_out_data)
    ,.client_host_out_ready(`CLIENT_MONITOR.host_out_ready)
    // client aw in
    ,.client_nasti_aw_valid(`CLIENT_MONITOR.nasti_aw_valid)
    ,.client_nasti_aw_data(`CLIENT_MONITOR.nasti_aw_data)
    ,.client_nasti_aw_ready(`CLIENT_MONITOR.nasti_aw_ready)
    // client w in
    ,.client_nasti_w_valid(`CLIENT_MONITOR.nasti_w_valid)
    ,.client_nasti_w_data(`CLIENT_MONITOR.nasti_w_data)
    ,.client_nasti_w_ready(`CLIENT_MONITOR.nasti_w_ready)
    // client b out
    ,.client_nasti_b_valid(`CLIENT_MONITOR.nasti_b_valid)
    ,.client_nasti_b_data(`CLIENT_MONITOR.nasti_b_data)
    ,.client_nasti_b_ready(`CLIENT_MONITOR.nasti_b_ready)
    // client ar in
    ,.client_nasti_ar_valid(`CLIENT_MONITOR.nasti_ar_valid)
    ,.client_nasti_ar_data(`CLIENT_MONITOR.nasti_ar_data)
    ,.client_nasti_ar_ready(`CLIENT_MONITOR.nasti_ar_ready)
    // client r out
    ,.client_nasti_r_valid(`CLIENT_MONITOR.nasti_r_valid)
    ,.client_nasti_r_data(`CLIENT_MONITOR.nasti_r_data)
    ,.client_nasti_r_ready(`CLIENT_MONITOR.nasti_r_ready)
    // master host in
    ,.master_host_in_valid(gw_host_in_valid)
    ,.master_host_in_data(gw_host_in_data)
    ,.master_host_in_ready(gw_host_in_ready)
    // master host out
    ,.master_host_out_valid(gw_host_out_valid)
    ,.master_host_out_data(gw_host_out_data)
    ,.master_host_out_ready(gw_host_out_ready)
    // master aw out
    ,.master_nasti_aw_valid(gw_aw_valid)
    ,.master_nasti_aw_data(gw_aw_data)
    ,.master_nasti_aw_ready(gw_aw_ready)
    // master w out
    ,.master_nasti_w_valid(gw_w_valid)
    ,.master_nasti_w_data(gw_w_data)
    ,.master_nasti_w_ready(gw_w_ready)
    // master b in
    ,.master_nasti_b_valid(gw_b_valid)
    ,.master_nasti_b_data(gw_b_data)
    ,.master_nasti_b_ready(gw_b_ready)
    // master ar out
    ,.master_nasti_ar_valid(gw_ar_valid)
    ,.master_nasti_ar_data(gw_ar_data)
    ,.master_nasti_ar_ready(gw_ar_ready)
    // master r in
    ,.master_nasti_r_valid(gw_r_valid)
    ,.master_nasti_r_data(gw_r_data)
    ,.master_nasti_r_ready(gw_r_ready));

  `endif

endmodule
