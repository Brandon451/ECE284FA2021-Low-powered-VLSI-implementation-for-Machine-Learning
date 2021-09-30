// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 


module sfp_tb;

parameter bw = 4;
parameter psum_bw = 16;

reg clk = 0;

wire [psum_bw-1:0] out;
reg  [psum_bw-1:0] expected_out = 0;
reg  [bw-1:0] in;
reg  relu;
reg  acc;
reg  reset;

integer in_file ; // file handler
integer in_scan_file ; // file handler

integer in_dec;
integer i; 
integer u; 

function [3:0] dec2bin ;
  input integer  weight ;
  begin

    if (weight>-1)
     dec2bin[3] = 0;
    else begin
     dec2bin[3] = 1;
     weight = weight + 8;
    end

    if (weight>3) begin
     dec2bin[2] = 1;
     weight = weight - 4;
    end
    else 
     dec2bin[2] = 0;

    if (weight>1) begin
     dec2bin[1] = 1;
     weight = weight - 2;
    end
    else 
     dec2bin[1] = 0;

    if (weight>0) 
     dec2bin[0] = 1;
    else 
     dec2bin[0] = 0;

  end
endfunction


sfp #(.psum_bw(psum_bw)) sfp_instance (
	.clk(clk), 
	.reset(reset), 
        .in(in),
        .acc(acc), 
        .relu(relu),
	.out(out)
); 
 

initial begin 

  in_file = $fopen("in_data.txt", "r"); 

  $dumpfile("sfp_tb.vcd");
  $dumpvars(0,sfp_tb);
 
  #1 clk = 1'b0;  reset = 1; relu = 0; acc = 0;
  #1 clk = 1'b1;  
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;  reset = 0;

  $display("-------------------- Computation start --------------------");
  

  for (i=0; i<10; i=i+1) begin  // Data lenght is 10 in the data files

     #1 clk = 1'b1;
     #1 clk = 1'b0; acc = 1;

     in_scan_file = $fscanf(in_file, "%d\n", in_dec);
     in = dec2bin(in_dec); 

  end

  #1 clk = 1'b1;
  #1 clk = 1'b0; acc = 0; relu = 1;
  #1 clk = 1'b1;  
  #1 clk = 1'b0;  

  $display("-------------------- Computation completed --------------------");

  #10 $finish;


end

endmodule




