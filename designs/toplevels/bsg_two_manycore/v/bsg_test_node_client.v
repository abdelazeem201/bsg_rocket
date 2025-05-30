`include "bsg_manycore_packet.vh"

//
// this instantiates a bsg_manycore array and also
// a converter between the south side of the manycore array
// and the FSB network.


module  bsg_test_node_client
   import bsg_noc_pkg::*; // {P=0, W, E, N, S}
   import bsg_fsb_pkg::*;
   import bsg_chip_pkg::*;

  #(parameter ring_width_p="inv"
    , parameter master_p="inv"
    , parameter master_id_p="inv"
    , parameter client_id_p="inv"
    )

  (input clk_i
   , input reset_i

   // control
   , input en_i   // FIXME unused

   // input channel
   , input  v_i
   , input [ring_width_p-1:0] data_i
   , output ready_o

   // output channel
   , output v_o
   , output [ring_width_p-1:0] data_o
   , input yumi_i   // late

   );

   localparam dest_id_lp         = master_id_p;

   // shared with client; factor
   localparam bank_size_lp       = bsg_chip_pkg::bank_size_gp;
   localparam bank_num_lp        = bsg_chip_pkg::bank_num_gp;

   localparam addr_width_lp      = bsg_chip_pkg::addr_width_gp;
   localparam data_width_lp      = bsg_chip_pkg::data_width_gp;
   localparam hetero_type_vec_lp = bsg_chip_pkg::hetero_type_vec_gp;
   localparam remote_credits_lp  = bsg_chip_pkg::fsb_remote_credits_gp;

   localparam num_tiles_y_lp     = bsg_chip_pkg::num_tiles_y_gp;
   localparam num_tiles_x_lp     = bsg_chip_pkg::num_tiles_x_gp;

   
   localparam debug_lp           = 0;

   localparam x_cord_width_lp = `BSG_SAFE_CLOG2(num_tiles_x_lp);

   // extra row for I/O at bottom of chip
   localparam y_cord_width_lp = `BSG_SAFE_CLOG2(num_tiles_y_lp+1);

  `declare_bsg_manycore_link_sif_s(addr_width_lp,data_width_lp,x_cord_width_lp,y_cord_width_lp);

   // horizontal -- {E,W}
   bsg_manycore_link_sif_s [E:W][num_tiles_y_lp-1:0]  hor_link_sif_li;
   bsg_manycore_link_sif_s [E:W][num_tiles_y_lp-1:0]  hor_link_sif_lo;

   // vertical -- {S,N}
   bsg_manycore_link_sif_s [S:N][num_tiles_x_lp-1:0]  ver_link_sif_li;
   bsg_manycore_link_sif_s [S:N][num_tiles_x_lp-1:0]  ver_link_sif_lo;

   bsg_manycore #(.bank_size_p       (bank_size_lp)
                  ,.num_banks_p      (bank_num_lp)
                  ,.num_tiles_x_p    (num_tiles_x_lp)
                  ,.num_tiles_y_p    (num_tiles_y_lp)
                  ,.extra_io_rows_p  (1)

                  ,.stub_w_p     ({num_tiles_y_lp{1'b1}})
                  ,.stub_e_p     ({num_tiles_y_lp{1'b1}})
                  ,.stub_n_p     ({num_tiles_x_lp{1'b1}})

                  // south side is unstubbed
                  ,.stub_s_p     ({num_tiles_x_lp{1'b0}})

                  ,.hetero_type_vec_p(hetero_type_vec_lp)
                  ,.debug_p          (debug_lp)
                  ,.addr_width_p     (addr_width_lp)
                  ,.data_width_p     (data_width_lp)
                  ) bm
     (.clk_i
      ,.reset_i

      // these are actually stubbed out and ignored
      ,.hor_link_sif_i(hor_link_sif_li)
      ,.hor_link_sif_o(hor_link_sif_lo)

      // north side is stubbed out and ignored
      ,.ver_link_sif_i(ver_link_sif_li)
      ,.ver_link_sif_o(ver_link_sif_lo)
      );

//
// the FSB network uses the bsg_fsb_pkt_client_data_t format
// (see bsg_fsb_pkg.v) which adds up to 80 bits. Currently it is:
//
//  4 bits   1 bit  75 bits
//
//  destid   cmd     bsg_fsb_pkt_client_data_t
//
//  The 75 bits are split into up to two pieces:
//
//  <tag> <bsg_manycore_packet_s>
//
//  The tag encodes the channel number. For every link
//  that is exposed to the outside world, there are
//  two channels (one for credits and one for return).
//

   bsg_manycore_link_sif_s links_sif_li, links_sif_lo;

   bsg_manycore_links_to_fsb
     #(.ring_width_p     (ring_width_p     )
       ,.dest_id_p       (dest_id_lp       )
       ,.num_links_p     (num_tiles_x_lp   )
       ,.addr_width_p    (addr_width_lp    )
       ,.data_width_p    (data_width_lp    )
       ,.x_cord_width_p  (x_cord_width_lp  )
       ,.y_cord_width_p  (y_cord_width_lp  )
       ,.remote_credits_p(remote_credits_lp)
       ) l2f
       (.clk_i
        ,.reset_i

        // later we may change this to be the west side
        // changes must be mirrored in master node
        ,.links_sif_i(ver_link_sif_lo[S])
        ,.links_sif_o(ver_link_sif_li[S])

        ,.v_i
        ,.data_i
        ,.ready_o

        ,.v_o
        ,.data_o
        ,.yumi_i
        );

// synopsys translate_off

   localparam trace_vscale_pipeline_lp=1'b1;

   if (trace_vscale_pipeline_lp)
     bind   vscale_pipeline bsg_manycore_vscale_pipeline_trace #(.x_cord_width_p(x_cord_width_p)
                                                    ,.y_cord_width_p(y_cord_width_p)
                                                    ) vscale_trace(clk
                                                                   ,PC_IF
                                                                   ,wr_reg_WB
                                                                   ,reg_to_wr_WB
                                                                   ,wb_data_WB
                                                                   ,stall_WB
                                                                   ,imem_wait
                                                                   ,dmem_wait
                                                                   ,dmem_en
                                                                   ,exception_code_WB
                                                                   ,imem_addr
                                                                   ,imem_rdata
                                                                   ,freeze
                                                                   ,my_x_i
                                                                   ,my_y_i
                                                                   );

// synopsys translate_on

endmodule

