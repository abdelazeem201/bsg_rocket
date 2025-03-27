`ifndef TEST_FIVE_VH
`define TEST_FIVE_VH

`define HTIF_TICK_DEFINITION(i, width) \
extern "A" void htif_``i``_tick        \
  (input  reg              en_i        \
  ,input  reg              valid_i     \
  ,input  reg  [width-1:0] data_i      \
  ,output reg              ready_o     \
  ,output reg              valid_o     \
  ,output reg  [width-1:0] data_o      \
  ,input  reg              ready_i     \
  ,output reg  [31:0]      exit_o);


`define HTIF_TICK_INSTANCE(i_prefix, o_prefix, i) \
  always @(posedge clk) begin                     \
    if (reset || r_reset) begin                   \
      ``o_prefix``_valid[i] <= 1'b0;              \
      ``i_prefix``_ready[i] <= 1'b0;              \
      ``o_prefix``_exit[i] <= '0;                 \
    end                                           \
    else begin                                    \
      htif_``i``_tick                             \
        (``i_prefix``_en[i]                       \
        ,``i_prefix``_valid[i]                    \
        ,``i_prefix``_data[i]                     \
        ,``i_prefix``_ready[i]                    \
        ,``o_prefix``_valid[i]                    \
        ,``o_prefix``_data[i]                     \
        ,``o_prefix``_ready[i]                    \
        ,``o_prefix``_exit[i]);                   \
    end                                           \
  end

`define MEMORY_TICK_DEFINITION(i, addr_width, id_width, strb_width, data_width) \
extern "A" void memory_``i``_tick         \
  (input  reg                  aw_valid_i \
  ,input  reg [addr_width-1:0] aw_addr_i  \
  ,input  reg   [id_width-1:0] aw_id_i    \
  ,input  reg            [2:0] aw_size_i  \
  ,input  reg            [7:0] aw_len_i   \
  ,output reg                  aw_ready_o \
  ,input  reg                  w_valid_i  \
  ,input  reg [strb_width-1:0] w_strb_i   \
  ,input  reg [data_width-1:0] w_data_i   \
  ,input  reg                  w_last_i   \
  ,output reg                  w_ready_o  \
  ,output reg                  b_valid_o  \
  ,output reg            [1:0] b_resp_o   \
  ,output reg   [id_width-1:0] b_id_o     \
  ,input  reg                  b_ready_i  \
  ,input  reg                  ar_valid_i \
  ,input  reg [addr_width-1:0] ar_addr_i  \
  ,input  reg   [id_width-1:0] ar_id_i    \
  ,input  reg            [2:0] ar_size_i  \
  ,input  reg            [7:0] ar_len_i   \
  ,output reg                  ar_ready_o \
  ,output reg                  r_valid_o  \
  ,output reg            [1:0] r_resp_o   \
  ,output reg   [id_width-1:0] r_id_o     \
  ,output reg [data_width-1:0] r_data_o   \
  ,output reg                  r_last_o   \
  ,input  reg                  r_ready_i);


`define MEMORY_TICK_INSTANCE(prefix, i) \
  always @(posedge clk) begin   \
    if (reset || r_reset) begin \
      ``prefix``_aw_ready[i] <= 1'b0; \
      ``prefix``_w_ready[i] <= 1'b0; \
      ``prefix``_b_valid[i] <= 1'b0; \
      ``prefix``_b_data[i] <= 0; \
      ``prefix``_ar_ready[i] <= 1'b0;  \
      ``prefix``_r_valid[i] <= 1'b0; \
      ``prefix``_r_data[i] <= 0; \
    end \
    else begin \
      memory_``i``_tick \
        (``prefix``_aw_valid[i] \
        ,``prefix``_aw_data_addr[i] \
        ,``prefix``_aw_data_id[i] \
        ,``prefix``_aw_data_size[i] \
        ,``prefix``_aw_data_len[i] \
        ,``prefix``_aw_ready[i] \
        ,``prefix``_w_valid[i] \
        ,``prefix``_w_data_strb[i] \
        ,``prefix``_w_data_data[i] \
        ,``prefix``_w_data_last[i] \
        ,``prefix``_w_ready[i] \
        ,``prefix``_b_valid[i] \
        ,``prefix``_b_data[i].resp \
        ,``prefix``_b_data[i].id \
        ,``prefix``_b_ready[i] \
        ,``prefix``_ar_valid[i] \
        ,``prefix``_ar_data_addr[i] \
        ,``prefix``_ar_data_id[i] \
        ,``prefix``_ar_data_size[i] \
        ,``prefix``_ar_data_len[i] \
        ,``prefix``_ar_ready[i] \
        ,``prefix``_r_valid[i] \
        ,``prefix``_r_data[i].resp \
        ,``prefix``_r_data[i].id \
        ,``prefix``_r_data[i].data \
        ,``prefix``_r_data[i].last \
        ,``prefix``_r_ready[i]); \
    end \
  end

`endif // TEST_FIVE_VH
