module bsg_gateway_chip

`include "bsg_pinout_inverted.v"

   localparam core_0_period_lp = `CORE_0_PERIOD;
   localparam core_1_period_lp = `CORE_1_PERIOD;
   localparam io_master_0_period_lp = `IO_MASTER_0_PERIOD;
   localparam io_master_1_period_lp = `IO_MASTER_1_PERIOD;

// MAX TIMING CORNER
   localparam core_clk_ds_val_p  = 8'b0000_0000;
   localparam iom_clk_ds_val_p   = 8'b0000_0000;
   localparam core_clk_mux_final_val_p = 2'b0;
   localparam iom_clk_mux_final_val_p  = 2'b0;

   localparam core_clk_osc_val_p   = 5'b10101; // (21=4.26ns)
   localparam iom_clk_osc_val_p    = 5'b01101; // (13=5.112 ns)

   // higher than this and the clock does not pass through the 16 mA I/O pad
   initial begin
      $vcdpluson;
      $vcdplusmemon;
   end

   initial
     $display("%m gateway creating clocks",core_0_period_lp, core_1_period_lp,
              io_master_0_period_lp, io_master_1_period_lp);

   wire asic_core_clk, asic_io_master_clk;

   bsg_nonsynth_clock_gen #(.cycle_time_p(core_1_period_lp  ))    asic_core_gen_clk   (.o(asic_core_clk  ));
   bsg_nonsynth_clock_gen #(.cycle_time_p(io_master_1_period_lp)) asic_master_gen_clk (.o(asic_io_master_clk));

   assign p_misc_L_4_o = asic_core_clk;
   assign p_PLL_CLK_o  = asic_io_master_clk;

   wire gateway_core_clk, gateway_io_master_clk;

   bsg_nonsynth_clock_gen #(.cycle_time_p(core_0_period_lp  ))      gateway_core_gen_clk  (.o(gateway_core_clk  ));
   bsg_nonsynth_clock_gen #(.cycle_time_p(io_master_0_period_lp  )) gateway_master_gen_clk(.o(gateway_io_master_clk));

   wire [7:0] sdo_data_i_int_packed [3:0];
   wire [7:0] sdi_data_o_int_packed [3:0];

   bsg_make_2D_array #(.width_p(8),.items_p(4)) m2da
     (.i({p_sdo_D_data_i, p_sdo_C_data_i, p_sdo_B_data_i, p_sdo_A_data_i})
      ,.o(sdo_data_i_int_packed)
      );

   // we swap B input and C input on both ASIC and Gateway to make physical design easier
   bsg_flatten_2D_array #(.width_p(8),.items_p(4)) f2da
     (.i(sdi_data_o_int_packed)
      ,.o({p_sdi_D_data_o, p_sdi_B_data_o, p_sdi_C_data_o, p_sdi_A_data_o})
      );

   wire       core_calib_reset;

`define BSG_SWIZZLE_3120(a) { a[3],a[1],a[2],a[0] }

   localparam nodes_lp = 1;

   bsg_guts #(.num_channels_p(4)
              ,.master_p(1)
              ,.master_to_client_speedup_p(100)
              ,.master_bypass_test_p(5'b11111)
              ,.enabled_at_start_vec_p({ (nodes_lp) {1'b1} })
              ,.nodes_p(nodes_lp)
              ) guts
     (.core_clk_i               ( gateway_core_clk      )  // locally generated
//      Keep it reseted all the time
      ,.async_reset_i           ( 1'b1        )
      ,.io_master_clk_i         ( gateway_io_master_clk    )  // locally generated
      ,.io_clk_tline_i          ( p_sdo_sclk_i          )
      ,.io_valid_tline_i        ( p_sdo_ncmd_i          )
      ,.io_data_tline_i         ( sdo_data_i_int_packed )
      ,.io_token_clk_tline_o    ( p_sdo_token_o         )
      ,.im_clk_tline_o          ( `BSG_SWIZZLE_3120(p_sdi_sclk_o)  )
      ,.im_valid_tline_o        ( `BSG_SWIZZLE_3120(p_sdi_ncmd_o)  )
      ,.im_data_tline_o         ( sdi_data_o_int_packed            )
      ,.token_clk_tline_i       ( `BSG_SWIZZLE_3120(p_sdi_token_i) )
      ,.im_slave_reset_tline_r_o( p_reset_o )
      ,.core_reset_o            (core_calib_reset)
      );

   localparam cycle_counter_width_lp=32;

   wire [cycle_counter_width_lp-1:0] core_ctr[1:0];
   wire [cycle_counter_width_lp-1:0] io_ctr  [1:0];

   wire [nodes_lp-1:0]               done_signals;

   bsg_cycle_counter #(.width_p(cycle_counter_width_lp))
   gw_core_ctr (.clk(gateway_core_clk), .reset_i(core_calib_reset), .ctr_r_o(core_ctr[0]));

   bsg_cycle_counter #(.width_p(cycle_counter_width_lp))
   gw_io_ctr   (.clk(gateway_io_master_clk), .reset_i(core_calib_reset), .ctr_r_o(io_ctr[0]));

   bsg_cycle_counter #(.width_p(cycle_counter_width_lp))
   asic_core_ctr (.clk(asic_core_clk), .reset_i(core_calib_reset), .ctr_r_o(core_ctr[1]));

   bsg_cycle_counter #(.width_p(cycle_counter_width_lp))
   asic_io_ctr   (.clk(asic_io_master_clk), .reset_i(core_calib_reset), .ctr_r_o(io_ctr[1]));


   localparam channel_width_lp = 8;
   localparam num_channels_lp  = 4;
   localparam verbose_lp       = 1;
   localparam iterations_lp    = 16;
   localparam ring_bytes_lp    = 10;

`define BSG_CLK_WATCH bsg_double_trouble_pcb.asic.ASIC.sdi_tkn_ex_o_int_3_

`ifndef BSG_CLK_WATCH
`define BSG_CLK_WATCH  p_sdi_tkn_ex_i[3]
`endif

   bsg_nonsynth_clock_gen #(10000) cfg_clk_gen (p_JTAG_TCK_o);

   wire clk_gen_0_done;

   // this is select mux for viewing the test clock

   assign p_sdo_tkn_ex_o[3] = clk_gen_0_done;  // bit 0
   assign p_misc_R_5_o      = 1'b0;            // bit 1

   wire [1:0] jtag_tms, jtag_tdi;

   assign p_JTAG_TMS_o = | jtag_tms;
   assign p_JTAG_TDI_o = | jtag_tdi;

   bsg_nonsynth_clk_gen_tester #(.fast_sim_p(1)
                                 ,.num_adgs_p(1)
                                 ,.ds_width_p(8)
                                 ,.tag_els_p(4)
                                 ,.tag_node_base_p(0)
                                 ,.osc_final_val_p(core_clk_osc_val_p)
                                 ,.ds_final_val_p(core_clk_ds_val_p)
                                 ,.clk_mux_final_val_p(core_clk_mux_final_val_p)
                                 ) cg_core_test
     (.ext_clk_i        (p_misc_L_4_o)
      ,.bsg_tag_clk_i    (p_JTAG_TCK_o)
      ,.bsg_tag_en_o     (jtag_tms[0])
      ,.bsg_tag_data_o   (jtag_tdi[0])
      ,.bsg_clk_gen_sel_o({p_misc_R_7_o, p_misc_R_6_o})
      ,.bsg_clk_gen_async_reset_o(p_JTAG_TRST_o)


      ,.bsg_clk_gen_i(`BSG_CLK_WATCH)
      ,.start_i(1'b1)
      ,.done_o(clk_gen_0_done)
      );

    wire clk_gen_1_done;
    bsg_nonsynth_clk_gen_tester #(.fast_sim_p(1)
                                  ,.num_adgs_p(1)
                                  ,.ds_width_p(8)
                                  ,.tag_els_p(4)
                                  ,.tag_node_base_p(2)
                                  ,.osc_final_val_p(iom_clk_osc_val_p)
                                  ,.ds_final_val_p(iom_clk_ds_val_p)
                                 ,.clk_mux_final_val_p(iom_clk_mux_final_val_p)
                                 ) cg_iom_test
     (.ext_clk_i        (p_PLL_CLK_o)
      ,.bsg_tag_clk_i    (p_JTAG_TCK_o)
      ,.bsg_tag_en_o     (jtag_tms[1])
      ,.bsg_tag_data_o   (jtag_tdi[1])
      ,.bsg_clk_gen_sel_o({p_misc_L_7_o, p_misc_L_6_o})
      ,.bsg_clk_gen_async_reset_o( p_sdo_tkn_ex_o[2])


      ,.bsg_clk_gen_i(`BSG_CLK_WATCH)
      ,.start_i(clk_gen_0_done)
      ,.done_o(clk_gen_1_done)
      );

   always_ff@( negedge gateway_core_clk ) begin
        if( clk_gen_1_done ) $finish;
   end
   // assign unuseds, so it's clear they're here
   // and to clean up X's in simulation

   assign p_misc_T_0_o = 1'b0;
   assign p_misc_T_1_o = 1'b0;
   assign p_misc_T_2_o = 1'b0;

   assign p_misc_L_0_o = 1'b0;
   assign p_misc_L_1_o = 1'b0;
   assign p_misc_L_2_o = 1'b0;

   assign p_misc_R_0_o = 1'b0;
   assign p_misc_R_1_o = 1'b0;
   assign p_misc_R_2_o = 1'b0;

   wire _unused1 = p_JTAG_TDO_i;
   wire _unused2 = p_misc_L_3_i;
   wire _unused3 = p_misc_R_3_i;

   assign p_misc_L_5_o = 1'b0;
   assign p_misc_R_4_o = 1'b0;

   assign p_sdo_tkn_ex_o[1] = 1'b0;
   assign p_sdo_tkn_ex_o[0] = 1'b0;

   wire [3:0] _unused4 = p_sdi_tkn_ex_i;

   assign p_sdi_sclk_ex_o = 4'b0;
   wire [3:0] _unused5    = p_sdo_sclk_ex_i;

   assign p_clk_0_p_o = 1'b0;
   assign p_clk_0_n_o = 1'b1;

   assign p_clk_1_p_o = 1'b0;
   assign p_clk_1_n_o = 1'b1;


endmodule
