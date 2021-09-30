// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 


module mac_tb;

parameter bw = 4;
parameter psum_bw = 16;

reg clk = 0;

reg  [bw-1:0] a;
reg  [bw-1:0] b;
reg  [psum_bw-1:0] c;
wire [psum_bw-1:0] out;
reg  [psum_bw-1:0] expected_out = 0;

integer w_file ; // file handler
integer w_scan_file ; // file handler

integer x_file ; // file handler
integer x_scan_file ; // file handler

integer x_dec;
integer w_dec;
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




// Below function is for verification
function [psum_bw-1:0] mac_predicted;
  
  input signed [bw-1:0] a, b;
  input signed [psum_bw-1:0] c;
  reg signed [2*bw-1:0] product;
  reg signed [psum_bw-1:0] psum;
 
  begin 
    product = a * b;
    mac_predicted =  product + c;
  end 
endfunction



mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
	.clk(clk), 
        .a(a), 
        .b(b),
        .c(c),
	.out(out)
); 
 

initial begin 

  w_file = $fopen("b_data.txt", "r");  //weight data
  x_file = $fopen("a_data.txt", "r");  //activation

  $dumpfile("mac_tb.vcd");
  $dumpvars(0,mac_tb);
 
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;

  $display("-------------------- Computation start --------------------");
  

  for (i=0; i<10; i=i+1) begin  // Data lenghh is 10 in the data files

     #1 clk = 1'b1;
     #1 clk = 1'b0;

     w_scan_file = $fscanf(w_file, "%d\n", w_dec);
     x_scan_file = $fscanf(x_file, "%d\n", x_dec);

     a = dec2bin(x_dec); 
     b = dec2bin(w_dec); 
     c = expected_out;

     expected_out = mac_predicted(a, b, c);

  end


  #1 clk = 1'b1;
  #1 clk = 1'b0;

  $display("-------------------- Computation completed --------------------");

  #10 $finish;


end

endmodule




