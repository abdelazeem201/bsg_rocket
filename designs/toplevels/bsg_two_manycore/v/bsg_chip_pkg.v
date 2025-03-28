`ifndef BSG_CHIP_PKG_V
`define BSG_CHIP_PKG_V

package bsg_chip_pkg;

   // for both bsg_test_node_master and bsg_test_node_client
   parameter bank_size_gp          = 1024;
   parameter bank_num_gp           = 8;
   parameter addr_width_gp         = 20;
   parameter data_width_gp         = 32;
   parameter hetero_type_vec_gp    = 64'h01_01_01_01;
   parameter fsb_remote_credits_gp = 128;
   parameter num_tiles_x_gp        = 2;
   parameter num_tiles_y_gp        = 1;

   // for bsg_test_node_master
   parameter tile_id_ptr_gp  = -1;
   parameter max_cycles_gp   = 500000;

   parameter mem_size_gp     = 32768; // fixme: calc from bank size and num?

endpackage

`endif
