//This module includes the MAC, FIFO, L0 and SPF

module corelet(
    clk,
    reset,
    inst_w_mac,
    l0_in,
    l0_rd,
    l0_wr,
    l0_full,
    l0_ready,
    ofifo_rd,
    ofifo_full,
    ofifo_ready,
    ofifo_valid,
    ofifo_out
)

parameter bw = 4;
parameter psum_bw = 16;
parameter col = 8;
parameter row = 8;

input clk;
input reset;

input [1:0] inst_w_mac;

input [bw*row-1:0] l0_in;
input l0_rd;
input l0_wr;
output l0_full;
output l0_ready;

input ofifo_rd;
output ofifo_full;
output ofifo_ready;
output ofifo_valid;

output [bw*col-1:0] ofifo_out;

wire [psum_bw*col-1:0] out_s_mac;
wire [bw*row-1:0] in_w_mac;

wire [psum_bw*col-1:0] in_n_mac;
wire [col-1:0] valid_mac;

mac_array #(
    .bw(bw),
    .psum_bw(psum_bw),
    .row(row),
    .col(col)
) mac_array_instance(
    .clk(clk),
    .reset(reset),
    .out_s(out_s_mac),
    .in_w(in_w_mac),
    .in_n(0),
    .inst_w(inst_w_mac),
    .valid(valid_mac)
);

l0 #(
    .bw(bw),
    .row(row)
) l0_instance(
    .clk(clk),
    .wr(l0_wr),
    .rd(l0_rd),
    .reset(reset),
    .in(l0_in),
    .out(in_w_mac),
    .o_full(l0_full),
    .o_ready(l0_ready)
);

ofifio #(
    .bw(bw),
    .col(col)
) ofifio_instance(
    .clk(clk),
    .wr(valid_mac),
    .rd(ofifo_rd),
    .reset(reset),
    .in(out_s_mac),
    .out(ofifo_out),
    .o_full(ofifo_full),
    .o_ready(ofifo_ready),
    .o_valid(ofifo_valid)
);

// genvar i;
// for (i=1; i< col+1; i=i+1) begin: col_num
//     sfp #(
//         .bw(bw),
//         .psum_bw(psum_bw)
//     ) sfp_instance (
//         .clk(clk),
//         .reset(reset),
//         .acc(//!),
//         .relu(//!),
//         .in(out_s_array[psum_bw*i-1 : psum_bw*(i-1)]),
//         .out(out_s_spf[psum_bw*i-1 : psum_bw*(i-1)])
//     );
// end

endmodule