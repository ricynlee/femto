module stage_id (
    input wire clk,
    input wire rstn,

    // dbg interface
    input wire dm_haltreq, // resumereq is software-implemented

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

    // pipeline ctrl interface
    input wire        jmp,
    input wire        hld,
    output wire       stage_id_hld,

    // xregfile-id interface
    input wire[31:0] x[0:15],
    input wire [31:0] x_wdata,
    input wire x_wreq,
    input wire [3:0] x_windex,

    // csregfile-id interface
    input wire[31:0] csr[0:15],
    input wire [31:0] csr_wdata,
    input wire csr_wreq,
    input wire [3:0] csr_windex,

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
if (1)begin: GEN_if_to_id
    dff #(
        .WIDTH(32+32+1+1)
    ) stage_id_dff (
        .clk (clk),
        .rstn(rstn),
        .set (jmp), // for simulation only
        .setv({(32+32+1+1){1'dx}}), // for simulation only
        .vld (stage_if_vld & ~hld),
        .in  ({stage_if_pc, stage_if_ir, stage_if_c, stage_if_e}),
        .out ({stage_id_pc, stage_id_ir, stage_id_c, stage_id_e})
    );
    
    wire stage_id_vld_held;
    dff #(
        .WIDTH(1),
        .INITV(1'b0)
    ) stage_id_vld_dff (
        .clk (clk),
        .rstn(rstn),
        .set (jmp),
        .setv(1'b0),
        .vld (~hld),
        .in  (stage_if_vld),
        .out (stage_id_vld_held)
    );
    assign stage_id_vld = stage_id_vld_held & ~hld;
end // IF2ID
endgenerate

    generate
        if (1) begin: GEN_decode
            wire [31:0] pc = stage_id_pc;
            wire [31:0] ir = stage_id_ir; // instruction register
            wire c = stage_id_c; // compressed flag
            wire e = stage_id_e; // error flag
            wire vld = stage_if_vld;

            wire mip_meip = csr[CSR_IDX_MIP][`MEIP];
            wire mstatus_mie = csr[CSR_IDX_MSTATUS[`MIE];

            // directly derived from riscv doc
            wire[31:0] i_type_imm = {{20{ir[31]}}, ir[31:20]};
            wire[31:0] s_type_imm = {{20{ir[31]}}, ir[31:25], ir[11:7]};
            wire[31:0] b_type_imm = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
            wire[31:0] u_type_imm = {ir[31:12], 12'd0};
            wire[31:0] j_type_imm = {{11{ir[31]}}, ir[31], ir[19:12], ir[20], ir[30:21], 1'b0};
            wire[6:0]  funct7 = ir[31:25];
            wire[2:0]  funct3 = ir[14:12];
            wire[4:0]  rs2_index = ir[24:20];
            wire[4:0]  rs1_index = ir[19:15];
            wire[4:0]  rd_index = ir[11:7];
            wire[31:0] shamt = {27'd0, rs2_index};
            wire[6:0]  opcode = ir[6:0];
            wire[11:0] csr_addr = ir[31:20];
            wire[31:0] csr_uimm = {27'd0, rs1_index};
            
            wire [31:0] rs1 = (x_wreq && rs1_index[3:0]==x_windex) ? x_wdata : x[rs1_index[3:0]];
            wire [31:0] rs2 = (x_wreq && rs2_index[3:0]==x_windex) ? x_wdata : x[rs2_index[3:0]];
            
            wire [3:0] csrsd_index = `CSR_ADDR_TO_IDX; // csr source & destination
            wire [31:0] csrs = (csr_wreq && csrsd_index[3:0]==csr_windex) ? csr_wdata : csr[csrsd_index[3:0]];

            // branch conditions
            wire eq = (rs1==rs2);
            wire lt = ({(funct3[1] ^~ rs1[31]), rs1[30:0]}<{(funct3[1] ^~ rs2[31]), rs2[30:0]}); // unsigned comparison, for blt and bltu
            
            assign op =
                // triggered dbg
                (opcode[6:2]==OPCODE_SYSTEM && {funct3[1:0], rs2_index[4], rs2_index[1]}==4'b0000) ? OP_DBG : // ebreak
                dm_haltreq ? OP_DBG : // external dbg req
                // single step
                e ? OP_IFAULT : // instruction bus error/fault， data bus error is handled at ex stage
                (mstatus_mie & mip_meip) ? OP_INT : // external interrupt
                opcode[6:2]==OPCODE_LUI ? OP_CAL : // lui
                opcode[6:2]==OPCODE_AUIPC ? OP_CAL : // auipc
                opcode[6:2]==OPCODE_JAL ? OP_JMP : // jal
                opcode[6:2]==OPCODE_JALR ? OP_JMP : // jalr
                opcode[6:2]==OPCODE_BRANCH ? (( funct3[0] ^ (funct3[2] ? lt : eq) ) ? OP_JMP : OP_CAL ) : // beq, bne, blt, bge, bltu, bgeu
                opcode[6:2]==OPCODE_LOAD ? (funct3[1] ? OP_LW : funct3[0] ? OP_LH : OP_LB) : // lb, lh, lw, lbu, lhu
                opcode[6:2]==OPCODE_STORE ? (funct3[1] ? OP_SW : funct3[0] ? OP_SH : OP_SB) : // sb, sh, sw
                opcode[6:2]==OPCODE_IMMCAL ? OP_CAL : // addi, slti, sltiu, xori, ori, andi, slli, srli, srai
                opcode[6:2]==OPCODE_CAL ? OP_CAL : // add, sub, sll, slt, sltu, xor, srl, sra, or, and
                opcode[6:2]==OPCODE_FENCE ? OP_JMP : // fence.i
                opcode[6:2]==OPCODE_SYSTEM ? (
                    funct3[1:0] ? OP_CSR : // csrrw, csrrwi, csrrs, csrrsi, csrrc, csrrci
                    {rs2_index[4], rs2_index[1]}==2'b11 ? OP_DRET : // dret
                    mip_meip ? OP_INTS : OP_MRET // mret, interrupt succession is handled at ex stage
                ) :
                OP_ILLI ; // illegal instruction

            assign alu =
                opcode[6:2]==OPCODE_LUI ? ALU_PASS : // lui
                opcode[6:2]==OPCODE_AUIPC ? ALU_ADD : // auipc
                opcode[6:2]==OPCODE_JAL ? ALU_ADD : // jal
                opcode[6:2]==OPCODE_JALR ? ALU_ADD : // jalr
                opcode[6:2]==OPCODE_BRANCH ? ALU_ADD : // beq, bne, blt, bge, bltu, bgeu
                opcode[6:2]==OPCODE_LOAD ? ALU_ADD : // lb, lh, lw, lbu, lhu
                opcode[6:2]==OPCODE_STORE ? ALU_ADD : // sb, sh, sw
                opcode[6:2]==OPCODE_IMMCAL ? (
                    funct3[1:0]==2'b01 ? {ir[30], funct3} : // alu op encoding should be carefully chosen - slli, srli, srai
                    {1'b0, funct3} // alu op encoding should be carefully chosen - addi slti sltiu xori ori andi
                ) :
                opcode[6:2]==OPCODE_CAL ? {ir[30], funct3} : // alu op encoding should be carefully chosen - add, sub, sll, slt, sltu, xor, srl, sra, or, and
                opcode[6:2]==OPCODE_FENCE ? ALU_ADD : // fence.i
                opcode[6:2]==OPCODE_SYSTEM ? (
                    funct3[1:0]==2'b01 ? ALU_PASS : // csrrw, csrrwi
                    funct3[1:0]==2'b01 ? ALU_OR : // csrrs, csrrsi
                    ALU_CLR// csrrc, csrrci, mret (placeholder, ditto), dret, ebreak
                ) :
                ALU_CLR ; // illegal instruction (placeholder)

            assign a =
                opcode[6:2]==OPCODE_LUI ? rs1 : // lui (placeholder)
                opcode[6:2]==OPCODE_AUIPC ? pc : // auipc
                opcode[6:2]==OPCODE_JAL ? pc : // jal
                opcode[6:2]==OPCODE_JALR ? rs1 : // jalr
                opcode[6:2]==OPCODE_BRANCH ? pc : // beq, bne, blt, bge, bltu, bgeu
                opcode[6:2]==OPCODE_LOAD ? rs1 : // lb, lh, lw, lbu, lhu
                opcode[6:2]==OPCODE_STORE ? rs1 : // sb, sh, sw
                opcode[6:2]==OPCODE_IMMCAL ? rs1 : // addi, slti, sltiu, xori, ori, andi, slli, srli, srai
                opcode[6:2]==OPCODE_CAL ? rs1 : // add, sub, sll, slt, sltu, xor, srl, sra, or, and
                opcode[6:2]==OPCODE_FENCE ? lr : // fence.i
                opcode[6:2]==OPCODE_SYSTEM ? csrs : // csrrw, csrrwi, csrrs, csrrsi, csrrc, csrrci, mret (placeholder, ditto), dret, ebreak
                rs1 ; // illegal instruction (placeholder)
                
            assign b =
                opcode[6:2]==OPCODE_LUI ? u_type_imm : // lui
                opcode[6:2]==OPCODE_AUIPC ? u_type_imm : // auipc
                opcode[6:2]==OPCODE_JAL ? j_type_imm : // jal
                opcode[6:2]==OPCODE_JALR ? i_type_imm : // jalr, if-stage ensuring lsb bit is 0
                opcode[6:2]==OPCODE_BRANCH ? b_type_imm : // beq, bne, blt, bge, bltu, bgeu
                opcode[6:2]==OPCODE_LOAD ? i_type_imm : // lb, lh, lw, lbu, lhu
                opcode[6:2]==OPCODE_STORE ? s_type_imm : // sb, sh, sw
                opcode[6:2]==OPCODE_IMMCAL ? (
                    funct3[1:0]==2'b01 ? shamt : // slli, srli, srai
                    i_type_imm // addi, slti, sltiu, xori, ori, andi
                ) :
                opcode[6:2]==OPCODE_CAL ? rs2 : // add, sub, sll, slt, sltu, xor, srl, sra, or, and
                opcode[6:2]==OPCODE_FENCE ? i_type_imm : // fence.i (std software shall zero imm - per riscv doc)
                opcode[6:2]==OPCODE_SYSTEM ? (
                    funct3[2] ? csr_uimm : // csrrwi, csrrsi, csrrci
                    rs1 // csrrw, csrrs, csrrc
                ) :
                i_type_imm ; // illegal instruction (placeholder)

            assign lr = pc + (c ? 32'd2 : 32'd4);

            assign stage_id_hld =
                vld && (
                    op==OP_DBG |
                    op==OP_IFAULT |
                    op==OP_INT |
                    op==OP_JMP |
                    (opcode[6:2]==OPCODE_SYSTEM && funct3[1:0]==2'b00) | // dret, mret, ebreak
                    opcode[6:2]==OPCODE_LOAD |
                    opcode[6:2]==OPCODE_STORE
                );

            assign dbusif_req = vld && (opcode[6:2]==OPCODE_LOAD || opcode[6:2]==OPCODE_STORE);
            assign dbusif_w_rb = opcode[5];
            assign dbusif_size = funct3[1:0];
            assign dbusif_wd = rs2;
        end
    endgenerate


    
    
endmodule
