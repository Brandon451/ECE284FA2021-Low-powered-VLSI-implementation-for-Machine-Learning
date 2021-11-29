//Core module contains corelet, xmemory (activation and weight) and pmemory (output)
//? clk - Master clock
//? reset - Master reset, high enable
//? inst[33:0] - All extra signals
//?     33 - Accumalate
//?     32 - PMemory chip enable
//?     31 - PMemory write enable
//?     30:20 - PMemory address
//?     19 - XMemory chip enable
//?     18 - XMemory write enable
//?     17:7 - XMemory address
//?     6 - ofifo_rd
//?     5 - ififo_wr
//?     4 - ififo_rd
//?     3 - l0_rd
//?     2 - l0_wr
//?     1 - execute
//?     0 - load
//? D_xmem - Data to be written into x memory
//? ofifo_valid - ofifo_valid signal
//? sfp_out - sfp output signal

module core #(
    parameter row = 8,
    parameter col = 8,
    parameter psum_bw = 16,
    parameter bw = 4
)(
    input clk,
    input reset,    //High enable
    input [33:0] inst,
    input [bw*row-1:0] D_xmem,
    output ofifo_valid,
    output [psum_bw*col-1:0] sfp_out
);

wire corelet_clk;
wire corelet_reset;
wire [33:0] corelet_inst;
wire [bw*row-1:0] corelet_data_in;
wire [psum_bw*col-1:0] corelet_data_in_acc;
wire [psum_bw*col-1:0] corelet_data_out;
wire [psum_bw*col-1:0] corelet_sfp_data_out;

assign corelet_clk = clk;
assign corelet_reset = reset;
assign corelet_inst = inst[33:0];
assign corelet_data_in_acc = pmem_data_out;
assign corelet_data_in = xmem_data_out;
assign sfp_out = corelet_sfp_data_out;
//!assign corelet_data_out;

//Instantiate corelet
corelet #(
    .row(row),
    .col(col),
    .psum_bw(psum_bw),
    .bw(bw)
) corelet_insts (
    .clk(corelet_clk),
    .reset(corelet_reset),
    .inst(corelet_inst),
    .data_in(corelet_data_in),
    .data_in_acc(corelet_data_in_acc),
    .data_out(corelet_data_out),
    .sfp_data_out(corelet_sfp_data_out)
);

wire xmem_clk;
wire xmem_chip_en;
wire xmem_wr_en;
wire [10:0] xmem_addr_in;
wire [31:0] xmem_data_in;
wire [31:0] xmem_data_out;

assign xmem_clk = clk;
assign xmem_chip_en = inst[19];
assign xmem_wr_en = inst[18];
assign xmem_addr_in = inst[17:7];
assign xmem_data_in = D_xmem;

//Instantiate xmemory
sram_32b_w2048 #(
    .num(2048),
    .width(32)
) Xmemory_inst (
    .clk(xmem_clk),
    .data_in(xmem_data_in),
    .data_out(xmem_data_out),
    .chip_en(xmem_chip_en),
    .wr_en(xmem_wr_en),
    .addr_in(xmem_addr_in)
);

wire pmem_clk;
wire [127:0] pmem_data_in;
wire [127:0] pmem_data_out;
wire pmem_chip_en;
wire pmem_wr_en;
wire [10:0] pmem_addr_in;

assign pmem_clk = clk;
assign pmem_data_in = corelet_data_out;
//!assign pmem_data_out;
assign pmem_chip_en = inst[32];
assign pmem_wr_en = inst[31];
assign pmem_addr_in = inst[30:20];

//Instantiate pmemory
sram_32b_w2048 #(
    .num(2048),
    .width(128)
) Pmemory_inst (
    .clk(pmem_clk),
    .data_in(pmem_data_in),
    .data_out(pmem_data_out),
    .chip_en(pmem_chip_en),
    .wr_en(pmem_wr_en),
    .addr_in(pmem_addr_in)
);

endmodule