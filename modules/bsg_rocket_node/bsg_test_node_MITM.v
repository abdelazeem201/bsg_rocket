// Author: shawnless.xie@gmail.com
//
// The BSG Man In The Middle (MITM) module.
// This module replay the packtes to and from
// the FSB masters, fooling around the original
// master.
//
//   FSB | --> |MITM |--> |Master
//       | <-- |     |<-- |
module  bsg_test_node_MITM
   import bsg_fsb_pkg::*;
  #(parameter ring_width_p="inv"
    , parameter master_id_p="inv"
    , parameter client_id_p="inv"
	, parameter enable_MITM_stimulus_p=0
	, parameter enable_MITM_response_p=0)
  (  input clk_i
   , input reset_i

   // control
   , input en_i
   , output done_o
   , output error_o

   // input channel
   , input  v_i
   , input [ring_width_p-1:0] data_i
   , output ready_o

   // output channel
   , output v_o
   , output [ring_width_p-1:0] data_o
   , input yumi_i   // late

   // input from master
   , input  from_master_v_i
   , input [ring_width_p-1:0] from_master_data_i
   , output from_master_ready_o

   // output to master
   , output to_master_v_o
   , output [ring_width_p-1:0] to_master_data_o
   , input to_master_yumi_i   // late


   );
    // Assign the input from FSB to the master:
   assign to_master_v_o         = 1'b0  ;
   assign to_master_data_o      = data_i;

   assign from_master_ready_o   = 1'b1;

    // Ignore the input from the master to FSB

    // Instantiate the trace_replay.
    bsg_test_node_master
  #( .ring_width_p          ( ring_width_p  )
    ,.enable_MITM_response_p( enable_MITM_response_p )
    ,.master_id_p           ( master_id_p   )
    ,.client_id_p           ( client_id_p   )
    ) response
    ( .clk_i
    , .reset_i

    // control
    , .en_i
    , .done_o
    , .error_o

    // input channel
    , .v_i
    , .data_i
    , .ready_o

    // output channel
    , .v_o ()
    , .data_o ()
    , .yumi_i (1'b0)  // late
    );

    bsg_test_node_master
  #( .ring_width_p          ( ring_width_p  )
    ,.enable_MITM_stimulus_p( enable_MITM_stimulus_p )
    ,.master_id_p           ( master_id_p   )
    ,.client_id_p           ( client_id_p   )
    ) stimulus
    ( .clk_i
    , .reset_i

    // control
    , .en_i
    , .done_o  ()
    , .error_o ()

    // input channel
    , .v_i     (1'b0)
    , .data_i  (ring_width_p'(0) )
    , .ready_o ( )

    // output channel
    , .v_o
    , .data_o
    , .yumi_i  // late
    );

endmodule

