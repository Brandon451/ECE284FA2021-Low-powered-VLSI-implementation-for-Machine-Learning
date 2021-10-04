// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sfp (out, in, acc, relu, clk, reset);

parameter bw = 4;
parameter psum_bw = 16;

input clk;
input acc;
input relu;
input reset;
input signed [bw-1:0] in;
output signed [psum_bw-1:0] out;

reg [psum_bw-1:0]extend_in;

reg signed [psum_bw-1:0] psum_q;
wire signed [psum_bw-1:0] psum_relu;

always @(posedge clk) begin
    if (reset == 1)
        psum_q <= 0;
    else begin
        if (acc == 1)
        psum_q <= psum_q + {{(psum_bw-bw){in[bw-1]}}, in};
    end
        
end

assign psum_relu = (psum_q>0)? psum_q : 0;

//psum_q = acc? psum_q + In : psum_q;
//assign psum_relu = (psum_q>0)? psum_q : 0;

assign out = psum_q;

endmodule
