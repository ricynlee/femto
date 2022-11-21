module core (
    input wire clk,
    input wire rstn,

    // external interrupt
    input wire  ext_int_req,
    output wire ext_int_resp,

    // external dbg trigger(DM)
    input wire  ext_dbg_req,
    output wire ext_dbg_resp,

    // dbg trap addr(DM)
    input wire[31:0] dbg_trap_addr,

    // data bus interface (ahblite-like)
    output wire [31:0] d_haddr,
    output wire        d_hprot,   // data/instruction access indicator
    output wire [ 1:0] d_hsize,
    output wire        d_hwrite,
    output wire [31:0] d_hwdata,
    output wire        d_htrans,  // indicate whether the transfer is valid, bit 1 of AHB HTRANS
    input  wire [31:0] d_hrdata,
    input  wire        d_hresp,
    input  wire        d_hready

    // instruction bus interface (ahblite-like)
    output wire [31:0] i_haddr,
    output wire        i_hprot,   // data/instruction access indicator
    output wire [ 1:0] i_hsize,
    output wire        i_hwrite,
    output wire [31:0] i_hwdata,
    output wire        i_htrans,  // indicate whether the transfer is valid, bit 1 of AHB HTRANS
    input  wire [31:0] i_hrdata,
    input  wire        i_hresp,
    input  wire        i_hready
);

    ibusif ibusif (
        .clk (clk),
        .rstn(rstn),
        .jmp_req (jmp),
        .jmp_addr('h00000002),
        .instr_fetch     (instr_fetch),      // typically vld of pipeline stage 0
        .instr_fetch_size(instr_fetch_size), // bit 0: 1 - requesting 16-bit data, 0 - requesting 32-bit data
        .instr_vld_size      (instr_vld_size),       // 2'b00 - not vld, 2'b01 - 16-bit instr vld, 2'b1x - 32-bit instr vld
        .instr               (instr),
        .instr_has_fault(instr_has_fault), // instr contains bus fault
        .haddr (haddr),
        .hprot (hprot),   // data/instruction access indicator
        .hsize (hsize),
        .hwrite(hwrite),
        .hwdata(hwdata),
        .htrans(htrans),  // indicate whether the transfer is valid, bit 1 of AHB HTRANS
        .hrdata(hrdata),
        .hresp (hresp),
        .hready(hready)
    );

    instr_decompressor instr_decompressor ( // conpressed instruction expansion
        .in_instr(),
        .out_instr(),
        .instr_compressed()
    );




    dbusif dbusif (
        .clk           (clk           ),
        .rstn          (rstn          ),
        .acc_req       (acc_req       ),
        .acc_w_rb      (acc_w_rb      ),
        .acc_size      (acc_size      ),
        .acc_addr      (acc_addr      ),
        .acc_wdata     (acc_wdata     ),
        .data_vld      (data_vld      ),
        .data          (data          ),
        .data_has_fault(data_has_fault),
        .haddr         (haddr         ),
        .hprot         (hprot         ),
        .hsize         (hsize         ),
        .hwrite        (hwrite        ),
        .hwdata        (hwdata        ),
        .htrans        (htrans        ),
        .hrdata        (hrdata        ),
        .hresp         (hresp         ),
        .hready        (hready        )
    );

    `include "core.vh"



        wire[`ILEN-1:0] if_ir_raw;

        assign s0_vld = ~hld & ((ifq_filled_16bit_entry==2'd2) || (ifq_filled_16bit_entry && s0_cif)); // instruction fetch control

        instr_decompressor instr_decompressor(
            .in_instr(if_ir_raw),
            .out_ir  (s0_ir    ),
            .out_cif (s0_cif   )
        );

        wire[`XLEN-1:0] if_next_pc = jmp ? jmp_addr : (s0_pc + (s0_cif ? 2 : 4));
        dff #(
            .WIDTH      (`XLEN    ),
            .INITIALIZER(`RESET_PC),
            .RESET      ("sync"   ),
            .VALID      ("sync"   )
        ) s0_pc_dff (
            .clk (clk         ),
            .rstn(rstn        ),
            .vld (jmp | s0_vld),
            .in  (if_next_pc  ),
            .out (s0_pc       )
        );
    end // STAGE0

    /**********************************************************************************************************************/
    begin:PIPELINE // can be seen as part of stage1(S1)
        pipeline pipeline(
            .clk   (clk   ),
            .rstn  (rstn  ),
            .clr   (jmp   ),
            .hld   (hld   ),
            .s0_ir (s0_ir ),
            .s0_pc (s0_pc ),
            .s0_cif(s0_cif),
            .s0_vld(s0_vld),
            .s1_ir (s1_ir ),
            .s1_pc (s1_pc ),
            .s1_cif(s1_cif),
            .s1_vld(s1_vld),
            .s2_ir (s2_ir ),
            .s2_pc (s2_pc ),
            .s2_cif(s2_cif),
            .s2_vld(s2_vld)
        );

        localparam PLC_NORMAL = 0, // pipeline control(PLC)
                   PLC_JUMP_CACL = 1, // jump addr caculation
                   PLC_JUMP_INIT = 2, // jump req initiating
                   PLC_JUMP_EXEC = 3, // jump req executing
                   PLC_DATA_INIT = 4, // data req initiating
                   PLC_DATA_EXEC = 5, // data req executing
                   PLC_BUTT   = 6;

        wire[7:0] state; // pipeline control FSM
        reg[7:0] next_state;

        dff #(
            .RESET      ("sync"    ),
            .WIDTH      (8         ),
            .INITIALIZER(PLC_NORMAL)
        ) plc_state_dff (
            .clk (clk       ),
            .rstn(rstn      ),
            .in  (next_state),
            .out (state     )
        );

        always_comb case(state)
            PLC_NORMAL:
                if (s1_vld & s1_jmp_req)
                    next_state = PLC_JUMP_CACL;
                else if (s1_vld & s1_data_req)
                    next_state = PLC_DATA_INIT;
                else // do not infer latch
                    next_state = PLC_NORMAL;
            PLC_JUMP_CACL:
                next_state = PLC_JUMP_INIT;
            PLC_JUMP_INIT:
                if (instr_req_launched)
                    next_state = PLC_JUMP_EXEC;
                else
                    next_state = PLC_JUMP_INIT;
            PLC_JUMP_EXEC:
                if (instr_resp_latched) begin
                    if (s1_vld & s1_jmp_req)
                        next_state = PLC_JUMP_CACL;
                    else if (s1_vld & s1_data_req)
                        next_state = PLC_DATA_INIT;
                    else // do not infer latch
                        next_state = PLC_NORMAL;
                end else
                    next_state = PLC_JUMP_EXEC;
            PLC_DATA_INIT:
                if (data_req_launched)
                    next_state = PLC_DATA_EXEC;
                else
                    next_state = PLC_DATA_INIT;
            PLC_DATA_EXEC:
                if (data_resp_latched) begin
                    if (s2_vld & s2_data_except)
                        next_state = PLC_JUMP_INIT;
                    else if (s1_vld & s1_jmp_req)
                        next_state = PLC_JUMP_CACL;
                    else if (s1_vld & s1_data_req)
                        next_state = PLC_DATA_INIT;
                    else // do not infer latch
                        next_state = PLC_NORMAL;
                end else
                    next_state = PLC_DATA_EXEC;
            default:
                next_state = PLC_NORMAL;
        endcase

        assign jmp = state==PLC_JUMP_CACL || s2_data_except;
        assign hld = (state==PLC_JUMP_CACL || state==PLC_JUMP_INIT || state==PLC_DATA_INIT) ||
                     (state==PLC_JUMP_EXEC && ~instr_resp_latched) ||
                     (state==PLC_DATA_EXEC && ~data_resp_latched);
    end // PIPELINE

    /**********************************************************************************************************************/
    begin:STAGE1 // instruction expansion & decoding
        // x regfile
        wire[`XLEN-1:0] x[0:15];
        regfile regfile(
            .clk   (clk          ),
            .wreq  (regfile_w_req),
            .windex(regfile_w_idx),
            .wdata (regfile_w_dat),
            .x0    (x            )
        );

        wire[$clog2(`BUS_ACC_CNT)-1:0] s1_data_req_acc;
        wire s1_data_req_w_rb;
        wire[`BUS_WIDTH-1:0] s1_data_req_wdata;
        begin:DECODE
            // instruction slices
            wire[31:0] i_type_imm = {{20{s1_ir[31]}}, s1_ir[31:20]};
            wire[31:0] s_type_imm = {{20{s1_ir[31]}}, s1_ir[31:25], s1_ir[11:7]};
            wire[31:0] b_type_imm = {{20{s1_ir[31]}}, s1_ir[7], s1_ir[30:25], s1_ir[11:8], 1'b0};
            wire[31:0] u_type_imm = {s1_ir[31:12], 12'd0};
            wire[31:0] j_type_imm = {{11{s1_ir[31]}}, s1_ir[31], s1_ir[19:12], s1_ir[20], s1_ir[30:21], 1'b0};
            wire[6:0]  funct7 = s1_ir[31:25];
            wire[2:0]  funct3 = s1_ir[14:12];
            wire[4:0]  rs2 = s1_ir[24:20];
            wire[4:0]  rs1 = s1_ir[19:15];
            wire[4:0]  rd = s1_ir[11:7];
            wire[31:0] shamt = {27'd0, rs2};
            wire[6:0]  opcode = s1_ir[6:0];
            wire[11:0] csr_addr = s1_ir[31:20];
            wire[31:0] csr_zimm = {27'd0, rs1};

            // decoding
            wire[`XLEN-1:0] rs1_val =
                (regfile_w_req && rs1[3:0]==regfile_w_idx) ?
                    regfile_w_data :
                /* otherwise */
                    x[rs1[3:0]];

            wire[`XLEN-1:0] rs2_val =
                (regfile_w_req && rs2[3:0]==regfile_w_idx) ?
                    regfile_w_data :
                /* otherwise */
                    x[rs2[3:0]];

            wire[`XLEN-1:0] jmp_lr = s1_pc + (s1_cif ? 2 : 4);

            wire[`CSR_IDX_WIDTH-1:0] csr_index = `CSR_ADDR_TO_IDX;

            // TODO: under debug mode there is no interrupt, exception or debug trap

            // signals for following stage
            always @ (*) begin
                if (interrupt) begin
                    s1_jmp_req = 1'b1;
                    s1_jmp_lr = {`XLEN{1'bx}};
                end

                if (interrupt) begin
                    s1_data_req = 1'b0;
                    s1_data_req_acc = {$clog2(`BUS_ACC_CNT){1'bx}};
                    s1_data_req_w_rb = 1'bx;
                    s1_data_req_wdata = {`XLEN{1'bx}};
                end

                if (interrupt) begin
                    s1_op = {OP_INT_INT, };
                    s1_alu_op = ALU_A;
                    s1_alu_a = csr_r_data[CSR_IDX_MTVEC];
                    s1_alu_b = {`XLEN{1'bx}};
                    s1_rd = 4'd0;
                    s1_csrd = {`CSR_IDX_WIDTH{1'bx}};
                    s1_csr_val = {`XLEN{1'bx}};
                end else if (s1_ir==32'b0011000_00010_00000_000_00000_1110011) begin // MRET
                    s1_op = OP_MRET;
                    s1_alu_op = ALU_A;
                    s1_alu_a = (succesional_interrupt ? csr_r_data[CSR_IDX_MTVEC] /* successional traps */ : csr_r_data[CSR_IDX_MEPC]);
                    s1_alu_b = {`XLEN{1'bx}};
                    s1_rd = 4'd0;
                    s1_csrd = {`CSR_IDX_WIDTH{1'bx}};
                    s1_csr_val = {`XLEN{1'bx}};
                    s1_jmp_req = 1'b1;
                    s1_jmp_lr = {`XLEN{1'bx}};
                    s1_data_req = 1'b0;
                    s1_data_req_acc = {$clog2(`BUS_ACC_CNT){1'bx}};
                    s1_data_req_w_rb = 1'bx;
                    s1_data_req_wdata = {`XLEN{1'bx}};
                end else if (s1_ir==32'h7b2000073) begin // DRET
                    s1_op = OP_MRET;
                    s1_alu_op = ALU_A;
                    s1_alu_a = csr_r_data[CSR_IDX_DPC];
                    s1_alu_b = {`XLEN{1'bx}};
                    s1_rd = 4'd0;
                    s1_csrd = {`CSR_IDX_WIDTH{1'bx}};
                    s1_csr_val = {`XLEN{1'bx}};
                    s1_jmp_req = 1'b1;
                    s1_jmp_lr = {`XLEN{1'bx}};
                    s1_data_req = 1'b0;
                    s1_data_req_acc = {$clog2(`BUS_ACC_CNT){1'bx}};
                    s1_data_req_w_rb = 1'bx;
                    s1_data_req_wdata = {`XLEN{1'bx}};
                end else if (s1_ir==32'b000000000001_00000_000_00000_1110011) begin // EBREAK
                    s1_op = OP_EBRK;
                    s1_alu_op = ALU_A;
                    s1_alu_a = dbg_trap_addr;
                    s1_alu_b = {`XLEN{1'bx}};
                    s1_rd = 4'd0;
                    s1_csrd = {`CSR_IDX_WIDTH{1'bx}};
                    s1_csr_val = {`XLEN{1'bx}};
                    s1_jmp_req = 1'b1;
                    s1_jmp_lr = {`XLEN{1'bx}};
                    s1_data_req = 1'b0;
                    s1_data_req_acc = {$clog2(`BUS_ACC_CNT){1'bx}};
                    s1_data_req_w_rb = 1'bx;
                    s1_data_req_wdata = {`XLEN{1'bx}};
                end else if (opcode==OPCODE_LUI) begin // LUI, rd[4] ignored
                    s1_op = OP_CAL;
                    s1_alu_op = ALU_A;
                    s1_alu_a = u_type_imm;
                    s1_alu_b = {`XLEN{1'bx}};
                    s1_rd = rd[3:0];
                    s1_csrd = {`CSR_IDX_WIDTH{1'bx}};
                    s1_csr_val = {`XLEN{1'bx}};
                    s1_jmp_req = 1'b0;
                    s1_jmp_lr = {`XLEN{1'bx}};
                    s1_data_req = 1'b0;
                    s1_data_req_acc = {$clog2(`BUS_ACC_CNT){1'bx}};
                    s1_data_req_w_rb = 1'bx;
                    s1_data_req_wdata = {`XLEN{1'bx}};
                end else if (opcode==OPCODE_AUIPC) begin // AUIPC, rd[4] ignored
                    s1_op = OP_CAL;
                    s1_alu_op = ALU_ADD;
                    s1_alu_a = u_type_imm;
                    s1_alu_b = s1_pc;
                    s1_rd = rd[3:0];
                    s1_csrd = {`CSR_IDX_WIDTH{1'bx}};
                    s1_csr_val = {`XLEN{1'bx}};
                    s1_jmp_req = 1'b0;
                    s1_jmp_lr = {`XLEN{1'bx}};
                    s1_data_req = 1'b0;
                    s1_data_req_acc = {$clog2(`BUS_ACC_CNT){1'bx}};
                    s1_data_req_w_rb = 1'bx;
                    s1_data_req_wdata = {`XLEN{1'bx}};
                end else if (opcode==JAL) begin // JAL, rd[4] ignored
                    s1_op = OP_JAL;
                    s1_alu_op = ALU_ADD;
                    s1_alu_a = j_type_imm;
                    s1_alu_b = s1_pc;
                    s1_rd = rd[3:0];
                    s1_csrd = {`CSR_IDX_WIDTH{1'bx}};
                    s1_csr_val = {`XLEN{1'bx}};
                    s1_jmp_req = 1'b1;
                    s1_jmp_lr = jmp_lr;
                    s1_data_req = 1'b0;
                    s1_data_req_acc = {$clog2(`BUS_ACC_CNT){1'bx}};
                    s1_data_req_w_rb = 1'bx;
                    s1_data_req_wdata = {`XLEN{1'bx}};
                end else if (opcode==JALR && funct3==3'b000) begin // JALR, r*[4] ignored
                    s1_op = OP_JALR;
                    s1_alu_op = ALU_ADD;
                    s1_alu_a = j_type_imm;
                    s1_alu_b = rs1_val;
                    s1_rd = rd[3:0];
                    s1_csrd = {`CSR_IDX_WIDTH{1'bx}};
                    s1_csr_val = {`XLEN{1'bx}};
                    s1_jmp_req = 1'b1;
                    s1_jmp_lr = jmp_lr;
                    s1_data_req = 1'b0;
                    s1_data_req_acc = {$clog2(`BUS_ACC_CNT){1'bx}};
                    s1_data_req_w_rb = 1'bx;
                    s1_data_req_wdata = {`XLEN{1'bx}};
                end else if (opcode==BRANCH) begin
                    s1_op = OP_NOP;
                    if (funct3==3'b000) begin

                    end
                endcase end else if () begin

                end












































            end


            assign imm_val =
                (opcode==OPCODE_BRANCH) ?
                    b_type_imm :
                (opcode==OPCODE_LUI || opcode==OPCODE_AUIPC) ?
                    u_type_imm :
                (opcode==OPCODE_JAL) ?
                    j_type_imm :
                (opcode==OPCODE_LOAD || opcode==OPCODE_JALR || (opcode==OPCODE_IMMCAL && funct3^3'b001 && funct3^3'b101)) ?
                    i_type_imm :
                (opcode==OPCODE_STORE) ?
                    s_type_imm :
                (opcode==OPCODE_SYSTEM) ?
                    csr_zimm :
                /* otherwise */
                    shamt;

            // signals for wider use
            assign s1_rd =
                interrupt ?
                    4'd0 /* interrupt/return seen as an instruction where rd=0 */ :
                (opcode==OPCODE)
                (opcode==OPCODE_BRANCH || opcode==OPCODE_STORE || opcode==OPCODE_FENCE) /* rd not available */ ?
                    4'd0 /* available yet should not be used for FENCE.I/FENCE */ :
                /* rd available */
                    rd[3:0];

            assign s1_csrd = csr_index;

            assign s1_csr_val = csr_r_data[csr_index];

            assign s1_alu_a =
                interrupt ?
                    csr_r_data[CSR_IDX_MTVEC] :
                (opcode==OPCODE_SYSTEM) ? (
                    funct3[1:0] ? // csr op
                        (funct3[1] ? csr_r_data[csr_index] /* bit set/clr */ : {`XLEN{1'b0}} /* val set */) :
                    // mret
                        (succesional_interrupt ? csr_r_data[CSR_IDX_MTVEC] /* successional traps */ : csr_r_data[CSR_IDX_MEPC])
                ) :
                (opcode==OPCODE_LUI) ?
                    {`XLEN{1'b0}} :
                (opcode==OPCODE_AUIPC || opcode==OPCODE_JAL || opcode==OPCODE_BRANCH || opcode==OPCODE_FENCE) ?
                    s1_pc /* do-not-care for FENCE. used for FENCE.I */ :
                /* otherwise */
                    rs1_val;

            assign s1_alu_b =
                interrupt ?
                    {`XLEN{1'b0}} : // (csr_mtvec | 0) as trap jump dst
                (opcode==OPCODE_SYSTEM) ? (
                    funct3[1:0] ? // csr op
                        (funct3[2] ? imm_val : rs1_val) :
                    // mret
                        {`XLEN{1'b0}} // (csr_mepc/csr_mtvec | 0) as trap return/succession jump dst
                ) :
                (opcode==OPCODE_CAL) ?
                    rs2_val :
                /* otherwise */
                    imm_val;

            assign s1_alu_op =
                interrupt ?
                    ALU_OR :
                (opcode==OPCODE_SYSTEM) ?
                    ((funct3[1] & funct3[0]) ? ALU_CLR : ALU_OR) :
                (opcode==OPCODE_CAL || opcode==OPCODE_IMMCAL) ? (
                    funct3==3'd1 ?
                        ALU_SL :
                    funct3==3'd2 ?
                        ALU_LT :
                    funct3==3'd3 ?
                        ALU_LTU :
                    funct3==3'd4 ?
                        ALU_XOR :
                    funct3==3'd5 ?
                        (~funct7[5] ? ALU_SRL : ALU_SRA) :
                    funct3==3'd6 ?
                        ALU_OR :
                    funct3==3'd7 ?
                        ALU_AND :
                    /* 3'd0 */
                        ((opcode==OPCODE_CAL && funct7[5]) ? ALU_SUB : ALU_ADD)
                ) :
                /* otherwise (even if unimplemented) */
                    ALU_ADD;

            assign s1_op =
                interrupt ?
                    OP_TRAP :
                (opcode==OPCODE_SYSTEM) ? (
                    funct3[1:0] ? // csr op
                        OP_CSR :
                    // mret
                        (succesional_interrupt ? OP_TRAP_SUC : OP_TRAP_RET)
                ) :
                (opcode==OPCODE_LOAD) ?
                    (funct3[2] ? OP_LDU : OP_LD) :
                (opcode==OPCODE_JAL || (opcode==OPCODE_FENCE && funct3[0] /* FENCE.I */ )) ?
                    OP_JAL :
                (opcode==OPCODE_JALR) ?
                    OP_JALR :
                /* otherwise */
                    OP_STD;

            assign s1_jmp_req =
            (
                opcode==OPCODE_BRANCH && (
                    funct3[2:1]==2'd2 ?
                        (funct3[0]^($signed(rs1_val)<$signed(rs2_val))/* ({~rs1_val[`XLEN-1], rs1_val[`XLEN-2:0]}<{~rs2_val[`XLEN-1], rs2_val[`XLEN-2:0]}) */) :
                    funct3[2:1]==2'd3 ?
                        (funct3[0]^(rs1_val<rs2_val)) :
                    /* 2'd0 or undefined */
                        (funct3[0]^(rs1_val==rs2_val))
                )
            ) || (
                opcode==OPCODE_JALR
            ) || (
                opcode==OPCODE_JAL
            ) || (
                opcode==OPCODE_FENCE && funct3[0] /* FENCE.I */
            ) || (
                interrupt || (opcode==OPCODE_SYSTEM && !funct3) /* always jump if interrupt/mret detected */
            );

            assign s1_jmp_lr =
                ((opcode==OPCODE_JALR) || (opcode==OPCODE_JAL)) ?
                    (s1_pc + (s1_cif ? 2 : 4)) :
                /* to set interrupt mepc */
                    s1_pc;

            assign s1_data_req = (opcode==OPCODE_LOAD || opcode==OPCODE_STORE) && !interrupt;
            assign s1_data_req_acc = (funct3[1:0]==2'd0 ? `BUS_ACC_1B : funct3[1:0]==2'd1 ? `BUS_ACC_2B : `BUS_ACC_4B);
            assign s1_data_req_w_rb = (opcode==OPCODE_STORE);
            assign s1_data_req_wdata = rs2_val;

            assign s1_iif = /* not processed upon interrupt */
                ~interrupt && (
                    s1_partial_iif ? 1'b1 : (
                        (opcode==OPCODE_LUI || opcode==OPCODE_AUIPC || opcode==OPCODE_JAL) ?
                            rd[4] :
                        (opcode==OPCODE_JALR) ?
                            (rd[4] || rs1[4] || funct3) :
                        (opcode==OPCODE_BRANCH) ?
                            (rs1[4] || rs2[4] || funct3[2:1]==2'b01) :
                        (opcode==OPCODE_LOAD) ?
                            (rd[4] | rs1[4] | (funct3[1]&funct3[0]) | (funct3[2]&funct3[1])) :
                        (opcode==OPCODE_STORE) ?
                            (rs1[4] | rs2[4] | funct3[2] | (funct3[1]&funct3[0])) :
                        (opcode==OPCODE_IMMCAL) ?
                            (rd[4] || rs1[4] || (funct3[1:0]==2'b01 && ({funct7[6], funct7[4:0]} || (~funct3[2] & funct7[5])))) :
                        (opcode==OPCODE_CAL) ?
                            (rd[4] || rs1[4] || rs2[4] || {funct7[6], funct7[4:0]} || (funct7[5] && (funct3[1] || (funct3[2]^funct3[0])))) :
                        (opcode==OPCODE_FENCE) ?
                            (rd[4] || rs1[4] || funct3[2:1]) :
                        (opcode==OPCODE_SYSTEM) ? ( // no ecall/ebreak
                            funct3[1:0]==2'b00 ? // mret
                                (funct3[2] || rs1 || rd || funct7!=7'b0011000 || rs2!=5'd2) :
                            // csr ops, no csr addr validity check here
                                ((funct3[2]==1'b0 && rs1[4]) || rd[4])
                        ) :
                        /* undefined / unimplemented opcode */
                            1'b1
                    )
                );
        end // DECODE

        dff #(
            .RESET("sync"),
            .VALID("sync"),
            .CLEAR("sync")
        ) data_req_dff (
            .clk (clk                 ),
            .rstn(rstn                ),
            .clr (data_req_launched   ),
            .vld (s1_vld & s1_data_req),
            .in  (s1_data_req         ),
            .out (data_req            )
        );

        dff #(
            .WIDTH($clog2(`BUS_ACC_CNT)+1+`BUS_WIDTH),
            .VALID("sync")
        ) data_req_info_dff (
            .clk(clk),
            .vld(s1_vld & s1_data_req),
            .in ({s1_data_req_acc,s1_data_req_w_rb,s1_data_req_wdata}),
            .out({data_req_acc,   data_req_w_rb,   data_req_wdata   })
        );
    end // STAGE1

    /**********************************************************************************************************************/
    begin:STAGE2 // executing, mem access & write back
        wire s2_partial_iif; // to be OR'ed with S2's iif logic
        dff #(
            .WIDTH(1),
            .VALID("sync")
        ) s2_partial_iif_dff (
            .clk(clk           ),
            .vld(s1_vld        ),
            .in (s1_iif        ),
            .out(s2_partial_iif)
        );

        dff #(
            .WIDTH(4+`XLEN+`XLEN+8+8+`XLEN+2+`XLEN),
            .VALID("sync")
        ) s2_misc_dff (
            .clk(clk),
            .vld(s1_vld),
            .in ({s1_rd,s1_alu_a,s1_alu_b,s1_alu_op,s1_op,s1_jmp_lr,s1_csrd,s1_csr_val}),
            .out({s2_rd,s2_alu_a,s2_alu_b,s2_alu_op,s2_op,s2_jmp_lr,s2_csrd,s2_csr_val})
        );

        // ALU
        wire[7:0]       alu_op = s2_alu_op;
        wire[`XLEN-1:0] alu_a  = s2_alu_a ;
        wire[`XLEN-1:0] alu_b  = s2_alu_b ;
        wire[`XLEN-1:0] alu_r;
        alu alu(
            .op(alu_op),
            .a (alu_a ),
            .b (alu_b ),
            .r (alu_r ) // for OP_JAL/OP_JALR/OP_TRAP(jal,mret,jalr,"trap") alu_r is jmp dst
        );

        // jump/data addr control
        assign jmp_addr = {alu_r[`XLEN-1:1], 1'b0}; // jmp_addr[0] clamped 0
        assign data_req_addr = alu_r;

        // regfile w access
        assign regfile_w_req = s2_vld && regfile_w_idx;
        assign regfile_w_idx = s2_rd;
        assign regfile_w_data =
            (s2_op==OP_LD) ? (
                (data_resp_acc==`BUS_ACC_1B) ?
                    {{24{data_resp_data[7]}}, data_resp_data[7:0]} :
                (data_resp_acc==`BUS_ACC_2B) ?
                    {{16{data_resp_data[15]}}, data_resp_data[15:0]} :
                /*otherwise*/
                    data_resp_data
            ) :
            (s2_op==OP_LDU) ? (
                (data_resp_acc==`BUS_ACC_1B) ?
                    {24'd0, data_resp_data[7:0]} :
                /*data_resp_acc==`BUS_ACC_2B*/
                    {16'd0, data_resp_data[15:0]}
            ) :
            (s2_op==OP_JAL || s2_op==OP_JALR) ?
                s2_jmp_lr :
            (s2_op==OP_CSR) ?
                s2_csr_val :
            /* otherwise treated as OP_STD */
                alu_r;

        // csr w access : only user csr access instructions are handled, not for trap entry/mret
        assign csr_w_idx = s2_csrd;
        assign csr_w_data = alu_r;

        begin:CSR // csr control
            // csr array
            reg[`XLEN-1:0] csr[0:CSR_NUM-1];

            // csr read definition
            for(genvar i=0; i<CSR_NUM; i=i+1) begin
                case (i)
                    CSR_IDX_MIP    : assign csr_r_data[i] = {csr[i][`XLEN-1:`MEIP+1], ext_int_req, csr[i][`MEIP-1:0]};
                    CSR_IDX_TDATA2 :
                    CSR_IDX_TDATA1 :
                    CSR_IDX_DCSR   :
                    CSR_IDX_DPC    :
                    default          : assign csr_r_data[i] = csr[i];
                endcase
            end

            // csr write operation
            always @ (posedge clk) begin
                if (~rstn) begin
                    csr[CSR_IDX_MSTATUS][`MIE ] <= `INT_RST_EN;
                    // csr[CSR_IDX_MIE    ][`MEIE] <= 1'b1;
                end else if (s2_vld) begin
                    if (s2_op==OP_CSR) begin
                        csr[csr_w_idx] <= csr_w_data;
                    end else if (s2_op==OP_TRAP_SUC) begin
                        // csr[CSR_IDX_MCAUSE] <= MCAUSE_EXT_INT;
                        csr[CSR_IDX_MSTATUS][`MIE] <= 1'b0;
                    end else if (s2_op==OP_TRAP) begin
                        csr[CSR_IDX_MEPC] <= s2_jmp_lr;
                        // csr[CSR_IDX_MCAUSE] <= MCAUSE_EXT_INT;
                        csr[CSR_IDX_MSTATUS][`MIE ] <= 1'b0;
                        csr[CSR_IDX_MSTATUS][`MPIE] <= csr_r_data[CSR_IDX_MSTATUS][`MIE];
                    end else if (s2_op==OP_TRAP_RET) begin
                        csr[CSR_IDX_MSTATUS][`MIE ] <= csr_r_data[CSR_IDX_MSTATUS][`MPIE];
                    end
                end
            end
        end

        begin:INTERRUPT // interrupt control
            assign ext_int_resp = s2_vld && (s2_op==OP_TRAP || s2_op==OP_TRAP_SUC);
            assign interrupt = csr_r_data[CSR_IDX_MSTATUS][`MIE] && (/*csr_r_data[CSR_IDX_MIE][`MEIE] &&*/ csr_r_data[CSR_IDX_MIP][`MEIP]);
            assign succesional_interrupt = csr_r_data[CSR_IDX_MSTATUS][`MPIE] && (/*csr_r_data[CSR_IDX_MIE][`MEIE] &&*/ csr_r_data[CSR_IDX_MIP][`MEIP]);
        end // INTERRUPT

        begin:EXCEPTION // exception control
            dff #(
                .RESET("sync" ),
                .CLEAR("sync" ),
                .VALID("async")
            )(
                .clk(clk),
                .rstn(rstn),
                .clr(s1_vld),
                .vld(s2_vld),
                .in(|{s2}),
                .out()
    input wire              vld,
    input wire [WIDTH-1:0]  in,
    output wire [WIDTH-1:0] out
);

        end // EXCEPTION

        begin:DEBUG // dbg/trigger control
            assign
        end // DEBUG
    end // STAGE2
endmodule

/**********************************************************************************************************************/

/**********************************************************************************************************************/

/**********************************************************************************************************************/

/**********************************************************************************************************************/

/**********************************************************************************************************************/
module pipeline( // basically a controllable shift reg
    input wire  clk,
    input wire  rstn,

    input wire  clr,
    input wire  hld,

    input wire[`ILEN-1:0]   s0_ir,
    input wire[`XLEN-1:0]   s0_pc,
    input wire              s0_cif,
    input wire              s0_vld,

    output wire[`ILEN-1:0]  s1_ir,
    output wire[`XLEN-1:0]  s1_pc,
    output wire             s1_cif,
    output wire             s1_vld,

    output wire[`ILEN-1:0]  s2_ir,
    output wire[`XLEN-1:0]  s2_pc,
    output wire             s2_cif,
    output wire             s2_vld
);
    reg[`ILEN+`XLEN+2-1:0]  s1, s2;

    always @(posedge clk) begin
        if (~rstn) begin
            s1[0] <= 1'b0;
            s2[0] <= 1'b0;
        end else if (clr) begin
            s1[`ILEN+`XLEN+2-1:1] <= {(`ILEN+`XLEN+1){1'b0}};
            s1[0] <= 1'b0;
            // s2[0] <= 1'b0; // clr, i.e. jmp, should not clear ex/wb stage's vld flag
        end else if (hld) begin
            // do nothing
        end else begin
            s1 <= {s0_ir,s0_pc,s0_cif,s0_vld};
            s2 <= s1;
        end
    end

    assign {s1_ir,s1_pc,s1_cif} = s1[`ILEN+`XLEN+2-1:1];
    assign {s2_ir,s2_pc,s2_cif} = s2[`ILEN+`XLEN+2-1:1];
    assign s1_vld = s1[0] & ~hld;
    assign s2_vld = s2[0] & ~hld;
endmodule

