`include "bsg_padmapping.v"

`include "bsg_iopad_macros.v"

module bsg_chip

   import bsg_tag_pkg::bsg_tag_s;

// pull in BSG Two's top-level module signature, and the definition of the pads
`include "bsg_pinout.v"

`include "bsg_iopads.v"

   // disable sdi_tkn_ex_o[0..2]
   `BSG_IO_TIEHI_VEC(sdi_tkn_ex_oen_int,3)

   // enable sdi_tkn_ex[3]
   `BSG_IO_TIELO_VEC_ONE(sdi_tkn_ex_oen_int,3)

   // disable sdo_sclk_ex[0..3]
   `BSG_IO_TIEHI_VEC(sdo_sclk_ex_oen_int,4)

   // disable misc_L_3_o
   `BSG_IO_TIEHI(misc_L_3_oen_int)

   // disable misc_R_3_o
   `BSG_IO_TIEHI(misc_R_3_oen_int)

   // disable sdo_A_data_8_o
   `BSG_IO_TIEHI(sdo_A_data_8_oen_int)

   // disable sdo_C_data_8_o
   `BSG_IO_TIEHI(sdo_C_data_8_oen_int)

   `BSG_IO_TIEHI(JTAG_TDO_oen_int)
// **********************************************************************
// BEGIN BSG CLK GENS
//

   logic [1:0]  clk_gen_iom_sel;
   logic [1:0]  clk_gen_core_sel;
   logic        clk_gen_iom_async_reset;
   logic        clk_gen_core_async_reset;

   // all of these should be shielded
   assign clk_gen_iom_sel[0]  = misc_L_6_i_int;
   assign clk_gen_iom_sel[1]  = misc_L_7_i_int;
   assign clk_gen_core_sel[0] = misc_R_6_i_int;
   assign clk_gen_core_sel[1] = misc_R_7_i_int;
   assign clk_gen_iom_async_reset  = sdo_tkn_ex_i_int[2];
   assign clk_gen_core_async_reset = JTAG_TRST_i_int;

`include "bsg_tag.vh"

   localparam bsg_tag_els_lp  = 4;
   localparam bsg_ds_width_lp = 8;
   localparam bsg_num_adgs_lp = 1;

   `declare_bsg_clk_gen_osc_tag_payload_s(bsg_num_adgs_lp)
   `declare_bsg_clk_gen_ds_tag_payload_s(bsg_ds_width_lp)

   localparam bsg_tag_max_payload_length_lp
     = `BSG_MAX($bits(bsg_clk_gen_osc_tag_payload_s),$bits(bsg_clk_gen_ds_tag_payload_s));

   localparam lg_bsg_tag_max_payload_length_lp = $clog2(bsg_tag_max_payload_length_lp+1);

   bsg_tag_s [bsg_tag_els_lp-1:0] tags;

   bsg_tag_master #(.els_p(bsg_tag_els_lp)
                    ,.lg_width_p(lg_bsg_tag_max_payload_length_lp)
                    ) btm
     (.clk_i       (JTAG_TCK_i_int)
      ,.data_i     (JTAG_TDI_i_int)
      ,.en_i       (JTAG_TMS_i_int) // shield
      ,.clients_r_o(tags)
      );

   // Clock signals coming out of clock generators
   logic core_clk_lo;
   logic iom_clk_lo;

   // core clock generator (bsg_tag ID's 0 and 1)
   bsg_clk_gen #(.downsample_width_p(bsg_ds_width_lp)
                 ,.num_adgs_p(bsg_num_adgs_lp)
                 ) clk_gen_core_inst
     (.bsg_osc_tag_i(tags[0])
      ,.bsg_ds_tag_i(tags[1])
      ,.async_osc_reset_i(clk_gen_core_async_reset)
      ,.ext_clk_i(misc_L_4_i_int)  // probably should be identified as clock
      ,.select_i (clk_gen_core_sel)
      ,.clk_o    (core_clk_lo)
      );

   // io clock generator (bsg_tag ID's 2 and 3)
   bsg_clk_gen #(.downsample_width_p(bsg_ds_width_lp)
                 ,.num_adgs_p(bsg_num_adgs_lp)
                 ) clk_gen_iom_inst
     (.bsg_osc_tag_i(tags[2])
      ,.bsg_ds_tag_i(tags[3])
      ,.async_osc_reset_i(clk_gen_iom_async_reset)
      ,.ext_clk_i(PLL_CLK_i_int) // probably should be identified as clock
      ,.select_i (clk_gen_iom_sel)
      ,.clk_o    (iom_clk_lo)
      );

   // Route the clock signals off chip to see life in the chip!
   logic [1:0]  clk_out_sel;
   logic        clk_out;

   assign clk_out_sel[0] = sdo_tkn_ex_i_int[3]; // shield
   assign clk_out_sel[1] = misc_R_5_i_int;      // shield
   assign sdi_tkn_ex_o_int[3] = clk_out;        // shield

   bsg_mux #(.width_p    (1)
             ,.els_p     (4)
             ,.balanced_p(1)
             ,.harden_p  (1)
             ) clk_out_mux_inst
     // being able to not output clock is a good idea
     // for noise; can also be used to see if chip is alive

     (.data_i({1'b1,1'b0,iom_clk_lo,core_clk_lo})
      ,.sel_i(clk_out_sel)
      ,.data_o(clk_out)
      );

// **********************************************************************
// BEGIN BSG GUTS
//
// Put this last because the previous lines define the wires that are inputs.
//
//
   wire [7:0] sdi_data_i_int_packed [3:0];
   wire [7:0] sdo_data_o_int_packed [3:0];

   // we swap B input and C input to make physical design easier
   //bsg_make_2D_array #(.width_p(8),.items_p(4)) m2da
   //  (.i({sdi_D_data_i_int, sdi_B_data_i_int, sdi_C_data_i_int, sdi_A_data_i_int})
   //    ,.o(sdi_data_i_int_packed)
   //    );

   assign sdi_data_i_int_packed = {sdi_D_data_i_int, sdi_B_data_i_int, sdi_C_data_i_int, sdi_A_data_i_int};

   //bsg_flatten_2D_array #(.width_p(8),.items_p(4)) f2da
   //  (.i(sdo_data_o_int_packed)
   //    ,.o({sdo_D_data_o_int, sdo_C_data_o_int, sdo_B_data_o_int, sdo_A_data_o_int})
   //    );

   assign { sdo_D_data_o_int, sdo_C_data_o_int, sdo_B_data_o_int, sdo_A_data_o_int }
             = { >> {sdo_data_o_int_packed} };

`define BSG_SWIZZLE_3120(a) { a[3],a[1],a[2],a[0] }

   bsg_guts #(.uniqueness_p(1)) g
     (.core_clk_i             (core_clk_lo    )
       ,.async_reset_i        (reset_i_int    )
       ,.io_master_clk_i      (iom_clk_lo     )
      // flip B and C input for PD
       ,.io_clk_tline_i       ( `BSG_SWIZZLE_3120(sdi_sclk_i_int)  )
       ,.io_valid_tline_i     ( `BSG_SWIZZLE_3120(sdi_ncmd_i_int)  )
       ,.io_data_tline_i      (sdi_data_i_int_packed)
       ,.io_token_clk_tline_o ( `BSG_SWIZZLE_3120(sdi_token_o_int) )
       ,.im_clk_tline_o       (sdo_sclk_o_int )
       ,.im_valid_tline_o     (sdo_ncmd_o_int )
       ,.im_data_tline_o      (sdo_data_o_int_packed)
       ,.token_clk_tline_i    (sdo_token_i_int)
       ,.im_slave_reset_tline_r_o()             // unused by ASIC
       ,.core_reset_o            ()             // post calibration reset
       );

`include "bsg_pinout_end.v"
