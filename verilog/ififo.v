// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module ififo (clk, in, out, rd, wr, o_full, reset, o_ready);

	parameter col  = 8;
	parameter bw = 4;

	input  clk;
	input  wr;
	input  rd;
	input  reset;
	input  [col*bw-1:0] in;
	output [col*bw-1:0] out;
	output o_full;
	output o_ready;

	wire [col-1:0] empty;
	wire [col-1:0] full;
	reg [col-1:0] rd_en;
  
	genvar i;

	assign o_ready = (| full ==  0) ? 1:0;
	assign o_full  = (| full == 1) ? 1:0;

  	for (i=0; i<col ; i=i+1) begin : col_num
      	fifo_depth64 #(.bw(bw)) fifo_instance (
	 		.rd_clk(clk),
	 		.wr_clk(clk),
	 		.rd(rd_en[i]),
	 		.wr(wr),
         	.o_empty(empty[i]),
         	.o_full(full[i]),
	 		.in(in[bw*(i+1) - 1:bw*i]),
	 		.out(out[bw*(i+1) - 1:bw*i]),
         	.reset(reset)
		);
  	end

  	always @ (posedge clk) begin
   		if (reset) begin
      		rd_en <= 8'b00000000;
   		end
   		else begin

      //////////////// version2: read 1 col at a time /////////////////
		rd_en <= {rd_en[col-2:0], rd};

        // rd_en[0] <= rd; 
		// rd_en[1] <= rd_en[0]; 
		// rd_en[2] <= rd_en[1]; 
		// rd_en[3] <= rd_en[2]; 
		// rd_en[4] <= rd_en[3]; 
		// rd_en[5] <= rd_en[4]; 
		// rd_en[6] <= rd_en[5]; 
		// rd_en[7] <= rd_en[6]; 
      ///////////////////////////////////////////////////////
		end
    end

endmodule
