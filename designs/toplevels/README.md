    bsg_two_loopback                  - bsg_comm_link with loopback module and finalized UCSD BGA Pad Ring
    bsg_two_loopback_clk_gen          - "" with clock generator and bsg_tag. Taped out Oct 2016.
    bsg_two_tag_ram                   - simple design with bsg_tag and one ram. for testing ram flow.
    bsg_two_manycore_vanilla          - 2-core manycore design, with bsg_comm_link and bsg_channel_tunnel
    bsg_two_manycore_vanilla_clk_gen  - 10-core version of "", with bsg_comm_link, bsg_channel_tunnel and clock generator. Taped out Dec 22, 2016.
    bsg_two_loopback_new              - loopback with refactored, FPGA-compatible code via Luis.
    bsg_two_alpaca                    - single rocket core, with bsg_comm_link, nasti converter, and bsg_channel_tunnel
    bsg_two_bison_XXXX                - bsg_two_alpaca+rocc+XXXX accelerator
    bsg_two_coyote_XXXX_YYYY_...      - bsg_two_alpaca+rocc_pulled_to_top_level (+ XXXX accelerator (+ YYYY accelerator ... ) )
