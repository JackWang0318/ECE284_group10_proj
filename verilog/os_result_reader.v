// helper to read s_output_array from mac_array
// every clock, i = i + psum_bw, out = s_output_array[i+psum_bw-1:i]

module os_result_reader (
  input clk,
  input reset,
  input [psum_bw*col*row-1:0] os_out_array,
  output [15:0] out
);
    parameter psum_bw = 16;
    parameter col = 8;
    parameter row = 8;
    reg [31:0] i_reg;
    reg [15:0] out_reg;

    always @(posedge clk) begin
        out_reg[0] = os_out_array[i_reg];
        out_reg[1] = os_out_array[i_reg+1];
        out_reg[2] = os_out_array[i_reg+2];
        out_reg[3] = os_out_array[i_reg+3];
        out_reg[4] = os_out_array[i_reg+4];
        out_reg[5] = os_out_array[i_reg+5];
        out_reg[6] = os_out_array[i_reg+6];
        out_reg[7] = os_out_array[i_reg+7];
        out_reg[8] = os_out_array[i_reg+8];
        out_reg[9] = os_out_array[i_reg+9];
        out_reg[10] = os_out_array[i_reg+10];
        out_reg[11] = os_out_array[i_reg+11];
        out_reg[12] = os_out_array[i_reg+12];
        out_reg[13] = os_out_array[i_reg+13];
        out_reg[14] = os_out_array[i_reg+14];
        out_reg[15] = os_out_array[i_reg+15];
        if (reset) 
            i_reg = 0;
        else i_reg = i_reg + psum_bw;
    end

    assign out = out_reg;
endmodule