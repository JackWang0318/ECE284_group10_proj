// Contributed by Hongjie Wang
// Special Functional Unit module 
// Accumulation in SFU and store back to psum SRAM
// ReLU in SFU and store back to psum SRAM

module sfu (out, in, acc, relu, clk, reset, in_valid, out_valid);

parameter bw = 4;
parameter psum_bw = 16;
parameter out_nij = 16;

input clk;
input acc;
input in_valid;
input relu;
input reset;
input signed [psum_bw-1:0] in;
output signed [psum_bw-1:0] out;
input out_valid;

reg signed [psum_bw-1:0] psum_q;

reg signed [psum_bw-1:0] reg_bank [out_nij-1:0];
reg [5:0] in_ptr;
reg [5:0] out_ptr;

integer i;

wire [psum_bw-1:0] reg0;
  wire [psum_bw-1:0] reg1;
  wire [psum_bw-1:0] reg2;
  wire [psum_bw-1:0] reg3;
  wire [psum_bw-1:0] reg4;
  wire [psum_bw-1:0] reg5;
  wire [psum_bw-1:0] reg6;
  wire [psum_bw-1:0] reg7;
  wire [psum_bw-1:0] reg8;
  wire [psum_bw-1:0] reg9;
  wire [psum_bw-1:0] reg10;
  wire [psum_bw-1:0] reg11;
  wire [psum_bw-1:0] reg12;
  wire [psum_bw-1:0] reg13;
  wire [psum_bw-1:0] reg14;
  wire [psum_bw-1:0] reg15;

  assign reg0 = reg_bank[0];
  assign reg1 = reg_bank[1];
  assign reg2 = reg_bank[2];
  assign reg3 = reg_bank[3];
  assign reg4 = reg_bank[4];
  assign reg5 = reg_bank[5];
  assign reg6 = reg_bank[6];
  assign reg7 = reg_bank[7];
  assign reg8 = reg_bank[8];
  assign reg9 = reg_bank[9];
  assign reg10 = reg_bank[10];
  assign reg11 = reg_bank[11];
  assign reg12 = reg_bank[12];
  assign reg13 = reg_bank[13];
  assign reg14 = reg_bank[14];
  assign reg15 = reg_bank[15];

initial begin
  for (i = 0; i < out_nij; i = i + 1) begin
    reg_bank[i] = 0;
  end

  in_ptr <= 0;
  out_ptr <= 0;
end

always @(posedge clk) begin
    if (reset == 1) begin 
        psum_q <= 0;
        // in_ptr <= 0;
        // out_ptr <= 0;
        // for (i = 0; i < out_nij; i = i + 1) begin
        //     reg_bank[i] <= 0;
        // end
    end
    else if (in_valid == 1) begin
        reg_bank[in_ptr] <=  reg_bank[in_ptr] + in;
        if(in_ptr == (out_nij - 1))
            in_ptr <= 0;
        else
            in_ptr <= in_ptr + 1;
    end
    else if (out_valid) begin
      psum_q <= (reg_bank[out_ptr] > 0) ? reg_bank[out_ptr] : 0;
      if(out_ptr == (out_nij - 1))
        out_ptr <= 0;
      else
        out_ptr <= out_ptr + 1;
      end

    // else begin
    //     if (acc == 1)
    //         psum_q <= psum_q + in;
    //     else if (relu == 1)
    //         psum_q <= (psum_q > 0) ? psum_q : 0;
    //     else
    //     psum_q <= psum_q;
    // end
        
end

assign out = psum_q;

endmodule
