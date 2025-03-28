`ifndef BSG_CLK_WATCH
`define BSG_CLK_WATCH bsg_double_trouble_pcb.asic.ASIC.sdi_tkn_ex_o_int_3_
`endif

module bsg_gateway_chip

`include "bsg_pinout_inverted.v"

   // timing corner typical
   localparam core_clk_osc_val_p = 5'b10101;
   localparam core_clk_ds_val_p = 8'b0000_0000;
   localparam core_clk_mux_final_val_p = 2'b00;

   localparam core_1_period_lp = `CORE_1_PERIOD;

   localparam num_adgs_lp = 1;

   logic done_lo;

   bsg_nonsynth_clock_gen #(10000) cfg_clk_gen (p_JTAG_TCK_o);

   bsg_nonsynth_clock_gen #(.cycle_time_p(core_1_period_lp  )) asic_core_gen_clk   (.o(p_misc_L_4_o));

   bsg_nonsynth_clk_gen_tester #(.fast_sim_p(1)
                                 ,.num_adgs_p (num_adgs_lp)
                                 ,.ds_width_p(8)
                                 ,.tag_els_p (4)
                                 ,.tag_node_base_p(0)
                                 ,.osc_final_val_p(core_clk_osc_val_p)
                                 ,.ds_final_val_p(core_clk_ds_val_p)
                                 ,.clk_mux_final_val_p(core_clk_mux_final_val_p)
                                 )
   bncgt
     (.ext_clk_i        (p_misc_L_4_o)
      ,.bsg_tag_clk_i    (p_JTAG_TCK_o)
      ,.bsg_tag_en_o     (p_JTAG_TMS_o)
      ,.bsg_tag_data_o   (p_JTAG_TDI_o)
      ,.bsg_clk_gen_sel_o({p_misc_R_7_o, p_misc_R_6_o})
      ,.bsg_clk_gen_async_reset_o(p_JTAG_TRST_o)
      ,.bsg_clk_gen_i(`BSG_CLK_WATCH)
      ,.start_i(1'b1)
      ,.done_o(done_lo)
      );

   // select core clock for view on output
   assign { p_misc_R_5_o, p_sdo_tkn_ex_o[3] } = 2'b0;

  initial
    begin
       $vcdpluson;
       $vcdplusmemon;
    end

  // finish
  always @(posedge p_misc_L_4_o)
    if (done_lo)
      $finish;

endmodule
