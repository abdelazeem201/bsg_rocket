module bsg_gateway_chip

`include "bsg_pinout_inverted.v"

   localparam core_0_period_lp = `CORE_0_PERIOD;
   localparam core_1_period_lp = `CORE_1_PERIOD;
   localparam io_master_0_period_lp = `IO_MASTER_0_PERIOD;
   localparam io_master_1_period_lp = `IO_MASTER_1_PERIOD;


// MAX TIMING CORNER
   
`ifdef TIMING_CORNER_max

   localparam core_clk_ds_val_p  = 8'b0000_0000;
   localparam iom_clk_ds_val_p   = 8'b0000_0000;
   localparam core_clk_mux_final_val_p = 2'b0;
   localparam iom_clk_mux_final_val_p  = 2'b0;
   
`ifdef SPEED_4_CHANNELS
   localparam core_clk_osc_val_p = 5'b10101; // (21=4.26ns)
   localparam iom_clk_osc_val_p    = 5'b01101; // (13=5.112 ns)
`endif

`ifdef SPEED_3_CHANNELS
   localparam core_clk_osc_val_p = 5'b10101;
   localparam iom_clk_osc_val_p  = 5'b10100;  // fastest works with three channels (20= 4.502ns)
`endif

`ifdef SPEED_2_CHANNELS
   localparam core_clk_osc_val_p = 5'b10101;
   localparam iom_clk_osc_val_p  = 5'b11001;   // definitely works (25 = 3.831ns)
`endif

`endif //  `ifdef TIMING_CORNER_max
      

// MIN TIMING CORNER
   
`ifdef TIMING_CORNER_min   

   localparam core_clk_ds_val_p  = 8'b0000_0000;
   localparam iom_clk_ds_val_p   = 8'b0000_0000;
   localparam core_clk_mux_final_val_p = 2'b0;

`ifdef SPEED_4_CHANNELS
   localparam core_clk_osc_val_p = 5'b10101; // (21=4.26ns    ; 1.905 ns)
   localparam iom_clk_osc_val_p  = 5'b10110; // 1.86*2 ns
//   localparam iom_clk_osc_val_p  = 5'b00000; // 1.86*2 ns
   
   // gets errors when we run the above iom slower -- check reset.
   // does not run at any setting without downsampler
   localparam iom_clk_mux_final_val_p  = 2'b1;

// this particular message is okay; it occurs before channel reset is completed
// and occurs because some unknown signals temporarily resolve to known and then go back to unknown
//"std_cells_filtered.v", 9527: Timing violation in bsg_double_trouble_pcb.asic.ASIC.g.comm_link.ch_1__s_control_slave.out_clk_init_r_o_reg
//    $setuphold( posedge CK &&& (flag == 1'b1):32089971, posedge D:32089931, limits: (74,-33) );

`endif

`ifdef SPEED_3_CHANNELS
   localparam core_clk_osc_val_p = 5'b10101;
   localparam iom_clk_osc_val_p  = 5'b0101; // (13=5.112 ns  2.338 ns) // 3 channels only
   localparam iom_clk_mux_final_val_p  = 2'b0;
`endif

`ifdef SPEED_2_CHANNELS
   localparam core_clk_osc_val_p = 5'b10110; // 22=1.815 (550 MHz)
   localparam iom_clk_osc_val_p  = 5'b11000; // 24=1.768ns (565 MHz)
   localparam iom_clk_mux_final_val_p  = 2'b0;
`endif
   
`endif //  `ifdef TIMING_CORNER_min


// TYP TIMING CORNER
   
`ifdef TIMING_CORNER_typ   

   localparam core_clk_ds_val_p  = 8'b0000_0000;
   localparam iom_clk_ds_val_p   = 8'b0000_0000;
   localparam core_clk_mux_final_val_p = 2'b0;

`ifdef SPEED_4_CHANNELS
   localparam core_clk_osc_val_p = 5'b10101; // 
   localparam iom_clk_osc_val_p  = 5'b10110; // 
   
   // gets errors when we run the above iom slower -- check reset.
   // does not run at any setting without downsampler
   localparam iom_clk_mux_final_val_p  = 2'b1;


`endif

`ifdef SPEED_3_CHANNELS
   localparam core_clk_osc_val_p = 5'b10101;
   localparam iom_clk_osc_val_p  = 5'b0101; // 
   localparam iom_clk_mux_final_val_p  = 2'b0;
`endif

`ifdef SPEED_2_CHANNELS
   localparam core_clk_osc_val_p = 5'b10110; // 
   localparam iom_clk_osc_val_p  = 5'b11000; // 
   localparam iom_clk_mux_final_val_p  = 2'b0;
`endif
   
`endif //  `ifdef TIMING_CORNER_typ
   
   
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

   logic       async_reset_lo;

   localparam core_reset_cycles_hi_lp = 1280;
   localparam core_reset_cycles_lo_lp = 16;

   // reset generator for local module
   bsg_nonsynth_reset_gen
     #(.num_clocks_p(4)
       ,.reset_cycles_lo_p(core_reset_cycles_lo_lp)
       ,.reset_cycles_hi_p(core_reset_cycles_hi_lp)
       ) reset_gen
       (.clk_i({ gateway_core_clk, gateway_io_master_clk, asic_core_clk, asic_io_master_clk })
        ,.async_reset_o(async_reset_lo)
        );

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
      ,.async_reset_i           ( async_reset_lo        )
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

   genvar 			     j;
   
   for (j = 0; j < nodes_lp; j=j+1)
     begin
        test_bsg_comm_link_checker
            #(.channel_width_p(channel_width_lp)
              ,.num_channels_p(num_channels_lp)
              ,.ring_bytes_p  (ring_bytes_lp)
              ,.check_bytes_p (8)
              ,.verbose_p     (verbose_lp)
              ,.iterations_p  (iterations_lp)
              ,.core_0_period_p(core_0_period_lp)
              ,.core_1_period_p(core_1_period_lp)
              ,.io_master_0_period_p(io_master_0_period_lp)
              ,.io_master_1_period_p(io_master_1_period_lp)
              ,.chip_num_p          (0)
              ,.node_num_p          (j)
              ,.cycle_counter_width_p(cycle_counter_width_lp)
              ) checker
            (.clk      (     gateway_core_clk)
             ,.valid_in(guts.core_node_v_A[j])
             ,.ready_in(guts.core_node_ready_A[j])
             ,.data_in (guts.core_node_data_A [j][ring_bytes_lp*channel_width_lp-1:0])
             ,.data_out(guts.core_node_data_B [j][ring_bytes_lp*channel_width_lp-1:0])
             ,.yumi_out(guts.core_node_yumi_B [j])
             ,.async_reset(async_reset_lo)
             ,.slave_reset_tline(p_reset_o)
             ,.io_valid_tline( `BSG_SWIZZLE_3120(p_sdi_ncmd_o))
             ,.io_data_tline ( sdi_data_o_int_packed          )
             ,.core_ctr(core_ctr)
             ,.io_ctr(io_ctr)
             ,.done_o(done_signals[j])
             );
     end // for (j = 0; j < nodes_lp; j=j+1)

   always @(negedge gateway_core_clk)
     if ((& done_signals) == 1'b1)
       $finish("##");



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
      ,.done_o()
      );

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

   // assign p_JTAG_TMS_o = 1'b0;
   // assign p_JTAG_TDI_o = 1'b0;
   // assign p_JTAG_TCK_o = 1'b0;

   // keep clk gen core oscillator in reset
   //assign p_JTAG_TRST_o = 1'b1;

   wire _unused1 = p_JTAG_TDO_i;
   wire _unused2 = p_misc_L_3_i;
   wire _unused3 = p_misc_R_3_i;


   // pass through of external core clock
   // assign p_misc_R_7_o = 1'b1;
   // assign p_misc_R_6_o = 1'b0;

   // pass through of external io master clock
   //assign p_misc_L_7_o = 1'b1;
   //assign p_misc_L_6_o = 1'b0;

   // assign p_misc_L_4_o = 1'b0;  used as clock input for ASIC
   assign p_misc_L_5_o = 1'b0;
   assign p_misc_R_4_o = 1'b0;



   // keep io master clk gen in reset
   //assign p_sdo_tkn_ex_o[2] = 1'b1;

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
