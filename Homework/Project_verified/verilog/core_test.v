//This module includes the corelet and external memory

module core (
    clk,
    reset,
    address,
    data_in,
    memory_write,
    mac_inst,
    l0_rd,
    l0_wr,
    l0_full,
    l0_ready,
    ofifo_rd,
    ofifo_full,
    ofifo_ready,
    ofifo_valid
);

parameter bw = 4;
parameter psum_bw = 16;
parameter col = 8;
parameter row = 8;

input clk;
input reset;
input [10:0] address;
input [31:0] data_in;
input [1:0] mac_instn;
input l0_rd;
input l0_wr;
input l0_full;
input l0_ready;
input ofifo_rd;
input ofifo_full;
input ofifo_ready;
input ofifo_valid;

wire [31:0] data_out;

sram_32b_w2048 #(
    .num(2048)
) sram_32b_w2048_instance (
    .CLK(clk),
    .WEN(memory_write),
    .CEN(0),
    .D(data_in),
    .A(address),
    .Q(data_out)
);

corelet #(
    .bw(bw),
    .psum_bw(psum_bw),
    .row(row),
    .col(col)
) corelet_instance (
    .clk(clk),
    .reset(reset),
    .inst_w_mac(mac_instn),
    .l0_in(data_out),
    .l0_rd(l0_rd),
    .l0_wr(l0_wr),
    .l0_full(//!),
    .l0_ready(//!),
    .ofifo_rd(//!),
    .ofifo_full(//!),
    .ofifo_ready(//!),
    .ofifo_valid(//!),
    .ofifo_out(//!)
);

endmodule