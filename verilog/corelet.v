module corelet(clk, reset, inst, data_to_l0, l0_rd, l0_wr, l0_full, l0_ready, ofifo_rd, ofifo_full, ofifo_ready, ofifo_valid, psum_out, data_sram_to_sfu, accumulate, relu, data_out, mode, in_n_weight, os_out_array);
	parameter bw = 4;
	parameter psum_bw = 16;
	parameter col = 8;
	parameter row = 8;

    input clk, reset;
    input [1:0] inst; //inst [1:0] = {execute, kernel loading} 
    input [bw*row-1:0] data_to_l0;
    input l0_rd, l0_wr;
    output l0_full, l0_ready;
    

    input ofifo_rd;
    output ofifo_full, ofifo_ready, ofifo_valid;
    output [psum_bw*col-1:0] psum_out; //data from ofifo to SRAM

    input [psum_bw*col-1:0] data_sram_to_sfu; //data from SRAM to sfu
    input accumulate, relu; //control signals for sfu
    output [psum_bw*col-1:0] data_out; //final output

    input mode;
    input [psum_bw*col-1:0] in_n_weight; //data from ififo to mac_array (output stationary); = 0 if weight stationary
    output [psum_bw*col*row-1:0] os_out_array; //output stationary
    


    wire [psum_bw*col-1:0] mac_out; //data from mac_array to ofifo
    wire [col-1:0] mac_out_valid; //valid from mac_array to ofifo

    wire [row*bw-1:0] data_out_l0; //data from l0 to mac_array

    wire [psum_bw*col-1:0] in_n;

    assign in_n = (mode == 0) ? 128'b0 : in_n_weight_out;




//L0 for input activation
    l0 #(.row(row), .bw(bw)) l0_instance (
        .clk(clk),
        .reset(reset),
        .in(data_to_l0),
        .out(data_out_l0),
        .rd(l0_rd),
        .wr(l0_wr),
        .o_full(l0_full),
        .o_ready(l0_ready)
    );
    
//TODO: L0 for weights
// l0 #(.row(row), .bw(bw)) l0_weight_instance (
//         .clk(clk),
//         .reset(reset),
//         .in(in_n_weight),
//         .out(in_n_weight_out),
//         .rd(),
//         .wr(),
//         .o_full(),
//         .o_ready()
//     );

    mac_array #(.bw(bw), .psum_bw(psum_bw), .col(col), .row(row)) mac_array_instance (
        .clk(clk),
        .reset(reset),
        .in_w(data_out_l0),
        .in_n(in_n),
        .inst_w(inst[1:0]),
        .out_s(mac_out),
        .valid(mac_out_valid),
        .mode(mode),
        .os_out_array(os_out_array)
    );


    ofifo #(.col(col), .psum_bw(psum_bw)) ofifo_instance (
        .clk(clk),
        .wr(mac_out_valid),
        .rd(ofifo_rd),
        .reset(reset),
        .in(mac_out),
        .out(psum_out),
        .o_full(ofifo_full),
        .o_ready(ofifo_ready),
        .o_valid(ofifo_valid)
    );

    genvar i;

    for (i=1; i<col+1; i=i+1) begin : sfu_num
        sfu #(.bw(bw), .psum_bw(psum_bw)) sfu_instance (
            .clk(clk),
            .acc(accumulate),
            .relu(relu),
            .reset(reset),
            .in(data_sram_to_sfu[psum_bw*i-1 : psum_bw*(i-1)]),
            .out(data_out[psum_bw*i-1 : psum_bw*(i-1)])
        );
    end

endmodule
