// instantiates the bsg_nonsynth_manycore_io_complex
// connected to the fsb via a bsg_manycore_links_to_fsb
//

module  bsg_test_node_master
   import bsg_fsb_pkg::*;
   import bsg_chip_pkg::*;
  #(parameter ring_width_p="inv"
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
   , input yumi_i

   );

   localparam tile_id_ptr_lp     = bsg_chip_pkg::tile_id_ptr_gp;
   localparam max_cycles_lp      = bsg_chip_pkg::max_cycles_gp;
   localparam mem_size_lp        = bsg_chip_pkg::mem_size_gp;

   localparam addr_width_lp      = bsg_chip_pkg::addr_width_gp;
   localparam data_width_lp      = bsg_chip_pkg::data_width_gp;
   localparam hetero_type_vec_lp = bsg_chip_pkg::hetero_type_vec_gp;
   localparam remote_credits_lp  = bsg_chip_pkg::fsb_remote_credits_gp;

   localparam num_tiles_y_lp     = bsg_chip_pkg::num_tiles_y_gp;
   localparam num_tiles_x_lp     = bsg_chip_pkg::num_tiles_x_gp;

   localparam dest_id_lp         = client_id_p;
   localparam x_cord_width_lp = `BSG_SAFE_CLOG2(num_tiles_x_lp);

   // extra row for I/O at bottom of chip
   localparam y_cord_width_lp = `BSG_SAFE_CLOG2(num_tiles_y_lp+1);

  `declare_bsg_manycore_link_sif_s(addr_width_lp,data_width_lp,x_cord_width_lp,y_cord_width_lp);

   bsg_manycore_link_sif_s [num_tiles_x_lp-1:0] ver_link_sif_li;
   bsg_manycore_link_sif_s [num_tiles_x_lp-1:0] ver_link_sif_lo;

   bsg_nonsynth_manycore_io_complex
     #(
       .mem_size_p    (mem_size_lp   )
       ,.max_cycles_p (max_cycles_lp )
       ,.addr_width_p (addr_width_lp )
       ,.data_width_p (data_width_lp )
       ,.num_tiles_x_p(num_tiles_x_lp)
       ,.num_tiles_y_p(num_tiles_y_lp)
       ,.tile_id_ptr_p(tile_id_ptr_lp)
       ) ioc
   (.clk_i
    ,.reset_i

    ,.ver_link_sif_i(ver_link_sif_li)
    ,.ver_link_sif_o(ver_link_sif_lo)
    );

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

    ,.links_sif_i(ver_link_sif_lo)
    ,.links_sif_o(ver_link_sif_li)

    ,.v_i
    ,.data_i
    ,.ready_o

    ,.v_o
    ,.data_o
    ,.yumi_i
    );

endmodule

