
`include "bsg_padmapping.v"
`include "bsg_iopad_macros.v"

module bsg_chip

  import bsg_tag_pkg::bsg_tag_s;

  `include "bsg_pinout.v"
  `include "bsg_iopads.v"
  `include "bsg_tag.vh"

  //----------------------------------------------
  // Begin Design
  //

  bsg_clkbuf
   #(.width_p(1)
    ,.harden_p(1)
    )
  clk_gen_0_inst
    (.i(misc_L_4_i_int)
    ,.o()
    );

  //----------------------------------------------
  //
  //

  localparam bsg_tag_client_count_lp = 1;
  localparam bsg_tag_data_width_lp   = 47;
  localparam bsg_mem_els_lp          = 1024;
  localparam bsg_mem_width_lp        = 32;

  //----------------------------------------------
  //
  //

  bsg_tag_s [bsg_tag_client_count_lp-1:0] btm_client_lines;

  bsg_tag_master
   #(.els_p       (bsg_tag_client_count_lp)
    ,.lg_width_p  (`BSG_SAFE_CLOG2(bsg_tag_data_width_lp))
    )
  btm
    (.clk_i       (JTAG_TCK_i_int)
    ,.data_i      (JTAG_TDI_i_int)
    ,.en_i        (JTAG_TMS_i_int)
    ,.clients_r_o (btm_client_lines)
    );

  //----------------------------------------------
  //
  //

  logic                              btc_new_data;
  logic [bsg_tag_data_width_lp-1:0]  btc_data_out;

  bsg_tag_client
   #(.width_p       (bsg_tag_data_width_lp)
    ,.default_p     (0)
    ,.harden_p      (0)
    )
  btc
    (.bsg_tag_i     (btm_client_lines[0])
    ,.recv_clk_i    (JTAG_TCK_i_int)
    ,.recv_reset_i  (reset_i_int)
    ,.recv_new_r_o  (btc_new_data)
    ,.recv_data_r_o (btc_data_out)
    );

  //----------------------------------------------
  //
  //

  logic [bsg_mem_width_lp-1:0]                bsg_mem_data_out;

  bsg_mem_1rw_sync_mask_write_byte
   #(.els_p        (bsg_mem_els_lp)
    ,.data_width_p (bsg_mem_width_lp)
    )
  mem1
    (.clk_i        (JTAG_TCK_i_int)
    ,.reset_i      (reset_i_int)
    ,.v_i          (btc_new_data)
    ,.w_i          (btc_data_out[0])
    ,.data_i       (btc_data_out[46:15])
    ,.addr_i       (btc_data_out[14:5])
    ,.write_mask_i (btc_data_out[4:1])
    ,.data_o       (bsg_mem_data_out)
    );

  //
  // End Design
  //----------------------------------------------

  `include "bsg_pinout_end.v"
