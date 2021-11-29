// Created by Brandon Saldanha
module sram_32b_w2048 #(
	parameter num = 2048,
	parameter width = 32
)(
	input clk,
	input [width-1:0] data_in,
	output [width-1:0] data_out,
	input chip_en,			//Low enable
	input wr_en,			//Low enable
	input [10:0] addr_in
);

reg [width-1:0] memory [num-1:0];
reg [10:0] add_q;
assign data_out = memory[add_q];

always @ (posedge clk) begin
	if (!chip_en && wr_en) // read 
    	add_q <= addr_in;

   	if (!chip_en && !wr_en) // write
      	memory[addr_in] <= data_in; 
end

integer idx;
initial begin
	$dumpfile("core_tb.vcd");
	for(idx = 0; idx < num; idx = idx+1) begin: register
		$dumpvars(0, memory[idx]);
	end
end


endmodule
