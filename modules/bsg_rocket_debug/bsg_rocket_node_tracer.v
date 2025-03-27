// This file is used as a tracer to record the in/out
// packet of the bsg_rocket_node_master
`include "bsg_rocket_pkg.vh"
`include "bsg_fsb_pkg.v"

module bsg_rocket_node_tracer
    import bsg_rocket_pkg::*;
    import bsg_fsb_pkg::*;
# (parameter dest_id_p = 0,
   parameter string file_prefix=""
  )
  (
    input               clk_i
   ,input               en_i
   ,input               reset_i
   // input packet
   ,input                       v_i_i
   ,input  bsg_fsb_pkt_client_s data_i_i
   ,input                       ready_o_i
   // output packet
   ,input                       v_o_i
   ,input  bsg_fsb_pkt_client_s data_o_i
   ,input                       yumi_i_i

);

//The trace file command definition
// format:   <4 bit op> <fsb packet>
//   op = 0000: wait one cycle
//   op = 0001: send
//   op = 0010: receive & check
//   op = 0011: done; disable but do not stop
//   op = 0100: end test; call $finish
//   op = 0101: decrement cycle counter; wait for cycle_counter == 0
//   op = 0110: initialized cycle counter with 16 bits

localparam  T_CMD_NOP  = 4'b0000 ;
localparam  T_CMD_SEND = 4'b0001 ;
localparam  T_CMD_RECV = 4'b0010 ;
localparam  T_CMD_DONE = 4'b0011 ;
localparam  T_CMD_END  = 4'b0100 ;
localparam  T_CMD_WCNT = 4'b0101 ;
localparam  T_CMD_ICNT = 4'b0110 ;
localparam  counter_width_lp = 16 ;

integer stimulus_file, response_file;
// open the trace file.
initial begin
    string stimulus_file_name, response_file_name;

    $sformat(stimulus_file_name, "%sfsb_node_%1d.stimulus.trace.in", file_prefix, dest_id_p);
    $sformat(response_file_name, "%sfsb_node_%1d.response.trace.in", file_prefix, dest_id_p);

    stimulus_file = $fopen( stimulus_file_name, "w");
    response_file = $fopen( response_file_name, "w");
    if (!stimulus_file) begin
        $display("Could not open %s", stimulus_file_name);
        $finish();
    end
    if (!response_file) begin
        $display("Could not open %s", response_file_name);
        $finish();
    end

end

// the couter of the cycles between two packets.
wire cond_send  = en_i & v_o_i & yumi_i_i;
wire cond_recv  = en_i & v_i_i & ready_o_i;

wire [counter_width_lp -1 : 0 ]      stimulus_delay_cycles, response_delay_cycles;

//did the first packed send ?
//logic first_packet_r ;
//always_ff@( posedge clk_i ) begin
//    if( reset_i )                               first_packet_r <= 1'b0;
//    else if ( cond_send &  (! first_packet_r) ) first_packet_r <= 1'b1;
//end

bsg_counter_clear_up #( .max_val_p     ( (1 << counter_width_lp) -1 )
                       ,.init_val_p    ( 0 )
    ) stimulus_delay_cnt (
          .clk_i
  //      , .reset_i ( reset_i |  (!first_packet_r) )
        , .reset_i

        , .clear_i ( cond_send  )
        , .up_i    ( ! cond_send )

        , .count_o ( stimulus_delay_cycles )
    );

// display the  packet from rocket
always@( posedge clk_i) begin
    if ( (reset_i === 1'b0)  & en_i & v_i_i  & ready_o_i) begin
        $fdisplay(response_file, "#", $time, "\tfrom rocket:\t%020h", data_i_i);
        $fdisplay(response_file, "#          trace_cmd4____destid4_switch1_data75");
        $fdisplay(response_file, "%4b____%4b_%1b_%75b",T_CMD_RECV, data_i_i.destid, data_i_i.cmd, data_i_i.data);
    end
end

// display the input packet
always@( posedge clk_i) begin
    if ( (reset_i === 1'b0)  & cond_send ) begin
         //set up the counter and wait counter
        if( stimulus_delay_cycles > counter_width_lp'(1) ) begin
            $fdisplay(stimulus_file, "# Delay Cycles=%d, Setup Counter=%d", stimulus_delay_cycles,  stimulus_delay_cycles- 2 );
            $fdisplay(stimulus_file, "%4b____%4b_%1b_%75b",T_CMD_ICNT, data_o_i.destid, data_o_i.cmd, 75'(stimulus_delay_cycles- 2) );

            $fdisplay(stimulus_file, "# Wait Counter" );
            $fdisplay(stimulus_file, "%4b____%4b_%1b_%75b",T_CMD_WCNT, data_o_i.destid, data_o_i.cmd, 75'(0) );
        end else if ( stimulus_delay_cycles > counter_width_lp'(0)) begin
            $fdisplay(stimulus_file, "# Wait 1 cycle" );
            $fdisplay(stimulus_file, "%4b____%4b_%1b_%75b",T_CMD_NOP, data_o_i.destid, data_o_i.cmd, 75'(0) );
        end
        $fdisplay(stimulus_file, "#", $time, "\tto rocket:\t%020h", data_o_i);
        $fdisplay(stimulus_file, "#          trace_cmd4____destid4_switch1_data75");
        $fdisplay(stimulus_file, "%4b____%4b_%1b_%75b",T_CMD_SEND, data_o_i.destid, data_o_i.cmd, data_o_i.data);
    end
end


endmodule
