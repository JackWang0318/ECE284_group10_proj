// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
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

wire [48:0] inst_q; 

reg [1:0]  inst_w_q = 0; 
reg [bw*row-1:0] D_xmem_q = 0;
reg [bw*row-1:0] D_wmem_q = 0;
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
reg CEN_wmem = 1;
reg WEN_wmem = 1;
reg CEN_wmem_q = 1;
reg WEN_wmem_q = 1;
reg [10:0] A_wmem = 0;
reg [10:0] A_wmem_q = 0;
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
reg relu = 0;
reg relu_q = 0;
reg mode = 1;
reg mode_q = 1;

reg [1:0]  inst_w; 
reg [bw*row-1:0] D_xmem;
reg [bw*col-1:0] D_wmem;
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
wire [psum_bw-1:0] os_s_out;
wire [bw*col-1:0] in_n_weight;
wire [psum_bw*col*row-1:0] os_out_array;

integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer captured_data; 
integer t, i, j, k, kij;
integer error;

assign inst_q[48] = mode_q;
assign inst_q[47] = relu_q;
assign inst_q[46] = acc_q;
assign inst_q[45] = CEN_wmem_q;
assign inst_q[44] = WEN_wmem_q;
assign inst_q[43:33] = A_wmem_q;
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

// os_result_reader  os_result_reader_instance (
//   .clk(clk), 
//   .out(os_s_out),
//   .os_out_array(os_out_array),
//   .reset(reset));
core  #(.bw(bw), .col(col), .row(row)) core_instance (
	.clk(clk), 
	.inst(inst_q),
	.ofifo_valid(ofifo_valid),
  .d_xmem(D_xmem_q), 
  .sfp_out(sfp_out), 
  .d_wmem(D_wmem_q),
  .os_out_array(os_out_array),
	.reset(reset)); 


initial begin 

  inst_w   = 0; 
  D_xmem   = 0;
  CEN_xmem = 1;
  WEN_xmem = 1;
  A_xmem   = 0;
  D_wmem   = 0;
  CEN_wmem = 1;
  WEN_wmem = 1;
  A_wmem   = 0;
  ofifo_rd = 0;
  ififo_wr = 0;
  ififo_rd = 0;
  l0_rd    = 0;
  l0_wr    = 0;
  execute  = 0;
  load     = 0;
  mode     = 1;

  $dumpfile("core_tb.vcd");
  $dumpvars(0,core_tb);

  x_file = $fopen("activation_os.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);

  //////// Reset /////////
  #0.5 clk = 1'b0;   reset = 1;
  #0.5 clk = 1'b1; 

  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;   reset = 0;
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0;   
  #0.5 clk = 1'b1;   
  /////////////////////////

  /////// Activation data writing to memory ///////
  for (t=0; t<27; t=t+1) begin  
    #0.5 clk = 1'b0;  
    x_scan_file = $fscanf(x_file,"%32b", D_xmem); 
    WEN_xmem = 0; 
    CEN_xmem = 0; 
    if (t>0) A_xmem = A_xmem + 1;
    #0.5 clk = 1'b1;   
  end

  #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b1; 

  $fclose(x_file);
  ///////////////////////////////////////////////////////////////////////////////////////

  w_file_name = "weight_os.txt";
  w_file = $fopen(w_file_name, "r");
  // Following three lines are to remove the first three comment lines of the file
  w_scan_file = $fscanf(w_file,"%s", captured_data);
  w_scan_file = $fscanf(w_file,"%s", captured_data);
  w_scan_file = $fscanf(w_file,"%s", captured_data);

  //////// Reset /////////
  #0.5 clk = 1'b0;   reset = 1;
  #0.5 clk = 1'b1; 

  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;   reset = 0;
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0;   
  #0.5 clk = 1'b1;   

  /////// Kernel data writing to memory ///////

  for (t=0; t<27; t=t+1) begin  
    #0.5 clk = 1'b0;  
    w_scan_file = $fscanf(w_file,"%32b", D_wmem); 
    WEN_wmem = 0; 
    CEN_wmem = 0; 
    if (t>0) A_wmem = A_wmem + 1; 
    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  WEN_wmem = 1;  CEN_wmem = 1; A_wmem = 0;
  #0.5 clk = 1'b1; 
  $fclose(w_file);
  /////////////////////////////////////

  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end

/////////////////////////////////////////////////////..........................................................................
  WEN_xmem = 1; // Xmem read enable
  CEN_xmem = 0; // Xmem chip enable
  l0_wr = 1;    // L0 write enable
  l0_rd = 0;    // L0 read disable
  A_xmem = 0;   // address set to the start of kernel data

  for (i=0; i<27; i=i+1) begin
    #0.5 clk = 1'b0;
    A_xmem = A_xmem + 1; 
    #0.5 clk = 1'b1; 
  end

  #0.5 clk = 1'b0;
  l0_wr = 0;    // L0 write disable
  #0.5 clk = 1'b1;
  
  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end
  /////////////////////////////////////////////////////////
  WEN_wmem = 1; // Xmem read enable
  CEN_wmem = 0; // Xmem chip enable
  ififo_wr = 1;    // L0 write enable
  ififo_rd = 0;    // L0 read disable
  A_wmem = 0;   // address set to the start of kernel data

  for (i=0; i<27; i=i+1) begin
    #0.5 clk = 1'b0;
    A_wmem = A_wmem + 1; 
    #0.5 clk = 1'b1; 
  end

  #0.5 clk = 1'b0;
  ififo_wr = 0;    // L0 write disable
  #0.5 clk = 1'b1;
  
  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;
////////////////////////EXECUTE/////////////////////////////..........................................................................
  l0_rd=1;
  ififo_rd=1;
  #0.5 clk = 1'b1;

  for(i=0; i<28; i=i+1) begin
    #0.5 clk = 1'b0;
    execute = 1;
    #0.5 clk = 1'b1;
  end

  #0.5 clk = 1'b0;  
  execute = 0;      // execute ends
  l0_rd = 0;        // L0 read disable
  ififo_rd = 0;
  #0.5 clk = 1'b1;  

    for (i=0; i<50 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end

  /////////////////////////////////////
 

  // for (kij=0; kij<9; kij=kij+1) begin  // kij loop ...............................................................................
  
  //   for (i=0; i<10 ; i=i+1) begin
  //     #0.5 clk = 1'b0;
  //     #0.5 clk = 1'b1;  
  //   end
  //   /////// Kernel data writing to L0 ///////

  //   WEN_wmem = 1; // wmem read enable
  //   CEN_wmem = 0; // wmem chip enable
  //   ififo_wr = 1;    // L0 write enable
  //   ififo_rd = 0;    // L0 read disable
  //   A_wmem = 11'b0;   // address set to the start of kernel data

  //   for (i=0; i<col; i=i+1) begin
	// 		#0.5 clk = 1'b0;
	// 		if (t>0) A_wmem = A_wmem + 1; 
	// 		#0.5 clk = 1'b1; 
	// 	end

  //   #0.5 clk = 1'b0;
  //   ififo_wr = 0;    // L0 write disable
  //   #0.5 clk = 1'b1;

  //   for (i=0; i<10 ; i=i+1) begin
  //     #0.5 clk = 1'b0;
  //     #0.5 clk = 1'b1;  
  //   end

  //   #0.5 clk = 1'b0;
  //   /////////////////////////////////////



  //   /////// Kernel loading to PEs ///////
  //   // l0_rd = 1;  // L0 read enable
  //   // #0.5 clk = 1'b1;

  //   // for (i=0; i<col; i=i+1) begin
	// 	// 	#0.5 clk = 1'b0;
	// 	// 	load = 1;
	// 	// 	#0.5 clk = 1'b1; 
	// 	// end

  //   /////////////////////////////////////
  


  //   ////// provide some intermission to clear up the kernel loading ///
  //   // #0.5 clk = 1'b0;  load = 0; l0_rd = 0;
  //   // #0.5 clk = 1'b1;  
  

  //   for (i=0; i<10 ; i=i+1) begin
  //     #0.5 clk = 1'b0;
  //     #0.5 clk = 1'b1;  
  //   end
  //   /////////////////////////////////////



  //   /////// Activation data writing to L0 ///////
    
  //   WEN_xmem = 1; // Xmem read enable
  //   CEN_xmem = 0; // Xmem chip enable
  //   l0_wr = 1;    // L0 write enable
  //   l0_rd = 0;    // L0 read disable
  //   A_xmem = 0;   // address set to the start of kernel data

  //   for (i=0; i<len_nij; i=i+1) begin
	// 		#0.5 clk = 1'b0;
	// 		if (t>0) A_xmem = A_xmem + 1; 
	// 		#0.5 clk = 1'b1; 
	// 	end

  //   #0.5 clk = 1'b0;
  //   l0_wr = 0;    // L0 write disable
  //   #0.5 clk = 1'b1;
    
  //   for (i=0; i<10 ; i=i+1) begin
  //     #0.5 clk = 1'b0;
  //     #0.5 clk = 1'b1;  
  //   end

  //   #0.5 clk = 1'b0;
  //   /////////////////////////////////////



  //   /////// Execution ///////
  //   l0_rd = 1;    // L0 read enable
  //   #0.5 clk = 1'b1;

  //   for (i=0; i<len_nij; i=i+1) begin
	// 		#0.5 clk = 1'b0;
	// 		execute = 1;      // execute
	// 		#0.5 clk = 1'b1; 
	// 	end

  //   for (i=0; i<row+col ; i=i+1) begin
  //       #0.5 clk = 1'b0;
  //       #0.5 clk = 1'b1;  
  //   end

  //   #0.5 clk = 1'b0;  
  //   execute = 0;      // execute ends
  //   l0_rd = 0;        // L0 read disable
  //   #0.5 clk = 1'b1;  
  //   /////////////////////////////////////



  //   //////// OFIFO READ ////////
  //   // Ideally, OFIFO should be read while execution, but we have enough ofifo
  //   // depth so we can fetch out after execution.
    
  //   #0.5 clk = 1'b0;
  //   ofifo_rd = 1;     // OFIFO read enable
  //   #0.5 clk = 1'b1;

  //   for (t=0; t<len_nij+1; t=t+1) begin  
  //     #0.5 clk = 1'b0;
	// 		WEN_pmem = 0;
	// 		CEN_pmem = 0;
	// 		if (t>0) A_pmem = A_pmem + 1; 
  //     #0.5 clk = 1'b1;  
  //   end

  //   #0.5 clk = 1'b0;  
  //   WEN_pmem = 1;  
  //   CEN_pmem = 1; 
  //   ofifo_rd = 0;
  //   #0.5 clk = 1'b1;

  //   for (i=0; i<10 ; i=i+1) begin
  //     #0.5 clk = 1'b0;
  //     #0.5 clk = 1'b1;  
  //   end

  //   /////////////////////////////////////

  //   $display("No. %d execution completed.", kij);

  // end  // end of kij loop


  for (t=0; t<10; t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
  end
  
  out_file = $fopen("output_os.txt", "r");  

  // Following three lines are to remove the first three comment lines of the file
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 

  error = 0;
  $display("############ Verification Start during accumulation #############"); 

  // for (i=0; i<len_onij+1; i=i+1) begin 
  //   #0.5 clk = 1'b0; 
  //   #0.5 clk = 1'b1; 
  //   out_scan_file = $fscanf(out_file,"%128b", answer);
  //   if (os_s_out == answer)
  //       $display("%2d-th output featuremap Data matched! :D", i); 
  //   else begin
  //     $display("%2d-th output featuremap Data ERROR!!", i); 
  //     $display("os_out: %16b", os_s_out);
  //     $display("answer: %16b", answer);
  //     error = 1;
  //   end
  // end
  // for (i=0; i<8; i=i+1) begin 
    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
    out_scan_file = $fscanf(out_file,"%128b", answer);
    if (os_out_array[127:0] == answer)
        $display("%2d-th output featuremap Data matched! :D", 0); 
    else begin
      $display("%2d-th output featuremap Data ERROR!!", 0); 
      $display("os_outs: %128b", os_out_array[127:0]);
      $display("answers: %128b", answer);
      error = 1;
    end

    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
    out_scan_file = $fscanf(out_file,"%128b", answer);
    if (os_out_array[255:128] == answer)
        $display("%2d-th output featuremap Data matched! :D", 1); 
    else begin
      $display("%2d-th output featuremap Data ERROR!!", 1); 
      $display("os_outs: %128b", os_out_array[255:128]);
      $display("answers: %128b", answer);
      error = 1;
    end

    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
    out_scan_file = $fscanf(out_file,"%128b", answer);
    if (os_out_array[383:256] == answer)
        $display("%2d-th output featuremap Data matched! :D", 2); 
    else begin
      $display("%2d-th output featuremap Data ERROR!!", 2); 
      $display("os_outs: %128b", os_out_array[383:256]);
      $display("answers: %128b", answer);
      error = 1;
    end

    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
    out_scan_file = $fscanf(out_file,"%128b", answer);
    if (os_out_array[511:384] == answer)
        $display("%2d-th output featuremap Data matched! :D", 3); 
    else begin
      $display("%2d-th output featuremap Data ERROR!!", 3); 
      $display("os_outs: %128b", os_out_array[511:384]);
      $display("answers: %128b", answer);
      error = 1;
    end

    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
    out_scan_file = $fscanf(out_file,"%128b", answer);
    if (os_out_array[639:512] == answer)
        $display("%2d-th output featuremap Data matched! :D", 4); 
    else begin
      $display("%2d-th output featuremap Data ERROR!!", 4); 
      $display("os_outs: %128b", os_out_array[639:512]);
      $display("answers: %128b", answer);
      error = 1;
    end
    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
    out_scan_file = $fscanf(out_file,"%128b", answer);
    if (os_out_array[767:640] == answer)
        $display("%2d-th output featuremap Data matched! :D", 5); 
    else begin
      $display("%2d-th output featuremap Data ERROR!!", 5); 
      $display("os_outs: %128b", os_out_array[767:640]);
      $display("answers: %128b", answer);
      error = 1;
    end

    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
    out_scan_file = $fscanf(out_file,"%128b", answer);
    if (os_out_array[895:768] == answer)
        $display("%2d-th output featuremap Data matched! :D", 6); 
    else begin
      $display("%2d-th output featuremap Data ERROR!!", 6); 
      $display("os_outs: %128b", os_out_array[895:768]);
      $display("answers: %128b", answer);
      error = 1;
    end

    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
    out_scan_file = $fscanf(out_file,"%128b", answer);
    if (os_out_array[1023:896] == answer)
        $display("%2d-th output featuremap Data matched! :D", 7); 
    else begin
      $display("%2d-th output featuremap Data ERROR!!", 7); 
      $display("os_outs: %128b", os_out_array[1023:896]);
      $display("answers: %128b", answer);
      error = 1;
    end
  // end

  if (error == 0) begin
  	$display("############ No error detected ##############"); 
  	$display("########### Project Completed !! ############"); 

  end
  #10 $finish;

end


always @ (posedge clk) begin
   inst_w_q   <= inst_w; 
   D_xmem_q   <= D_xmem;
   CEN_xmem_q <= CEN_xmem;
   WEN_xmem_q <= WEN_xmem;
   A_xmem_q   <= A_xmem;
   D_wmem_q   <= D_wmem;
   CEN_wmem_q <= CEN_wmem;
   WEN_wmem_q <= WEN_wmem;
   A_wmem_q   <= A_wmem;
   CEN_pmem_q <= CEN_pmem;
   WEN_pmem_q <= WEN_pmem;
   A_pmem_q   <= A_pmem;
   ofifo_rd_q <= ofifo_rd;
   acc_q      <= acc;
   ififo_wr_q <= ififo_wr;
   ififo_rd_q <= ififo_rd;
   l0_rd_q    <= l0_rd;
   l0_wr_q    <= l0_wr ;
   execute_q  <= execute;
   load_q     <= load;
   relu_q     <= relu;
   mode_q     <= mode;
end


endmodule





//act -> sram (32 * 27)
//weight -> sram (32 * 27)

// for(27){
    //load act -> l0
    //load weight -> l0

    
    //execute
      // read for l0
// }


