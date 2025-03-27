`include "test_five.vh"

extern "A" void htif_fini(input reg failure);

`HTIF_TICK_DEFINITION(0, `HTIF_WIDTH)
`HTIF_TICK_DEFINITION(1, `HTIF_WIDTH)
`HTIF_TICK_DEFINITION(2, `HTIF_WIDTH)
`HTIF_TICK_DEFINITION(3, `HTIF_WIDTH)
`HTIF_TICK_DEFINITION(4, `HTIF_WIDTH)

`MEMORY_TICK_DEFINITION(0, `MEM_ADDR_BITS, `MEM_ID_BITS, `MEM_STRB_BITS, `MEM_DATA_BITS)
`MEMORY_TICK_DEFINITION(1, `MEM_ADDR_BITS, `MEM_ID_BITS, `MEM_STRB_BITS, `MEM_DATA_BITS)
`MEMORY_TICK_DEFINITION(2, `MEM_ADDR_BITS, `MEM_ID_BITS, `MEM_STRB_BITS, `MEM_DATA_BITS)
`MEMORY_TICK_DEFINITION(3, `MEM_ADDR_BITS, `MEM_ID_BITS, `MEM_STRB_BITS, `MEM_DATA_BITS)
`MEMORY_TICK_DEFINITION(4, `MEM_ADDR_BITS, `MEM_ID_BITS, `MEM_STRB_BITS, `MEM_DATA_BITS)

module test_five;

  import bsg_rocket_pkg::*;

  reg [31:0] seed;
  initial seed = $get_initial_random_seed();

  //-----------------------------------------------
  // Instantiate the processor

  reg reset = 1'b1;
  reg r_reset;
  reg start = 1'b0;

  // bsg clk

  // FIXME: not all rockets have a manycore
  `ifndef MANYCORE_CLOCK_PERIOD_PS
    `define MANYCORE_CLOCK_PERIOD_PS 20
  `endif

  wire clk, io_clk;
  wire manycore_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`CORE_CLOCK_PERIOD_PS)) cc (.o(clk));
  bsg_nonsynth_clock_gen #(.cycle_time_p(`IO_CLOCK_PERIOD_PS)) ioc (.o(io_clk));
  bsg_nonsynth_clock_gen #(.cycle_time_p(`MANYCORE_CLOCK_PERIOD_PS)) mcc (.o(manycore_clk));

  // bsg async reset
   // mbt reduce for simulation time
   localparam reset_cycles_hi_lp = 250;

  //localparam reset_cycles_hi_lp = 1280;
  localparam reset_cycles_lo_lp = 16;

  wire gateway_async_reset;

  bsg_nonsynth_reset_gen #
    (.num_clocks_p(2)
    ,.reset_cycles_lo_p(reset_cycles_lo_lp)
    ,.reset_cycles_hi_p(reset_cycles_hi_lp))
  reset_gen
    (.clk_i({clk, io_clk})
    ,.async_reset_o(gateway_async_reset));

  reg [  31:0] n_mem_channel = `N_MEM_CHANNELS;
  reg [  31:0] htif_width = `HTIF_WIDTH;
  reg [  31:0] mem_width = `MEM_DATA_BITS;
  reg [  63:0] max_cycles = 0;
  reg [  63:0] total_cycle_count = 0;
  reg [  63:0] trace_count = 0;
  reg [1023:0] vcdplusfile = 0;
  reg [1023:0] vcdfile = 0;
  reg          stats_active = 0;
  reg          stats_tracking = 0;
  integer      stderr = 32'h80000002;

  logic mem_verbose = 0;
  logic htif_verbose = 0;

  wire boot_done;

  localparam num_rockets_gp = 5;

  // test_five.vfrag has the wiring htif_tick and memory_tick to test_five_system
  `include "test_five.vfrag"

  always @(posedge clk)
  begin
    r_reset <= reset;
  end

  test_five_system #
    (.num_rockets_gp(num_rockets_gp))
  dut
    // clk
    (.core_clk_i(clk)
    ,.io_clk_i(io_clk)
    ,.manycore_clk_i(manycore_clk)
    // ctrl
    ,.reset(reset)
    ,.gateway_async_reset_i(gateway_async_reset)
    ,.boot_done_o(boot_done)
    // host in
    ,.host_valid_i(h2r_valid_d)
    ,.host_data_i(h2r_data_d)
    ,.host_ready_o(h2r_ready_d)
    // host out
    ,.host_valid_o(r2h_valid_d)
    ,.host_data_o(r2h_data_d)
    ,.host_ready_i(r2h_ready_d)
    // aw out
    ,.nasti_aw_valid_o(nasti_aw_valid_d)
    ,.nasti_aw_data_o(nasti_aw_data_d)
    ,.nasti_aw_ready_i(nasti_aw_ready_d)
    // w out
    ,.nasti_w_valid_o(nasti_w_valid_d)
    ,.nasti_w_data_o(nasti_w_data_d)
    ,.nasti_w_ready_i(nasti_w_ready_d)
    // b in
    ,.nasti_b_valid_i(nasti_b_valid_d)
    ,.nasti_b_data_i(nasti_b_data_d)
    ,.nasti_b_ready_o(nasti_b_ready_d)
    // ar out
    ,.nasti_ar_valid_o(nasti_ar_valid_d)
    ,.nasti_ar_data_o(nasti_ar_data_d)
    ,.nasti_ar_ready_i(nasti_ar_ready_d)
    // r in
    ,.nasti_r_valid_i(nasti_r_valid_d)
    ,.nasti_r_data_i(nasti_r_data_d)
    ,.nasti_r_ready_o(nasti_r_ready_d));

  logic [31:0] h2r_exit [num_rockets_gp-1:0] = {{0}, {0}, {0}, {0}, {0}};

  // rocket enable bit vector
  //logic [num_rockets_gp-1:0] r2h_en = `ROCKET_EN_BIT_VECTOR;
  logic [num_rockets_gp-1:0] r2h_en = {num_rockets_gp {1'b0}};

  // rocket exit barrier
  logic [num_rockets_gp-1:0] rocket_exit_barrier_r;

  integer       rid          ;
  logic   [7:0] rocket_id_str;

  initial
  begin

    r2h_en = {num_rockets_gp {1'b0}};

    for(rid = 0; rid < num_rockets_gp; rid = rid + 1)
    begin
      rocket_id_str = "0" + rid;
      if ($test$plusargs({"enable_rocket_", rocket_id_str}))
      begin
        r2h_en[rid] = 1'b1;
      end
    end

    $display("r2h_en = %b", r2h_en);

  end

  `HTIF_TICK_INSTANCE(r2h, h2r, 0)
  `HTIF_TICK_INSTANCE(r2h, h2r, 1)
  `HTIF_TICK_INSTANCE(r2h, h2r, 2)
  `HTIF_TICK_INSTANCE(r2h, h2r, 3)
  `HTIF_TICK_INSTANCE(r2h, h2r, 4)

  `MEMORY_TICK_INSTANCE(nasti, 0)
  `MEMORY_TICK_INSTANCE(nasti, 1)
  `MEMORY_TICK_INSTANCE(nasti, 2)
  `MEMORY_TICK_INSTANCE(nasti, 3)
  `MEMORY_TICK_INSTANCE(nasti, 4)

  // mem_verbose is activated via Makefile as vcs-argument +mem_verbose
  // htif_verbose is activated via Makefile as vcs-argument +htif_verbose

  for (i = 0; i < num_rockets_gp; i++) begin

    // memory traffic
    always @(posedge clk) begin
      if (mem_verbose) begin

        if (nasti_ar_valid_d[i] && nasti_ar_ready_d[i])
          $fdisplay(stderr, "MC[%1d]: ar addr=%x id=%x size=%x len=%x"
          ,i
          ,nasti_ar_data_d[i].addr
          ,nasti_ar_data_d[i].id
          ,nasti_ar_data_d[i].size
          ,nasti_ar_data_d[i].len);

        if (nasti_aw_valid_d[i] && nasti_aw_ready_d[i])
          $fdisplay(stderr, "MC[%1d]: aw addr=%x id=%x size=%x len=%x"
          ,i
          ,nasti_aw_data_d[i].addr
          ,nasti_aw_data_d[i].id
          ,nasti_aw_data_d[i].size
          ,nasti_aw_data_d[i].len);

        if (nasti_w_valid_d[i] && nasti_w_ready_d[i])
          $fdisplay(stderr, "MC[%1d]: w data=%x", i, nasti_w_data_d[i].data);

        if (nasti_r_valid_d[i] && nasti_r_ready_d[i])
          $fdisplay(stderr, "MC[%1d]: r data=%x", i, nasti_r_data_d[i].data);

      end
    end

    // host traffic
    always @(posedge clk) begin
      if (htif_verbose) begin

        if (h2r_valid_d[i] && h2r_ready_d[i])
          $fdisplay(stderr, "H2R[%1d]: %04x", i, h2r_data_d[i]);

        if (r2h_valid_d[i] && r2h_ready_d[i])
          $fdisplay(stderr, "R2H[%1d]: %04x", i, r2h_data_d[i]);

      end
    end

    // resets
    //always @(negedge dut.chip.g.n[i].clnt.r2f.rocket.uncore_io_htif_0_reset)
    //  $fdisplay(stderr, "ROCKET[%1d]: DEASSERT RESET", i);

    always @(posedge clk) begin
      if (reset | r_reset)
        rocket_exit_barrier_r[i] <= 1'b0;
      else if (h2r_exit[i] == 1 && rocket_exit_barrier_r[i] == 1'b0) begin
        rocket_exit_barrier_r[i] <= 1'b1;
        $fdisplay(stderr, "ROCKET[%1d]: DONE", i);
      end
    end

  end

  //-----------------------------------------------
  // Start the simulation

  // Some helper functions for turning on, stopping, and finishing stat tracking
  task start_stats;
  begin
    if(!reset || !stats_active)
      begin
`ifdef DEBUG
      if(vcdplusfile)
      begin
        $vcdpluson(0);
        $vcdplusmemon(0);
      end
      if(vcdfile)
      begin
        $dumpon;
      end
`endif
      assign stats_tracking = 1;
    end
  end
  endtask
  task stop_stats;
  begin
`ifdef DEBUG
    $vcdplusoff; $dumpoff;
`endif
    assign stats_tracking = 0;
  end
  endtask
`ifdef DEBUG
`define VCDPLUSCLOSE $vcdplusclose; $dumpoff;
`else
`define VCDPLUSCLOSE
`endif

  // Read input arguments and initialize
  initial
  begin
    $value$plusargs("max-cycles=%d", max_cycles);
    mem_verbose = $test$plusargs("mem_verbose");
    htif_verbose = $test$plusargs("htif_verbose");
`ifdef DEBUG
    stats_active = $test$plusargs("stats");
    if ($value$plusargs("vcdplusfile=%s", vcdplusfile))
    begin
      $vcdplusfile(vcdplusfile);
    end
    if ($value$plusargs("vcdfile=%s", vcdfile))
    begin
      $dumpfile(vcdfile);
      $dumpvars(0, dut);
    end
    if (!stats_active)
    begin
      start_stats;
    end
    else
    begin
      if(vcdfile)
      begin
        $dumpoff;
      end
    end
`endif

    // Strobe reset
    wait (~boot_done);
    wait (boot_done) reset = 0;

  end

  reg [255:0] reason = 0;
  always @(posedge clk) begin

    if (max_cycles > 0 && trace_count > max_cycles)
      reason = "timeout";

    if (h2r_exit[0] > 1)
      $sformat(reason, "tohost = %d", h2r_exit[0] >> 1);

    if (reason)
    begin
      $fdisplay(stderr, "FAILED (%s) after %d simulation cycles", reason, total_cycle_count);
      $display("\n");
      $display("*** FAIL (reason = %s)", reason);
      $display("*** Simulated %d active cycles out of %d total cycles.", trace_count, total_cycle_count);
      `VCDPLUSCLOSE
      htif_fini(1'b1);
    end

    if (rocket_exit_barrier_r == r2h_en) begin
      `VCDPLUSCLOSE
      $fdisplay(stderr, "SIMULATION DONE: total-cycles:%d and trace-cycles:%d", total_cycle_count, trace_count);
      $display("\n");
      $display("*** PASS");
      $display("*** Simulated %d active cycles out of %d total cycles.", trace_count, total_cycle_count);
      htif_fini(1'b0);
    end

  end

  //-----------------------------------------------
  // Tracing code

  always @(posedge clk)
  begin
    if(stats_active)
    begin
      if(!stats_tracking)
      begin
        start_stats;
      end
      if(stats_tracking)
      begin
        stop_stats;
      end
    end
  end

  always @(posedge clk)
  begin
    total_cycle_count = total_cycle_count + 1;
    if (reset || r_reset)
    begin
      trace_count = 0;
    end
    begin
      trace_count = trace_count + 1;
    end
  end

endmodule
