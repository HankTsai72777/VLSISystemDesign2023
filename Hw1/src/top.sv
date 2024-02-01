`include "cpu.sv"
`include "SRAM_wrapper.sv"
module top(
    input clk, rst
);

logic [13:0]    IM_addr;
logic [31:0]    IM_out;

logic [13:0]    DM_addr;
logic [31:0]    DM_in, DM_out;
logic [3:0]     DM_wen;

cpu CPU1 (
    .clk        (clk),
    .rst        (rst),
    .IM_addr    (IM_addr),
    .IM_out     (IM_out),
    .DM_wen     (DM_wen),
    .DM_addr    (DM_addr),
    .DM_in      (DM_in),
    .DM_out     (DM_out)
);

SRAM_wrapper IM1 (
    .CK     (clk),
    .CS     (1'b1),
    .OE     (1'b1),
    .WEB    (4'b1111),
    .A      (IM_addr),
    .DI     (32'd0),
    .DO     (IM_out)
);

SRAM_wrapper DM1 (
    .CK     (clk),
    .CS     (1'b1),
    .OE     (1'b1),
    .WEB    (DM_wen),
    .A      (DM_addr),
    .DI     (DM_in),
    .DO     (DM_out)
);

endmodule