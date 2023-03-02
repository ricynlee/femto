module stage_id (
    input wire clk,
    input wire rstn,

    // if-id interface
    input wire [31:0] stage_if_pc,
    input wire [31:0] stage_if_ir,
    input wire        stage_if_c,   // compressed flag
    input wire        stage_if_e,   // ibus exception trigger for stage ex
    input wire        stage_if_vld,

    // dbusif-id interface
    output wire        dbusif_req, // data access, pipeline ensures no overlapping reqs
    output wire        dbusif_w_rb,
    output wire [1:0]  dbusif_size,
    output wire [31:0] dbusif_addr,
    output wire [31:0] dbusif_wd,
    input wire        dbusif_done,
    input wire        dbusif_err,

    // pipeline ctrl interface
    output wire        jmp,
    output wire [31:0] jmp_addr,
    output wire        hld,

    // xregfile-id interface
    input wire[31:0] x[0:15],
    input wire [31:0] x_wdata,
    input wire x_wreq,
    input wire [3:0] x_windex,

    // id-ex interface
    output wire [31:0] stage_id_pc,
    output wire [31:0] stage_id_ir,
    output wire        stage_id_c,   // compressed flag
    output wire        stage_id_e,   // ibus exception trigger for stage ex
    output wire        stage_id_vld,

    output wire [3:0] stage_id_op,
    output wire [31:0] stage_id_lr,
    output wire [31:0] stage_id_a,
    output wire [31:0] stage_id_b,
    output wire [3:0] stage_id_alu, // alu op
    output wire [3:0] stage_id_xrd,
    output wire [3:0] stage_id_csrd,

);

generate
if (1)begin: IF2ID
    dff #(
        .WIDTH(32+32+1+1),
        .INITV({(32+32+1+1){1'd0}})
    ) stage_id_dff (
        .clk (clk),
        .rstn(rstn),
        .set (jmp), // for simulation only
        .setv({(32+32+1+1){1'dx}}), // for simulation only
        .vld (stage_if_vld & ~hld),
        .in  ({stage_if_pc, stage_if_ir, stage_if_c, stage_if_e}),
        .out ({stage_id_pc, stage_id_ir, stage_id_c, stage_id_e})
    );
    
    dff #(
        .WIDTH(1),
        .INITV(1'b0)
    ) stage_id_vld_dff (
        .clk (clk),
        .rstn(rstn),
        .set (jmp | hld),
        .setv(1'b0),
        .vld (1'b1 /* ~hld */), // set has higher priority than vld
        .in  (stage_if_vld),
        .out (stage_id_vld)
    );
end // IF2ID
endgenerate

    generate
        if (1) begin: DECODE
            // directly derived from riscv doc
            wire[31:0] i_type_imm = {{20{stage_id_ir[31]}}, stage_id_ir[31:20]};
            wire[31:0] s_type_imm = {{20{stage_id_ir[31]}}, stage_id_ir[31:25], stage_id_ir[11:7]};
            wire[31:0] b_type_imm = {{20{stage_id_ir[31]}}, stage_id_ir[7], stage_id_ir[30:25], stage_id_ir[11:8], 1'b0};
            wire[31:0] u_type_imm = {stage_id_ir[31:12], 12'd0};
            wire[31:0] j_type_imm = {{11{stage_id_ir[31]}}, stage_id_ir[31], stage_id_ir[19:12], stage_id_ir[20], stage_id_ir[30:21], 1'b0};
            wire[6:0]  funct7 = stage_id_ir[31:25];
            wire[2:0]  funct3 = stage_id_ir[14:12];
            wire[4:0]  rs2_index = stage_id_ir[24:20];
            wire[4:0]  rs1_index = stage_id_ir[19:15];
            wire[4:0]  rd_index = stage_id_ir[11:7];
            wire[31:0] shamt = {27'd0, rs2};
            wire[6:0]  opcode = stage_id_ir[6:0];
            wire[11:0] csr_addr = stage_id_ir[31:20];
            wire[31:0] csr_zimm = {27'd0, rs1};
            
            wire [31:0] rs1 = (x_wreq && rs1_index[3:0]==x_windex) ? x_wdata : x[rs1_index[3:0]];
            wire [31:0] rs2 = (x_wreq && rs2_index[3:0]==x_windex) ? x_wdata : x[rs2_index[3:0]];
            
            // branch conditions
            wire eq = (rs1==rs2);
            wire lt = ({(funct3[1] ^~ rs1[31]), rs1[30:0]}<{(funct3[1] ^~ rs2[31]), rs2[30:0]}); // unsigned comparison, for blt and bltu
            
            assign stage_id_op = 
                opcode[6:2]==OPCODE_LUI ? OP_CAL : // lui
                opcode[6:2]==OPCODE_AUIPC ? OP_CAL : // auipc
                opcode[6:2]==OPCODE_JAL ? OP_JMP : // jal
                opcode[6:2]==OPCODE_JALR ? OP_JMP : // jalr
                (opcode[6:2]==OPCODE_BRANCH && ( funct3[0] ^ (funct3[2] ? lt : eq) )) ? OP_JMP : // beq, bne, blt, bge, bltu, bgeu
                opcode[6:2]==OPCODE_LOAD ? (funct3[1] ? OP_LW : funct3[0] ? OP_LH : OP_LB) : // lb, lh, lw, lbu, lhu
                opcode[6:2]==OPCODE_STORE ? (funct3[1] ? OP_SW : funct3[0] ? OP_SH : OP_SB) : // sb, sh, sw
                opcode[6:2]==OPCODE_IMMCAL ? OP_CAL : // addi, slti, sltiu, xori, ori, andi, slli, srli, srai
                opcode[6:2]==OPCODE_CAL ? OP_CAL : // add, sub, sll, slt, sltu, xor, srl, sra, or, and
                opcode[6:2]==OPCODE_FENCE ? OP_JMP : // fence.i
                opcode[6:2]==OPCODE_SYSTEM ? (
                    funct3[1:0]==2'b01 ? OP_CSRRW : // csrrw, csrrwi
                    funct3[1:0]==2'b01 ? OP_CSRRS : // csrrs, csrrsi
                    funct3[1:0]==2'b11 ? OP_CSRRC : // csrrc, csrrci
                    {rs2_index[4], rs2_index[1]}==2'b01 ? OP_MRET : // mret
                    {rs2_index[4], rs2_index[1]}==2'b11 ? OP_DRET : // dret
                    OP_EBREAK // ebreak
                ) :
                OP_TRAP_ILLI ; // illegal instruction

            assign stage_id_xrd =
                opcode[6:2]==OPCODE_LUI ? rd_index[3:0] : // lui
                opcode[6:2]==OPCODE_AUIPC ? rd_index[3:0] : // auipc
                opcode[6:2]==OPCODE_JAL ? rd_index[3:0] : // jal
                opcode[6:2]==OPCODE_JALR ? rd_index[3:0] : // jalr
                (opcode[6:2]==OPCODE_BRANCH && ( funct3[0] ^ (funct3[2] ? lt : eq) )) ? 4'd0 : // beq, bne, blt, bge, bltu, bgeu
                opcode[6:2]==OPCODE_LOAD ? rd_index[3:0] : // lb, lh, lw, lbu, lhu
                opcode[6:2]==OPCODE_STORE ? 4'd0 : // sb, sh, sw
                opcode[6:2]==OPCODE_IMMCAL ? rd_index[3:0] : // addi, slti, sltiu, xori, ori, andi, slli, srli, srai
                opcode[6:2]==OPCODE_CAL ? rd_index[3:0] : // add, sub, sll, slt, sltu, xor, srl, sra, or, and
                opcode[6:2]==OPCODE_FENCE ? rd_index[3:0] : // fence.i
                opcode[6:2]==OPCODE_SYSTEM ? (
                    funct3[1:0]==2'b01 ? rd_index[3:0] : // csrrw, csrrwi
                    funct3[1:0]==2'b01 ? rd_index[3:0] : // csrrs, csrrsi
                    funct3[1:0]==2'b11 ? rd_index[3:0] : // csrrc, csrrci
                    4'd0 // mret, dret, ebreak
                ) :
                4'd0 ; // illegal instruction
                
            assign stage_id_a =
                
                    
        end
    endgenerate
    
    
    
    
endmodule
