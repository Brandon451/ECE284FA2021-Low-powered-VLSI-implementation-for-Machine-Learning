// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sfp (out, in, acc, relu, clk, reset);

parameter bw = 4;
parameter psum_bw = 16;

input clk;
input acc;
input relu;
input reset;
input   signed [bw-1:0] in;
output  signed [psum_bw-1:0] out;

reg     signed [psum_bw-1:0] psum_q;
wire    signed [psum_bw-1:0] psum_relu;

...

endmodule
