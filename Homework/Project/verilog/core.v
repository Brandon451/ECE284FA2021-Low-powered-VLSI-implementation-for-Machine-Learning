//This module includes the corelet and external memory

module core (
    clk,
    reset
);

parameter bw = 4;
parameter psum_bw = 16;
parameter col = 8;
parameter row = 8;

input clk;
input reset;

sram_32b_w2048 #(
    .num(2048)
) sram_32b_w2048_instance (
    .CLK(clk),
    .WEN(//!),
    .CEN(//!),
    .D(//!),
    .A(//!),
    .Q(//!)
);

corelet #(
    .bw(bw),
    .psum_bw(psum_bw),
    .row(row),
    .col(col)
) corelet_instance (
    .clk(clk),
    .reset(reset),
    .out(//!)
);

endmodule