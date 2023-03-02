module stage_if (
    input wire clk,
    input wire rstn,

    // ibusif interface
    input  wire [ 1:0] ibusif_vld_size,  // vld data size in instr fetch queue
    output wire        ibusif_pop,
    output wire [ 1:0] ibusif_pop_size,  // only bit 0 matters as aligned with ibusif
    input  wire [31:0] ibusif_data,
    input  wire        ibusif_err,   // bus access to instr caused fault

    // if-id interface
    output wire [31:0] stage_if_pc,
    output wire [31:0] stage_if_ir,
    output wire        stage_if_c,   // compressed flag
    output wire        stage_if_e,   // ibus exception trigger for stage ex
    output wire        stage_if_vld,

    // pipeline ctrl interface
    input wire        jmp,
    input wire [31:0] jmp_addr,
    input wire        hld
);
    wire [31:0] stage_if_next_pc;
    assign stage_if_next_pc = stage_if_pc + (instr_compressed ? 32'd2 : 32'd4);
    assign ibusif_pop       = stage_if_vld;
    assign ibusif_pop_size  = {1'b0, stage_if_c};  // only bit 0 matters, as aligned with ibusif

    instr_decompressor instr_decompressor (
        .in_instr        (ibusif_data),
        .out_instr       (stage_if_ir),
        .instr_compressed(stage_if_c)
    );
    assign stage_if_e   = ibusif_err;
    assign stage_if_vld = ~hld & (ibusif_vld_size[1]  /*32b*/ || (ibusif_vld_size[0] & instr_compressed));
    dff #(
        .WIDTH(32),
        .INITV(`RESET_PC)
    ) stage_if_pc_dff (
        .clk (clk),
        .rstn(rstn),
        .set (jmp),
        .setv(jmp_addr),
        .vld (stage_if_vld),
        .in  (stage_if_next_pc),
        .out (stage_if_pc)
    );
endmodule
