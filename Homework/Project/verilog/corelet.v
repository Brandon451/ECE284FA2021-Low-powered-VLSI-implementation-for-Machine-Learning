//Corelet module contains the MAC array, L0, output FIFO and SFU

//? clk - Master clock
//? reset - Master reset, high enable
//? inst[33:0] - All extra signals
//?     6 - ofifo_rd
//?     5 - ififo_wr
//?     4 - ififo_rd
//?     3 - l0_rd
//?     2 - l0_wr
//?     1 - execute
//?     0 - load

module corelet #(
    parameter row = 8,
    parameter col = 8,
    parameter psum_bw = 16,
    parameter bw = 4
)(
    input clk,
    input reset,
    input [33:0] inst,
    input [bw*row-1:0] data_in,
    input [psum_bw*col-1:0] data_in_acc,
    output [psum_bw*col-1:0] data_out,
    output [psum_bw*col-1:0] sfp_data_out
);

//L0 signals
wire L0_clk;
wire L0_wr;
wire L0_rd;
wire L0_reset;
wire [bw*row-1:0] L0_in;
wire [bw*row-1:0] L0_out;
wire L0_o_full;
wire L0_o_ready;

assign L0_clk = clk;
assign L0_reset = reset;
assign L0_wr = inst[2];
assign L0_rd = inst[3];
assign L0_reset = reset;
assign L0_in = data_in;
//!assign L0_out = ;
assign L0_o_full_out = L0_o_full;
assign L0_o_ready_out = L0_o_ready;

//Instantiate L0
l0 #(
    .row(row),
    .bw(bw)
) L0_inst (
    .clk(L0_clk),
    .wr(L0_wr),
    .rd(L0_rd),
    .reset(L0_reset),
    .in(L0_in),
    .out(L0_out),
    .o_full(L0_o_full),
    .o_ready(L0_o_ready)
);

//MAC signals
wire mac_clk;
wire mac_reset;
wire [psum_bw*col-1:0] mac_out_s;
wire [bw*row-1:0] mac_in_w;
wire [1:0] mac_inst_w;
wire [psum_bw*col-1:0] mac_in_n;
wire [col-1:0] mac_valid;

assign mac_clk = clk;
assign mac_reset = reset;
//!assign mac_out_s = ;
assign mac_in_w = L0_out;
assign mac_inst_w = inst[1:0];
assign mac_in_n = 0;
//!assign mac_valid = ;

//Instantiate MAC
mac_array #(
    .bw(bw),
    .psum_bw(psum_bw),
    .col(col),
    .row(row)
) mac_array_inst (
    .clk(mac_clk),
    .reset(mac_reset),
    .out_s(mac_out_s),
    .in_w(mac_in_w),
    .inst_w(mac_inst_w),
    .in_n(mac_in_n),
    .valid(mac_valid)
);

//OFIFO signals
wire ofifo_clk;
wire ofifo_reset;
wire [col-1:0] ofifo_wr;
wire ofifo_rd;
wire [psum_bw*col-1:0] ofifo_in;
wire [psum_bw*col-1:0] ofifo_out;
wire ofifo_o_full;
wire ofifo_o_ready;
wire ofifo_o_valid;

assign ofifo_clk = clk;
assign ofifo_reset = reset;
assign ofifo_wr = mac_valid;
assign ofifo_rd = inst[6];
assign ofifo_in = mac_out_s;
assign data_out = ofifo_out;
//!assign ofifo_o_full;
//!assign ofifo_o_ready;
//!assign ofifo_o_valid;

//Instantiate OFIFO
ofifo #(
    .col(col),
    .psum_bw(psum_bw)
) ofifo_inst (
    .clk(ofifo_clk),
    .reset(ofifo_reset),
    .wr(ofifo_wr),
    .rd(ofifo_rd),
    .in(ofifo_in),
    .out(ofifo_out),
    .o_full(ofifo_o_full),
    .o_ready(ofifo_o_ready),
    .o_valid(ofifo_o_valid)
);

wire sfp_clk;
wire sfp_acc;
wire sfp_relu;
wire sfp_reset;
wire [psum_bw*col-1:0] sfp_in;
wire [psum_bw*col-1:0] sfp_out;

assign sfp_clk = clk;
assign sfp_acc = inst[33];
assign sfp_relu = 0;
assign sfp_reset = reset;
assign sfp_in = data_in_acc;
assign sfp_data_out = sfp_out;

//Instantiate SFP
genvar i;
for (i=1; i<col+1; i=i+1) begin : sfp_num
    sfp #(
        .bw(bw),
        .psum_bw(psum_bw)
    ) sfp_inst (
        .clk(sfp_clk),
        .acc(sfp_acc),
        .relu(sfp_relu),
        .reset(sfp_reset),
        .in(sfp_in[psum_bw*i-1:psum_bw*(i-1)]),
        .out(sfp_out[psum_bw*i-1:psum_bw*(i-1)])
    );
end

endmodule