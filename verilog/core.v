module core #(
    parameter row = 8,
    parameter col = 8,
    parameter psum_bw = 16,
    parameter bw = 4
)(
    input clk,
    input reset,
    input [48:0] inst,
    input [bw*row-1:0] d_xmem,
    output ofifo_valid,
    output [psum_bw*col-1:0] sfp_out,

    input [bw*col-1:0] d_wmem, // -> sram -> in_n_weight
    // input mode, // inst[35]
    output [psum_bw*col*row-1:0] os_out_array

);

wire [bw*row-1:0] data_in;
wire [psum_bw*col-1:0] acc_in;
wire [psum_bw*col-1:0] data_out;
wire [psum_bw*col-1:0] spf_out;

wire [bw*col-1:0] in_n_weight;  // sram(wmem) to ififo

assign acc_in = pmem_data_out;
assign data_in = xmem_data_out;
assign sfp_out = spf_out;

wire [31:0] xmem_data_out;

sram_32b_w2048 #(
    .num(2048)
) xmemory_inst (
    .clk(clk),
    .D(d_xmem),
    .Q(xmem_data_out),
    .CEN(inst[19]),
    .WEN(inst[18]),
    .A(inst[17:7])
);

// new sram - weight to ififo
sram_32b_w2048 #(
    .num(2048)
) wmemory_inst (
    .clk(clk),
    .D(d_wmem),
    .Q(in_n_weight),
    .CEN(inst[45]),
    .WEN(inst[44]),
    .A(inst[43:33])
);

wire [127:0] pmem_data_in;
wire [127:0] pmem_data_out;

sram_32b_w2048 #(
    .num(2048),
    .width(128)
) pmemory_inst (
    .clk(clk),
    .D(data_out),
    .Q(pmem_data_out),
    .CEN(inst[32]),
    .WEN(inst[31]),
    .A(inst[30:20])
);

corelet #(
    .row(row),
    .col(col),
    .psum_bw(psum_bw),
    .bw(bw)
) corelet_insts (
    .clk(clk),
    .reset(reset),
    .inst(inst[1:0]),
    .data_to_l0(data_in),
    .l0_rd(inst[3]),
    .l0_wr(inst[2]),
    .l0_full(),
    .l0_ready(),
    .in_n_weight(in_n_weight),
    .ififo_rd(inst[4]),
    .ififo_wr(inst[5]),
    .ififo_full(),
    .ififo_ready(),
    .ofifo_rd(inst[6]),
    .ofifo_full(),
    .ofifo_ready(),
    .ofifo_valid(ofifo_valid),
    .psum_out(data_out),
    .data_sram_to_sfu(acc_in),
    .accumulate(inst[46]),
    .relu(inst[47]),
    .data_out(spf_out),
    .os_out_array(os_out_array),
    .mode(inst[48])
);

endmodule
