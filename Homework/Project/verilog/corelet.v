//This module includes the MAC, FIFO, L0 and SPF

module corelet(
    clk,
    reset,
    out
)

parameter bw = 4;
parameter psum_bw = 16;
parameter col = 8;
parameter row = 8;

input clk;
input reset;
output [psum_bw*col-1:0] out;

wire [psum_bw*col-1:0] out_s_array;
wire [row*bw-1:0] in_w_array; // inst[1]:execute, inst[0]: kernel loading
wire [1:0] inst_w_array;
wire [psum_bw*col-1:0] in_n_array;
wire [col-1:0] valid_array;

wire [psum_bw*col-1:0] out_s_spf;

mac_array #(
    .bw(bw),
    .psum_bw(psum_bw),
    .row(row),
    .col(col)
) mac_array_instance(
    .clk(clk),
    .reset(reset),
    .inst_w(inst_w_array),
    .out_s(out_s_array),
    .in_w(in_w_array),
    in_n(in_n_array),
    .valid(valid_array)
);

l0 #(
    .bw(bw),
    .row(row)
) l0_instance(
    .clk(clk),
    .wr(//!),
    .rd(//!),
    .reset(reset),
    .in(//!),
    .out(in_w),
    .ofull(//!),
    .oready(//!)
);

ofifio #(
    .bw(bw),
    .col(col)
) ofifio_instance(
    .clk(clk),
    .wr(//!),
    .rd(//!),
    .reset(reset),
    .in(out_s_spf),
    .out(out),
    .o_full(//!),
    .o_ready(//!),
    .o_valid(//!)
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