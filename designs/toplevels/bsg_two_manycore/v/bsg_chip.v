`include "bsg_padmapping.v"

`include "bsg_iopad_macros.v"

module bsg_chip

// pull in BSG Two's top-level module signature, and the definition of the pads
`include "bsg_pinout.v"

`include "bsg_iopads.v"

// **********************************************************************
// BEGIN BSG GUTS
//
// Put this last because the previous lines define the wires that are inputs.
//
//
   wire [7:0] sdi_data_i_int_packed [3:0];
   wire [7:0] sdo_data_o_int_packed [3:0];

   // we swap B input and C input to make physical design easier
   bsg_make_2D_array #(.width_p(8),.items_p(4)) m2da
     (.i({sdi_D_data_i_int, sdi_B_data_i_int, sdi_C_data_i_int, sdi_A_data_i_int})
       ,.o(sdi_data_i_int_packed)
       );

   bsg_flatten_2D_array #(.width_p(8),.items_p(4)) f2da
     (.i(sdo_data_o_int_packed)
       ,.o({sdo_D_data_o_int, sdo_C_data_o_int, sdo_B_data_o_int, sdo_A_data_o_int})
       );

   // fixme; for the real chip, we probably want to create
   // space around pin misc_L_3_i_int to shield it from nearby
   // sdi_A_data_0_i. This could be accomplished by shifting the sdi_A_data_X_i
   // wires over and not use sdi_A_data_0_i, and instead using sdi_A_sclk_i for
   // bit 7. The FPGA could be setup to toggle bit 0 to experimentally determine
   // if this was necessary.

`define BSG_SWIZZLE_3120(a) { a[3],a[1],a[2],a[0] }

   bsg_guts #(.uniqueness_p(1)
              ,.enabled_at_start_vec_p(1'b1)
              ) g
     (.core_clk_i             (misc_L_4_i_int)
       ,.async_reset_i        (reset_i_int    )
       ,.io_master_clk_i      (PLL_CLK_i_int  )
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
