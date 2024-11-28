module core #(
    parameter row = 8,
    parameter col = 8,
    parameter psum_bw = 16,
    parameter bw = 4
)(
    input clk,
    input reset,
    input [33:0] inst,
    input [bw*row-1:0] d_xmem,
    output ofifo_valid,
    output [psum_bw*col-1:0] sfp_out
);

wire corelet_clk;
wire corelet_reset;
wire [33:0] corelet_inst;
wire [bw*row-1:0] corelet_data_in;
wire [psum_bw*col-1:0] corelet_data_in_acc;
wire [psum_bw*col-1:0] corelet_data_out;
wire [psum_bw*col-1:0] corelet_sfp_data_out;

assign corelet_clk = clk;
assign corelet_reset = reset;
assign corelet_inst = inst[33:0];
assign corelet_data_in_acc = pmem_data_out;
assign corelet_data_in = xmem_data_out;
assign sfp_out = corelet_sfp_data_out;

wire xmem_clk;
wire xmem_chip_en;
wire xmem_wr_en;
wire [10:0] xmem_addr_in;
wire [31:0] xmem_data_in;
wire [31:0] xmem_data_out;

assign xmem_clk = clk;
assign xmem_chip_en = inst[19];
assign xmem_wr_en = inst[18];
assign xmem_addr_in = inst[17:7];
assign xmem_data_in = d_xmem;

sram_32b_w2048 #(
    .num(2048)
) xmemory_inst (
    .clk(xmem_clk),
    .D(xmem_data_in),
    .Q(xmem_data_out),
    .CEN(xmem_chip_en),
    .WEN(xmem_wr_en),
    .A(xmem_addr_in)
);

wire pmem_clk;
wire [127:0] pmem_data_in;
wire [127:0] pmem_data_out;
wire pmem_chip_en;
wire pmem_wr_en;
wire [10:0] pmem_addr_in;

assign pmem_clk = clk;
assign pmem_data_in = corelet_data_out;
assign pmem_chip_en = inst[32];
assign pmem_wr_en = inst[31];
assign pmem_addr_in = inst[30:20];

sram_32b_w2048 #(
    .num(2048),
    .width(128)
) pmemory_inst (
    .clk(pmem_clk),
    .D(pmem_data_in),
    .Q(pmem_data_out),
    .CEN(pmem_chip_en),
    .WEN(pmem_wr_en),
    .A(pmem_addr_in)
);

corelet #(
    .row(row),
    .col(col),
    .psum_bw(psum_bw),
    .bw(bw)
) corelet_insts (
    .clk(corelet_clk),
    .reset(corelet_reset),
    .inst(corelet_inst[1:0]),
    .data_to_l0(corelet_data_in),
    .l0_rd(inst[3]),
    .l0_wr(inst[2]),
    .l0_full(),
    .l0_ready(),
    .in_n(),
    .ofifo_rd(inst[6]),
    .ofifo_full(),
    .ofifo_ready(),
    .ofifo_valid(ofifo_valid),
    .psum_out(corelet_data_out),
    .data_sram_to_sfu(corelet_data_in_acc),
    .accumulate(inst[33]),
    .relu(1'b0),
    .data_out(corelet_sfp_data_out)
);

endmodule
