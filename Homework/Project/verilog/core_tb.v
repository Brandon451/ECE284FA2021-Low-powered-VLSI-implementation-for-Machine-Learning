// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
// Modified by Brandon Saldanha

/*
//*What's happening:
Activation file has 36*8 (number of elements in channel * number of channels)
Each element is 4 bits wide
And we store 4bits * 8(number of channels) = 32bits in a line (of the .txt file)
Store these acxtivation values in Xmemory from address 11'b0
Weights are stored differently:
Each index in the weight matrix is stored along with the same index in other channels






*/


`timescale 1ns/1ps

module core_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter len_onij = 16;
parameter col = 8;
parameter row = 8;
parameter len_nij = 36;

reg clk = 0;
reg reset = 1;

wire [33:0] inst_q; 

reg [1:0]  inst_w_q = 0; 
reg [bw*row-1:0] D_xmem_q = 0;
reg CEN_xmem = 1;
reg WEN_xmem = 1;
reg [10:0] A_xmem = 0;
reg CEN_xmem_q = 1;
reg WEN_xmem_q = 1;
reg [10:0] A_xmem_q = 0;
reg CEN_pmem = 1;
reg WEN_pmem = 1;
reg [10:0] A_pmem = 0;
reg CEN_pmem_q = 1;
reg WEN_pmem_q = 1;
reg [10:0] A_pmem_q = 0;
reg ofifo_rd_q = 0;
reg ififo_wr_q = 0;
reg ififo_rd_q = 0;
reg l0_rd_q = 0;
reg l0_wr_q = 0;
reg execute_q = 0;
reg load_q = 0;
reg acc_q = 0;
reg acc = 0;

reg [1:0]  inst_w; 
reg [bw*row-1:0] D_xmem;
reg [psum_bw*col-1:0] answer;


reg ofifo_rd;
reg ififo_wr;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg execute;
reg load;
reg [8*30:1] stringvar;
reg [8*30:1] w_file_name;
wire ofifo_valid;
wire [col*psum_bw-1:0] sfp_out;

integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer captured_data; 
integer t, i, j, k, kij;
integer error;

assign inst_q[33] = acc_q;
assign inst_q[32] = CEN_pmem_q;
assign inst_q[31] = WEN_pmem_q;
assign inst_q[30:20] = A_pmem_q;
assign inst_q[19]   = CEN_xmem_q;
assign inst_q[18]   = WEN_xmem_q;
assign inst_q[17:7] = A_xmem_q;
assign inst_q[6]   = ofifo_rd_q;
assign inst_q[5]   = ififo_wr_q;
assign inst_q[4]   = ififo_rd_q;
assign inst_q[3]   = l0_rd_q;
assign inst_q[2]   = l0_wr_q;
assign inst_q[1]   = execute_q; 
assign inst_q[0]   = load_q; 


core #(
	.bw(bw),
	.col(col),
	.row(row)
) core_instance (
	.clk(clk), 
	.inst(inst_q),
	.ofifo_valid(ofifo_valid),
    .D_xmem(D_xmem_q), 
    .sfp_out(sfp_out), 
	.reset(reset)
); 

initial begin 

	inst_w   = 0; 
	D_xmem   = 0;
	CEN_xmem = 1;
	WEN_xmem = 1;
	A_xmem   = 0;
	ofifo_rd = 0;
	ififo_wr = 0;
	ififo_rd = 0;
	l0_rd    = 0;
	l0_wr    = 0;
	execute  = 0;
	load     = 0;

	$dumpfile("core_tb.vcd");
	$dumpvars(0,core_tb);

  	//x_file = $fopen("activation_tile0.txt", "r");
	x_file = $fopen("./text_files/activation/activation_bin.txt", "r");
  	// Following three lines are to remove the first three comment lines of the file
  	x_scan_file = $fscanf(x_file,"%s", captured_data);
  	x_scan_file = $fscanf(x_file,"%s", captured_data);
  	x_scan_file = $fscanf(x_file,"%s", captured_data);

	//? Reset
  	#0.5 clk = 1'b0;   reset = 1;
  	#0.5 clk = 1'b1; 

	for (i=0; i<10 ; i=i+1) begin
    	#0.5 clk = 1'b0;
    	#0.5 clk = 1'b1;  
  	end

	#0.5 clk = 1'b0;	reset = 0;
  	#0.5 clk = 1'b1; 

  	#0.5 clk = 1'b0;   
  	#0.5 clk = 1'b1;

  	//? Activation data writing to memory
  	for (t=0; t<len_nij; t=t+1) begin  
  		#0.5 clk = 1'b0;
		x_scan_file = $fscanf(x_file, "%32b", D_xmem);
		WEN_xmem = 0;
		CEN_xmem = 0;
		if (t>0) A_xmem = A_xmem + 1;
  		#0.5 clk = 1'b1;   
  	end

	#0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
	#0.5 clk = 1'b1; 

	$fclose(x_file);

	for (kij=0; kij<9; kij=kij+1) begin  // kij loop
	//*for (kij=0; kij<2; kij=kij+1) begin  // kij loop
		case(kij)
     		// 0: w_file_name = "weight_itile0_otile0_kij0.txt";
     		// 1: w_file_name = "weight_itile0_otile0_kij1.txt";
    		// 2: w_file_name = "weight_itile0_otile0_kij2.txt";
    		// 3: w_file_name = "weight_itile0_otile0_kij3.txt";
    		// 4: w_file_name = "weight_itile0_otile0_kij4.txt";
    		// 5: w_file_name = "weight_itile0_otile0_kij5.txt";
    		// 6: w_file_name = "weight_itile0_otile0_kij6.txt";
    		// 7: w_file_name = "weight_itile0_otile0_kij7.txt";
    		// 8: w_file_name = "weight_itile0_otile0_kij8.txt";

			0: w_file_name = "./text_files/weights/weight0.txt";
			1: w_file_name = "./text_files/weights/weight1.txt";
			2: w_file_name = "./text_files/weights/weight2.txt";
			3: w_file_name = "./text_files/weights/weight3.txt";
			4: w_file_name = "./text_files/weights/weight4.txt";
			5: w_file_name = "./text_files/weights/weight5.txt";
			6: w_file_name = "./text_files/weights/weight6.txt";
			7: w_file_name = "./text_files/weights/weight7.txt";
			8: w_file_name = "./text_files/weights/weight8.txt";
    	endcase

    	w_file = $fopen(w_file_name, "r");
    	// Following three lines are to remove the first three comment lines of the file
    	w_scan_file = $fscanf(w_file,"%s", captured_data);
    	w_scan_file = $fscanf(w_file,"%s", captured_data);
    	w_scan_file = $fscanf(w_file,"%s", captured_data);

    	#0.5 clk = 1'b0;	reset = 1;
    	#0.5 clk = 1'b1; 

    	for (i=0; i<10 ; i=i+1) begin
      		#0.5 clk = 1'b0;
      		#0.5 clk = 1'b1;  
    	end

    	#0.5 clk = 1'b0;	reset = 0;
    	#0.5 clk = 1'b1; 

    	#0.5 clk = 1'b0;   
    	#0.5 clk = 1'b1;   

    	//? Kernel data writing to memory
    	A_xmem = 11'b10000000000;

    	for (t=0; t<col; t=t+1) begin  
      		#0.5 clk = 1'b0;
			w_scan_file = $fscanf(w_file,"%32b", D_xmem);
			WEN_xmem = 0;
			CEN_xmem = 0;
			if (t>0) A_xmem = A_xmem + 1; 
      		#0.5 clk = 1'b1;  
    	end

    	#0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
    	#0.5 clk = 1'b1; 

		//?Gap for verification
		for (i=0; i<10 ; i=i+1) begin
      		#0.5 clk = 1'b0;
      		#0.5 clk = 1'b1;  
    	end

    	//? Kernel data writing to L0
		//Xmem read enable
		WEN_xmem = 1;
		//Xmem chip enable
		CEN_xmem = 0;
		//L0 write enable
		l0_wr = 1;
		//L0 read disable
		l0_rd = 0;
		//Set address to start of kernel data
		A_xmem = 11'b10000000000;

		for (i=0; i<col; i=i+1) begin
			#0.5 clk = 1'b0;
			if (t>0) A_xmem = A_xmem + 1; 
			#0.5 clk = 1'b1; 
		end

		#0.5 clk = 1'b0;
		//L0 write disable
		l0_wr = 0;
		#0.5 clk = 1'b1;

		//?Gap for verification
		for (i=0; i<10 ; i=i+1) begin
      		#0.5 clk = 1'b0;
      		#0.5 clk = 1'b1;  
    	end

		#0.5 clk = 1'b0;
    	//? Kernel loading to PEs
		//L0 read enable
		l0_rd = 1;

		#0.5 clk = 1'b1;

		for (i=0; i<col; i=i+1) begin
			#0.5 clk = 1'b0;
			load = 1;
			#0.5 clk = 1'b1; 
		end

    	// Provide some intermission to clear up the kernel loading
    	#0.5 clk = 1'b0;  load = 0; l0_rd = 0;
    	#0.5 clk = 1'b1;  
  
    	for (i=0; i<10 ; i=i+1) begin
    		#0.5 clk = 1'b0;
    		#0.5 clk = 1'b1;  
    	end


    	//? Activation data writing to L0 ///////
    	//Xmem read enable
		WEN_xmem = 1;
		//Xmem chip enable
		CEN_xmem = 0;
		//L0 write enable
		l0_wr = 1;
		//L0 read disable
		l0_rd = 0;
		//Set address to start of kernel data
		A_xmem = 0;

		for (i=0; i<len_nij; i=i+1) begin
			#0.5 clk = 1'b0;
			if (t>0) A_xmem = A_xmem + 1; 
			#0.5 clk = 1'b1; 
		end

		#0.5 clk = 1'b0;
		//L0 write disable
		l0_wr = 0;
		#0.5 clk = 1'b1;

		//?Gap for verification
		for (i=0; i<10 ; i=i+1) begin
      		#0.5 clk = 1'b0;
      		#0.5 clk = 1'b1;  
    	end

		#0.5 clk = 1'b0;
    	//? Execution
    	//L0 read enable
		l0_rd = 1;

		#0.5 clk = 1'b1;

		for (i=0; i<len_nij; i=i+1) begin
			#0.5 clk = 1'b0;
			execute = 1;
			#0.5 clk = 1'b1; 
		end

		for (i=0; i<row+col ; i=i+1) begin
      		#0.5 clk = 1'b0;
      		#0.5 clk = 1'b1;  
    	end

		// Provide some intermission to clear up the kernel loading
    	#0.5 clk = 1'b0;  execute = 0; l0_rd = 0;
    	#0.5 clk = 1'b1;  

    	//? OFIFO read
    	// Ideally, OFIFO should be read while execution, but we have enough ofifo
    	// depth so we can fetch out after execution.
    	
		#0.5 clk = 1'b0;
		//OFIFO read enable
		ofifo_rd = 1;

		#0.5 clk = 1'b1;

		// for (i=0; i<len_nij+2; i=i+1) begin
		// 	#0.5 clk = 1'b0;
		// 	#0.5 clk = 1'b1; 
		// end

		//? Pmemory write

    	for (t=0; t<len_nij+1; t=t+1) begin  
      		#0.5 clk = 1'b0;
			WEN_pmem = 0;
			CEN_pmem = 0;
			if (t>0) A_pmem = A_pmem + 1; 
      		#0.5 clk = 1'b1;  
    	end

    	#0.5 clk = 1'b0;  WEN_pmem = 1;  CEN_pmem = 1; ofifo_rd = 0;
    	#0.5 clk = 1'b1; 

		for (i=0; i<10 ; i=i+1) begin
      		#0.5 clk = 1'b0;
      		#0.5 clk = 1'b1;  
    	end
		
	$display("Completed execution number: %d", kij);
  	end  // end of kij loop

  ////////// Accumulation /////////
  acc_file = $fopen("./text_files/addr/addr.txt", "r");
  out_file = $fopen("./text_files/output/out.txt", "r");  /// out.txt file stores the address sequence to read out from psum memory for accumulation
                                      /// This can be generated manually or in
                                      /// pytorch automatically

  // Following three lines are to remove the first three comment lines of the file
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 

  error = 0;



  $display("############ Verification Start during accumulation #############"); 

  for (i=0; i<len_onij+1; i=i+1) begin 

    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 

    if (i>0) begin
    	out_scan_file = $fscanf(out_file,"%128b", answer); // reading from out file to answer
       	if (sfp_out == answer)
        	$display("Output featuremap Data number %2d matched! :D", i); 
       	else begin
        	//$display("Output featuremap Data number %2d ERROR!!", i); 
        	$display("sfpout: %128b", sfp_out);
        	//$display("answer: %128b", answer);
        	error = 1;
       	end
    end
   
 
    #0.5 clk = 1'b0; reset = 1;
    #0.5 clk = 1'b1;  
    #0.5 clk = 1'b0; reset = 0; 
    #0.5 clk = 1'b1;  

    for (j=0; j<len_kij+1; j=j+1) begin 
		#0.5 clk = 1'b0;   
        if (j<len_kij) begin
			CEN_pmem = 0;
			WEN_pmem = 1;
			acc_scan_file = $fscanf(acc_file,"%11b", A_pmem);
		end
        else begin
			CEN_pmem = 1;
			WEN_pmem = 1;
		end
        if (j>0)  acc = 1;  
      #0.5 clk = 1'b1;   
    end

    #0.5 clk = 1'b0; acc = 0;
    #0.5 clk = 1'b1; 
  end


  if (error == 0) begin
  	$display("############ No error detected ##############"); 
  	$display("########### Project Completed !! ############"); 

  end

  $fclose(acc_file);
  //////////////////////////////////

  for (t=0; t<10; t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
  end

  #10 $finish;

end

always @ (posedge clk) begin
   inst_w_q   <= inst_w; 
   D_xmem_q   <= D_xmem;
   CEN_xmem_q <= CEN_xmem;
   WEN_xmem_q <= WEN_xmem;
   A_pmem_q   <= A_pmem;
   CEN_pmem_q <= CEN_pmem;
   WEN_pmem_q <= WEN_pmem;
   A_xmem_q   <= A_xmem;
   ofifo_rd_q <= ofifo_rd;
   acc_q      <= acc;
   ififo_wr_q <= ififo_wr;
   ififo_rd_q <= ififo_rd;
   l0_rd_q    <= l0_rd;
   l0_wr_q    <= l0_wr ;
   execute_q  <= execute;
   load_q     <= load;
end

endmodule




