`include "timescale.vh"
`include "femto.vh"

module core (
    input wire clk,
    input wire rstn,

    // fault
    output wire            core_fault,
    output wire[`XLEN-1:0] core_fault_pc,

    // external interrupt
    input wire  ext_int_req,
    output wire ext_int_resp,

    // external dbg trigger
    input wire  ext_dbg_req,
    output wire ext_dbg_resp,

    // data bus interface
    output wire[`XLEN-1:0]                dbus_addr, // byte addr
    output wire                           dbus_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] dbus_acc,
    input wire[`BUS_WIDTH-1:0]            dbus_rdata,
    output wire[`BUS_WIDTH-1:0]           dbus_wdata,
    output wire                           dbus_req,
    input wire                            dbus_resp,
    input wire                            dbus_fault,

    // instruction bus interface
    output wire[`XLEN-1:0]                ibus_addr, // byte addr
    output wire                           ibus_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] ibus_acc,
    input wire[`BUS_WIDTH-1:0]            ibus_rdata,
    output wire[`BUS_WIDTH-1:0]           ibus_wdata,
    output wire                           ibus_req,
    input wire                            ibus_resp,
    input wire                            ibus_fault
);

    `include "core.vh"

    /**********************************************************************************************************************/
    // pipeline flow control
    wire jmp, hld;
    wire[`XLEN-1:0] jmp_addr;

    // data bus access
    wire dbus_req;
    wire dbus_req_w_rb;
    wire[$clog2(`BUS_ACC_CNT)-1:0] dbus_req_acc;
    wire[`XLEN-1:0] dbus_req_addr;
    wire[`BUS_WIDTH-1:0] dbus_req_wdata;
    wire dbus_req_launched;
    wire dbus_resp_latched;
    wire dbus_resp_w_rb;
    wire[$clog2(`BUS_ACC_CNT)-1:0] dbus_resp_acc;
    wire[`BUS_WIDTH-1:0] dbus_resp_data;

    // instruction bus access
    wire ibus_req;
    wire[`XLEN-1:0] ibus_req_addr;
    wire[$clog2(`BUS_ACC_CNT)-1:0] ibus_req_acc;
    wire ibus_req_launched;
    wire ibus_resp_latched;
    wire[$clog2(`BUS_ACC_CNT)-1:0] ibus_resp_acc;
    wire[`ILEN-1:0] ibus_resp_data;

    // pipeline stages (pc, ir)
    wire s0_vld;
    wire s0_cif; // compressed instruction flag
    wire[`ILEN-1:0] s0_ir; // instruction
    wire[`XLEN-1:0] s0_pc;

    wire s1_vld;
    wire s1_cif; // compressed instruction flag
    wire[`ILEN-1:0] s1_ir;
    wire[`XLEN-1:0] s1_pc;

    wire s2_vld;
    wire s2_cif; // compressed instruction flag
    wire[`ILEN-1:0] s2_ir;
    wire[`XLEN-1:0] s2_pc;

    // cross pipeline stage signals
    wire s0_iif; // illegal instruction flag
    wire s1_iif;
    wire s2_iif;

    wire[3:0] s1_rd; // dest reg index
    wire[`XLEN-1:0] s1_alu_a, s1_alu_b;
    wire[7:0] s1_alu_op; // alu operation
    wire[7:0] s1_op; // instruction operation
    wire[$clog2(CSR_NUM)-1:0] s1_csr; // dest csr index
    wire[`XLEN-1:0] s1_csr_val;
    wire s1_jmp_req;
    wire[`XLEN-1:0] s1_jmp_lr; // jump link register/return address
    wire s1_dbus_req;

    wire[3:0] s2_rd; // dest reg index
    wire[`XLEN-1:0] s2_alu_a, s2_alu_b;
    wire[7:0] s2_alu_op; // alu operation
    wire[7:0] s2_op; // instruction operation
    wire[`XLEN-1:0] s2_jmp_lr; // jump link register/return address
    wire[$clog2(CSR_NUM)-1:0] s2_csr; // dest csr index
    wire[`XLEN-1:0] s2_csr_val;

    // trap control signals
    wire interrupt, succesional_interrupt;

    // dbg control signals
    wire trigger;

    // regfile signals
    wire regfile_w_req;
    wire[3:0] regfile_w_idx;
    wire[`XLEN-1:0] regfile_w_data;

    // csr signals
    wire[$clog2(CSR_NUM)-1:0] csr_w_idx;
    wire[`XLEN-1:0] csr_w_data;
    wire[`XLEN-1:0] csr_r_data[0:CSR_NUM-1];

    /**********************************************************************************************************************/
    begin:BUS_REQ_CTRL
        // Bus busy indicator
        wire    ibus_busy_post, ibus_busy;
        wire    dbus_busy_post, dbus_busy;
        dff #(
            .RESET("sync"),
            .VALID("sync")
        ) ibus_busy_dff (
            .clk (clk                 ),
            .rstn(rstn                ),
            .vld (ibus_req | ibus_resp),
            .in  (ibus_req            ),
            .out (ibus_busy_post      )
         );
        assign ibus_busy = ~ibus_resp & ibus_busy_post;

        dff #(
            .RESET("sync"),
            .VALID("sync")
        ) dbus_busy_dff (
            .clk (clk                 ),
            .rstn(rstn                ),
            .vld (dbus_req | dbus_resp),
            .in  (dbus_req            ),
            .out (dbus_busy_post      )
        );
        assign dbus_busy = ~dbus_resp & dbus_busy_post;

        assign ibus_req   = ibus_req & ~ibus_busy;
        assign ibus_addr  = ibus_req_addr;
        assign ibus_w_rb  = 1'b0;
        assign ibus_acc   = ibus_req_acc;
        assign ibus_wdata = 32'dx; // for error detection in simulation

        assign dbus_req   = dbus_req & ~dbus_busy;
        assign dbus_addr  = dbus_req_addr;
        assign dbus_w_rb  = dbus_req_w_rb;
        assign dbus_acc   = dbus_req_acc;
        assign dbus_wdata = dbus_req_wdata;

        assign ibus_req_launched = ibus_req;
        assign dbus_req_launched = dbus_req;
     end

    /**********************************************************************************************************************/
    begin:BUS_RESP_CTRL
        wire    ibus_resp_w_rb, dbus_resp_w_rb;
        wire[$clog2(`BUS_ACC_CNT)-1:0]  ibus_resp_acc, dbus_resp_acc;

        wire    ibus_req_not_cancelled; // jmp ignores the matching ibus_resp, so as to cancel ibus_req
        dff #(
            .WIDTH($clog2(`BUS_ACC_CNT) + 1),
            .VALID("sync"),
            .CLEAR("sync") // so as to cancel ibus_req
        ) ibus_resp_dff (
            .clk(clk                                    ),
            .clr(jmp                                    ),
            .vld(ibus_req                               ),
            .in ({ibus_acc, 1'b1}                       ),
            .out({ibus_resp_acc, ibus_req_not_cancelled})
        );
        assign ibus_resp_w_rb = 1'b0; // Always read access

        dff #(
            .WIDTH($clog2(`BUS_ACC_CNT) + 1),
            .VALID("sync"                  )
        ) dbus_resp_dff (
            .clk(clk                            ),
            .clr(jmp                            ),
            .vld(dbus_req                       ),
            .in ({dbus_acc, dbus_w_rb}          ),
            .out({dbus_resp_acc, dbus_resp_w_rb})
        );

        assign ibus_resp_latched = ibus_resp & ibus_req_not_cancelled;
        assign ibus_resp_acc = ibus_resp_acc;
        assign ibus_resp_data = ibus_rdata;

        assign dbus_resp_latched = dbus_resp;
        assign dbus_resp_acc = dbus_resp_acc;
        assign dbus_resp_data = dbus_rdata;
        assign dbus_resp_w_rb = dbus_resp_w_rb;
    end

    /**********************************************************************************************************************/
    begin:STAGE0 // instruction fetch
        wire[`XLEN-1:0] if_next_req_addr = jmp ? jmp_addr : (ibus_req_acc==`BUS_ACC_2B) ? (ibus_req_addr+2) : (ibus_req_addr+4);
        dff #(
            .WIDTH      (`XLEN    ),
            .INITIALIZER(`RESET_PC),
            .RESET      ("sync"   ),
            .VALID      ("sync"   )
        ) if_req_addr_dff ( // this is not called "pc" because the addr can be in the middle of an instruction
            .clk (clk                    ),
            .rstn(rstn                   ),
            .vld (jmp | ibus_req_launched),
            .in  (if_next_req_addr       ),
            .out (ibus_req_addr          )
        );

        wire ibus_got_16bit_rdata = (ibus_resp_acc==`BUS_ACC_2B);
        wire[1:0] ifq_vacant_entry_in_16bit, ifq_filled_entry_in_16bit;
        assign ibus_req = (ifq_vacant_entry_in_16bit != 2'd0);
        assign ibus_req_acc = (ibus_req_addr[1] || ifq_filled_entry_in_16bit) ? `BUS_ACC_2B : `BUS_ACC_4B;

        wire[`ILEN-1:0] if_ir_raw;
        instr_fetch_queue ifq(
            .clk             (clk ),
            .rstn            (rstn),
            .clr             (jmp ),

            .in_req                (ibus_resp_latched        ),
            .in_16bit              (ibus_got_16bit_rdata     ),
            .in                    (ibus_resp_data           ),
            .vacant_16bit_entry_cnt(ifq_vacant_entry_in_16bit),

            .out_req               (s0_vld                   ),
            .out_16bit             (s0_cif                   ),
            .out                   (if_ir_raw                ),
            .filled_16bit_entry_cnt(ifq_filled_entry_in_16bit)
        );

        assign s0_vld = ~hld & ((ifq_filled_entry_in_16bit==2'd2) || (ifq_filled_entry_in_16bit && s0_cif)); // instruction fetch control

        instr_decompressor instr_decompressor(
            .in_instr(if_ir_raw),
            .out_ir  (s0_ir    ),
            .out_cif (s0_cif   ),
            .out_iif (s0_iif   )
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
                   PLC_JUMP_P = 1, // jump preparing
                   PLC_JUMP_I = 2, // jump initiating
                   PLC_JUMP_E = 3, // jump executing
                   PLC_DATA_I = 4, // data req initiating
                   PLC_DATA_E = 5, // data req executing
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

        always @ (*) case(state)
            PLC_NORMAL:
                if (s1_vld & s1_jmp_req)
                    next_state = PLC_JUMP_P;
                else if (s1_vld & s1_dbus_req)
                    next_state = PLC_DATA_I;
                else // do not infer latch
                    next_state = PLC_NORMAL;
            PLC_JUMP_P:
                next_state = PLC_JUMP_I;
            PLC_JUMP_I:
                if (ibus_req_launched)
                    next_state = PLC_JUMP_E;
                else
                    next_state = PLC_JUMP_I;
            PLC_JUMP_E:
                if (ibus_resp_latched) begin
                    if (s1_vld & s1_jmp_req)
                        next_state = PLC_JUMP_P;
                    else if (s1_vld & s1_dbus_req)
                        next_state = PLC_DATA_I;
                    else // do not infer latch
                        next_state = PLC_NORMAL;
                end else
                    next_state = PLC_JUMP_E;
            PLC_DATA_I:
                if (dbus_req_launched)
                    next_state = PLC_DATA_E;
                else
                    next_state = PLC_DATA_I;
            PLC_DATA_E:
                if (dbus_resp_latched) begin
                    if (s1_vld & s1_jmp_req)
                        next_state = PLC_JUMP_P;
                    else if (s1_vld & s1_dbus_req)
                        next_state = PLC_DATA_I;
                    else // do not infer latch
                        next_state = PLC_NORMAL;
                end else
                    next_state = PLC_DATA_E;
            default:
                next_state = PLC_NORMAL;
        endcase

        assign jmp = state==PLC_JUMP_P;
        assign hld = (state==PLC_JUMP_P || state==PLC_JUMP_I || state==PLC_DATA_I) ||
                     (state==PLC_JUMP_E && ~ibus_resp_latched) ||
                     (state==PLC_DATA_E && ~dbus_resp_latched);
    end // PIPELINE

    /**********************************************************************************************************************/
    begin:STAGE1 // instruction expansion & decoding
        wire s1_partial_iif; // to be OR'ed with S1's iif logic
        dff #(
            .WIDTH(1),
            .VALID("sync")
        ) s1_partial_iif_dff (
            .clk(clk           ),
            .vld(s0_vld        ),
            .in (s0_iif        ),
            .out(s1_partial_iif)
        );

        // x regfile
        wire[`XLEN-1:0] x[0:15];
        regfile regfile(
            .clk   (clk           ),
            .wreq  (regfile_w_req  ),
            .windex(regfile_w_idx),
            .wdata (regfile_w_data ),
            .x0    (x[0 ]         ),
            .x1    (x[1 ]         ),
            .x2    (x[2 ]         ),
            .x3    (x[3 ]         ),
            .x4    (x[4 ]         ),
            .x5    (x[5 ]         ),
            .x6    (x[6 ]         ),
            .x7    (x[7 ]         ),
            .x8    (x[8 ]         ),
            .x9    (x[9 ]         ),
            .x10   (x[10]         ),
            .x11   (x[11]         ),
            .x12   (x[12]         ),
            .x13   (x[13]         ),
            .x14   (x[14]         ),
            .x15   (x[15]         )
        );

        wire[$clog2(`BUS_ACC_CNT)-1:0] s1_dbus_req_acc;
        wire s1_dbus_req_w_rb;
        wire[`BUS_WIDTH-1:0] s1_dbus_req_wdata;
        begin:DECODE
            // decoder
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
            wire[31:0] csr_uimm = {27'd0, rs1};

            wire[$clog2(CSR_NUM)-1:0] csr_index = `CSR_ADDR_TO_INDEX;

            wire[`XLEN-1:0] rs1_val, rs2_val;
            wire[`XLEN-1:0] imm_val;

            assign rs1_val =
                (regfile_w_req && rs1[3:0]==regfile_w_idx) ?
                    regfile_w_data :
                /* otherwise */
                    x[rs1[3:0]];

            assign rs2_val =
                (regfile_w_req && rs2[3:0]==regfile_w_idx) ?
                    regfile_w_data :
                /* otherwise */
                    x[rs2[3:0]];

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
                (opcode==OPCODE_FENCE) ?
                    32'd4 : /* 4 for FENCE.I, do-not-care for FENCE */
                (opcode==OPCODE_SYSTEM) ?
                    csr_uimm :
                /* otherwise */
                    shamt;

            // signals for wider use
            assign s1_rd =
                interrupt ?
                    4'd0 /* interrupt/return seen as an instruction where rd=0 */ :
                (opcode==OPCODE_BRANCH || opcode==OPCODE_STORE || opcode==OPCODE_FENCE) /* rd not available */ ?
                    4'd0 /* available yet should not be used for FENCE.I/FENCE */ :
                /* rd available */
                    rd[3:0];

            assign s1_csr = csr_index;

            assign s1_csr_val = csr_r_data[csr_index];

            assign s1_alu_a =
                interrupt ?
                    csr_r_data[CSR_INDEX_MTVEC] :
                (opcode==OPCODE_SYSTEM) ? (
                    funct3[1:0] ? // csr op
                        (funct3[1] ? csr_r_data[csr_index] /* bit set/clr */ : {`XLEN{1'b0}} /* val set */) :
                    // mret
                        (succesional_interrupt ? csr_r_data[CSR_INDEX_MTVEC] /* successional traps */ : csr_r_data[CSR_INDEX_MEPC])
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

            assign s1_dbus_req = (opcode==OPCODE_LOAD || opcode==OPCODE_STORE) && !interrupt;
            assign s1_dbus_req_acc = (funct3[1:0]==2'd0 ? `BUS_ACC_1B : funct3[1:0]==2'd1 ? `BUS_ACC_2B : `BUS_ACC_4B);
            assign s1_dbus_req_w_rb = (opcode==OPCODE_STORE);
            assign s1_dbus_req_wdata = rs2_val;

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
                            // csr ops, mstatus/mtvec/mepc/mip/dpc/dcsr/tdata1/tdata2 permitted (no csr addr validity check here)
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
        ) dbus_req_dff (
            .clk (clk              ),
            .rstn(rstn             ),
            .clr (dbus_req_launched   ),
            .vld (s1_vld & s1_dbus_req),
            .in  (s1_dbus_req         ),
            .out (dbus_req            )
        );

        dff #(
            .WIDTH($clog2(`BUS_ACC_CNT)+1+`BUS_WIDTH),
            .VALID("sync")
        ) dbus_req_info_dff (
            .clk(clk),
            .vld(s1_vld),
            .in ({s1_dbus_req_acc,s1_dbus_req_w_rb,s1_dbus_req_wdata}),
            .out({dbus_req_acc,   dbus_req_w_rb,   dbus_req_wdata   })
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
            .in ({s1_rd,s1_alu_a,s1_alu_b,s1_alu_op,s1_op,s1_jmp_lr,s1_csr,s1_csr_val}),
            .out({s2_rd,s2_alu_a,s2_alu_b,s2_alu_op,s2_op,s2_jmp_lr,s2_csr,s2_csr_val})
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
        assign jmp_addr = {alu_r[`XLEN-1:1], ((s2_op==OP_JALR) ? 1'b0 : alu_r[0])}; // jmp_addr[0] clamped 1'b0 upon JALR
        assign dbus_req_addr = alu_r;

        // regfile w access
        assign regfile_w_req = s2_vld && regfile_w_idx;
        assign regfile_w_idx = s2_rd;
        assign regfile_w_data =
            (s2_op==OP_LD) ? (
                (dbus_resp_acc==`BUS_ACC_1B) ?
                    {{24{dbus_resp_data[7]}}, dbus_resp_data[7:0]} :
                (dbus_resp_acc==`BUS_ACC_2B) ?
                    {{16{dbus_resp_data[15]}}, dbus_resp_data[15:0]} :
                /*otherwise*/
                    dbus_resp_data
            ) :
            (s2_op==OP_LDU) ? (
                (dbus_resp_acc==`BUS_ACC_1B) ?
                    {24'd0, dbus_resp_data[7:0]} :
                /*dbus_resp_acc==`BUS_ACC_2B*/
                    {16'd0, dbus_resp_data[15:0]}
            ) :
            (s2_op==OP_JAL || s2_op==OP_JALR) ?
                s2_jmp_lr :
            (s2_op==OP_CSR) ?
                s2_csr_val :
            /* otherwise treated as OP_STD */
                alu_r;

        // csr w access : only user csr access instructions are handled, not for trap entry/mret
        assign csr_w_idx = s2_csr;
        assign csr_w_data = alu_r;

        begin:CSR // csr control
            // csr array
            reg[`XLEN-1:0] csr[0:CSR_NUM-1];

            // csr read definition
            for(genvar i=0; i<CSR_NUM; i=i+1) begin
                case (i)
                    CSR_INDEX_MIP    : assign csr_r_data[i] = {csr[i][`XLEN-1:`MEIP+1], ext_int_req, csr[i][`MEIP-1:0]};
                    CSR_INDEX_TDATA2 :
                    CSR_INDEX_TDATA1 :
                    CSR_INDEX_DCSR   :
                    CSR_INDEX_DPC    :
                    default          : assign csr_r_data[i] = csr[i];
                endcase
            end

            // csr write operation
            always @ (posedge clk) begin
                if (~rstn) begin
                    csr[CSR_INDEX_MSTATUS][`MIE ] <= `INT_RST_EN;
                    // csr[CSR_INDEX_MIE    ][`MEIE] <= 1'b1;
                end else if (s2_vld) begin
                    if (s2_op==OP_CSR) begin
                        csr[csr_w_idx] <= csr_w_data;
                    end else if (s2_op==OP_TRAP_SUC) begin
                        // csr[CSR_INDEX_MCAUSE] <= MCAUSE_MEXTINT;
                        csr[CSR_INDEX_MSTATUS][`MIE] <= 1'b0;
                    end else if (s2_op==OP_TRAP) begin
                        csr[CSR_INDEX_MEPC] <= s2_jmp_lr;
                        // csr[CSR_INDEX_MCAUSE] <= MCAUSE_MEXTINT;
                        csr[CSR_INDEX_MSTATUS][`MIE ] <= 1'b0;
                        csr[CSR_INDEX_MSTATUS][`MPIE] <= csr_r_data[CSR_INDEX_MSTATUS][`MIE];
                    end else if (s2_op==OP_TRAP_RET) begin
                        csr[CSR_INDEX_MSTATUS][`MIE ] <= csr_r_data[CSR_INDEX_MSTATUS][`MPIE];
                    end
                end
            end
        end

        begin:TRAP // trap control
            assign ext_int_resp = s2_vld && (s2_op==OP_TRAP || s2_op==OP_TRAP_SUC);
            assign interrupt = csr_r_data[CSR_INDEX_MSTATUS][`MIE] && (/*csr_r_data[CSR_INDEX_MIE][`MEIE] &&*/ csr_r_data[CSR_INDEX_MIP][`MEIP]);
            assign succesional_interrupt = csr_r_data[CSR_INDEX_MSTATUS][`MPIE] && (/*csr_r_data[CSR_INDEX_MIE][`MEIE] &&*/ csr_r_data[CSR_INDEX_MIP][`MEIP]);
        end // TRAP

        begin:DBG // dbg/trigger control
            assign
        end
    end // STAGE2

    /**********************************************************************************************************************/
    // fault propagation
    dff #(
        .RESET("sync")
    ) core_fault_dff (
        .clk (clk                   ),
        .rstn(rstn                  ),
        .in  (s1_vld & s1_iif),
        .out (core_fault            )
    );

    dff #(
        .WIDTH(`XLEN ),
        .VALID("sync")
    ) core_fault_pc_dff (
        .clk (clk                   ),
        .vld (s1_vld & s1_iif),
        .in  (s1_pc                 ),
        .out (core_fault_pc         )
    );

endmodule

/**********************************************************************************************************************/
module alu(
    input wire[7:0]        op,
    input wire[`XLEN-1:0]  a,
    input wire[`XLEN-1:0]  b,
    output wire[`XLEN-1:0] r
);
    localparam SHIFTWIDTH = $clog2(`XLEN);
    wire[SHIFTWIDTH-1:0] shift = b[SHIFTWIDTH-1:0];

    wire[`XLEN-1:0] sra_r = $signed(a)>>>shift,
                    lt_r  = $signed(a)<$signed(b);

    `include "core.vh"

    assign r =
        op==ALU_SUB ? (a-b     ):
        op==ALU_AND ? (a&b     ):
        op==ALU_OR  ? (a|b     ):
        op==ALU_CLR ? (a & ~b  ):
        op==ALU_XOR ? (a^b     ):
        op==ALU_LTU ? (a<b     ):
        op==ALU_LT  ? (lt_r    ):
        op==ALU_SRL ? (a>>shift):
        op==ALU_SRA ? (sra_r   ):
        op==ALU_SL  ? (a<<shift):
        /* ALU_ADD */ (a+b     );
endmodule

/**********************************************************************************************************************/
module regfile(
    input wire             clk,

    input wire             wreq,
    input wire[3:0]        windex,
    input wire[`XLEN-1:0]  wdata,

    output wire[`XLEN-1:0] x0,
    output wire[`XLEN-1:0] x1,
    output wire[`XLEN-1:0] x2,
    output wire[`XLEN-1:0] x3,
    output wire[`XLEN-1:0] x4,
    output wire[`XLEN-1:0] x5,
    output wire[`XLEN-1:0] x6,
    output wire[`XLEN-1:0] x7,
    output wire[`XLEN-1:0] x8,
    output wire[`XLEN-1:0] x9,
    output wire[`XLEN-1:0] x10,
    output wire[`XLEN-1:0] x11,
    output wire[`XLEN-1:0] x12,
    output wire[`XLEN-1:0] x13,
    output wire[`XLEN-1:0] x14,
    output wire[`XLEN-1:0] x15
);

    reg[`XLEN-1:0] xr[1:15];
    assign x0  = 0;
    assign x1  = xr[1 ];
    assign x2  = xr[2 ];
    assign x3  = xr[3 ];
    assign x4  = xr[4 ];
    assign x5  = xr[5 ];
    assign x6  = xr[6 ];
    assign x7  = xr[7 ];
    assign x8  = xr[8 ];
    assign x9  = xr[9 ];
    assign x10 = xr[10];
    assign x11 = xr[11];
    assign x12 = xr[12];
    assign x13 = xr[13];
    assign x14 = xr[14];
    assign x15 = xr[15];

    always @ (posedge clk) begin
        if (wreq && windex) begin
            xr[windex] <= wdata;
        end
    end
endmodule

/**********************************************************************************************************************/
module instr_fetch_queue (
    input wire          clk,
    input wire          rstn,

    input wire          in_req,
    input wire          in_16bit, // 0:32-bit data, 1:16-bit data
    input wire[31:0]    in,

    input wire          out_req,
    input wire          out_16bit, // 0:32-bit data, 1:16-bit data
    output wire[31:0]   out,

    input wire          clr,

    output wire[1:0]    vacant_16bit_entry_cnt,
    output wire[1:0]    filled_16bit_entry_cnt
);
    generate
        for(genvar i=0;i<2;i=i+1) begin:pingpong
            wire w, r;
            wire full, empty;
            wire almost_full, almost_empty;
            wire[15:0] din, dout;
            fifo #(
                .WIDTH(16    ),
                .DEPTH(2     ),
                .CLEAR("sync")
            ) fifo (
                .clk         (clk         ),
                .rstn        (rstn        ),
                .din         (din         ),
                .dout        (dout        ),
                .w           (w           ),
                .r           (r           ),
                .clr         (clr         ),
                .full        (full        ),
                .empty       (empty       ),
                .almost_full (almost_full ),
                .almost_empty(almost_empty)
            );
        end
    endgenerate

    reg wsel, rsel;

    // note: both fifos' depth are 2, and we'are not expecting "one:2, the other:0" situation
    // note: actual capacity of the queue is 4 entries, but we would reserve 2 for an incoming (outgoing) 32-bit instruction for safety
    //       while the instruction is being written into (read from) fifos, we cannot see full (empty) flag change
    assign vacant_16bit_entry_cnt =
        (pingpong[0].full & pingpong[1].full) ?
            2'd0 : // actually 0
        ((pingpong[0].full & pingpong[1].almost_full) | (pingpong[1].full & pingpong[0].almost_full)) ?
            2'd0 : // actually 1
        (pingpong[0].almost_full & pingpong[1].almost_full) ?
            2'd0 : // actually 2
        (pingpong[0].almost_full ^ pingpong[1].almost_full) ?
            2'd1 : // actually 3
        /* ~pingpong[0].almost_full & ~pingpong[1].almost_full */
            2'd2;  // actually >=4

    assign filled_16bit_entry_cnt =
        (pingpong[0].empty & pingpong[1].empty) ?
            2'd0 : // actually 0
        ((pingpong[0].empty & pingpong[1].almost_empty) | (pingpong[1].empty & pingpong[0].almost_empty)) ?
            2'd1 : // actually 1
        (pingpong[0].almost_empty & pingpong[1].almost_empty) ?
            2'd2 : // actually 2
        (pingpong[0].almost_empty ^ pingpong[1].almost_empty) ?
            2'd2 : // actually 3
        /* ~pingpong[0].almost_empty & ~pingpong[1].almost_empty */
            2'd2;  // actually >=4

    assign pingpong[0].w = in_req & (~in_16bit | ~wsel);
    assign pingpong[1].w = in_req & (~in_16bit | wsel);

    assign pingpong[0].r = out_req & (~out_16bit | ~rsel);
    assign pingpong[1].r = out_req & (~out_16bit | rsel);

    assign pingpong[0].din = wsel ? in[31:16] : in[15:0];
    assign pingpong[1].din = wsel ? in[15:0] : in[31:16];

    assign out[15:0] = rsel ? pingpong[1].dout : pingpong[0].dout;
    assign out[31:16] = rsel ? pingpong[0].dout : pingpong[1].dout;

    always @ (posedge clk) begin
        if (~rstn | clr) begin
            wsel <= 1'b0;
            rsel <= 1'b0;
        end else begin
            if (~(pingpong[0].full & pingpong[1].full) & in_req & in_16bit) begin
                wsel <= ~wsel;
            end
            if (~(pingpong[0].empty & pingpong[1].empty) & out_req & out_16bit) begin
                rsel <= ~rsel;
            end
        end
    end
endmodule

/**********************************************************************************************************************/
module instr_decompressor( // conpressed instruction expansion
    input wire[`ILEN-1:0]   in_instr,
    output wire[`ILEN-1:0]  out_ir,  // decompressed instruction
    output wire             out_cif, // compressed instruction flag (whether in_instr is compressed)
    output wire             out_iif  // illegal instruction flag
);
// instruction with OPCODE_NC are fed through instr_decompressor
`include "core.vh"

    assign out_cif = in_instr[1:0]!=OPCODE_NC;
    // 16-32bit expansion
    wire[1:0] opcode = in_instr[1:0];
    wire[2:0] funct3 = in_instr[15:13];
    wire[4:0] rd_rs1 = in_instr[11:7];
    wire[4:0] rs2 = in_instr[6:2];
    wire[2:0] rd_q_rs1_q = in_instr[9:7];
    wire[2:0] rd_q_rs2_q = in_instr[4:2];

    assign out_iif = out_cif &&
        (
            (opcode==OPCODE_C0 && (
                (funct3==3'b000 && in_instr[12:5]==8'd0) ||
                (funct3==3'b001) ||
                (funct3==3'b011) ||
                (funct3==3'b100) ||
                (funct3==3'b101) ||
                (funct3==3'b111)
            )) ||
            (opcode==OPCODE_C1 && (
                (funct3==3'b011 && {in_instr[12],in_instr[6:2]}==6'd0) ||
                (funct3==3'b100 && in_instr[11:10]!=2'b10 && in_instr[12])
            )) ||
            (opcode==OPCODE_C2 && (
                (funct3==3'b000 && in_instr[12]) ||
                (funct3==3'b001) ||
                (funct3==3'b010 && rd_rs1==5'd0) ||
                (funct3==3'b011) ||
                (funct3==3'b100 && (
                    (~in_instr[12] && rd_rs1==5'd0 && rs2==5'd0) ||
                    (in_instr[12] && rd_rs1==5'd0 && rs2==5'd0) //c.ebreak
                )) ||
                (funct3==3'b101) ||
                (funct3==3'b111)
            ))
        );

    assign out_ir =
        (opcode==OPCODE_C0) ? (
            funct3==3'b000 ? {{2'd0,in_instr[10:7],in_instr[12:11],in_instr[5],in_instr[6],2'd0},5'd2/*x2*/,3'b000,{2'b01,rd_q_rs2_q},OPCODE_IMMCAL} : //c.addi4spn
            funct3==3'b010 ? {{5'd0,in_instr[5],in_instr[12:10],in_instr[6],2'd0},{2'b01,rd_q_rs1_q},3'b010,{2'b01,rd_q_rs2_q},OPCODE_LOAD} : //c.lw
            /*funct3==3'b110*/ {{5'd0,in_instr[5],in_instr[12]},{2'b01,rd_q_rs2_q},{2'b01,rd_q_rs1_q},3'b010,{in_instr[11:10],in_instr[6],2'd0},OPCODE_STORE} //c.sw
        ) :
        (in_instr[1:0]==OPCODE_C1) ? (
            funct3==3'b000 ? {{{7{in_instr[12]}},in_instr[6:2]},rd_rs1,3'b000,rd_rs1,OPCODE_IMMCAL} : //c.addi
            funct3==3'b001 ? {{in_instr[12],in_instr[8],in_instr[10:9],in_instr[6],in_instr[7],in_instr[2],in_instr[11],in_instr[5:3],{9{in_instr[12]}}},5'd1/*x1*/,OPCODE_JAL} : //c.jal
            funct3==3'b010 ? {{{7{in_instr[12]}},in_instr[6:2]},5'd0/*x0*/,3'b000,rd_rs1,OPCODE_IMMCAL} : //c.li
            funct3==3'b011 ? (
                rd_rs1==5'd2 ? {{{3{in_instr[12]}},in_instr[4:3],in_instr[5],in_instr[2],in_instr[6],4'd0},5'd2/*x2*/,3'b000,5'd2/*x2*/,OPCODE_IMMCAL} : //c.addi16sp
                               {{{15{in_instr[12]}},in_instr[6:2]},rd_rs1,OPCODE_LUI} //c.lui
            ) :
            funct3==3'b100 ? (
                in_instr[11:10]==2'b00 ? {7'b0000000,in_instr[6:2],{2'b01,rd_q_rs1_q},3'b101,{2'b01,rd_q_rs1_q},OPCODE_IMMCAL} : //c.srli
                in_instr[11:10]==2'b01 ? {7'b0100000,in_instr[6:2],{2'b01,rd_q_rs1_q},3'b101,{2'b01,rd_q_rs1_q},OPCODE_IMMCAL} : //c.srai
                in_instr[11:10]==2'b10 ? {{{7{in_instr[12]}},in_instr[6:2]},{2'b01,rd_q_rs1_q},3'b111,{2'b01,rd_q_rs1_q},OPCODE_IMMCAL} : //c.andi
                /*in_instr[11:10]==2'b11*/ (
                    in_instr[6:5]==2'b00 ? {7'b0100000,{2'b01,rd_q_rs2_q},{2'b01,rd_q_rs1_q},3'b000,{2'b01,rd_q_rs1_q},OPCODE_CAL} : //c.sub
                    in_instr[6:5]==2'b01 ? {7'b0000000,{2'b01,rd_q_rs2_q},{2'b01,rd_q_rs1_q},3'b100,{2'b01,rd_q_rs1_q},OPCODE_CAL} : //c.xor
                    in_instr[6:5]==2'b10 ? {7'b0000000,{2'b01,rd_q_rs2_q},{2'b01,rd_q_rs1_q},3'b110,{2'b01,rd_q_rs1_q},OPCODE_CAL} : //c.or
                                 /*2'b11*/ {7'b0000000,{2'b01,rd_q_rs2_q},{2'b01,rd_q_rs1_q},3'b111,{2'b01,rd_q_rs1_q},OPCODE_CAL}   //c.and
                )
            ) :
            funct3==3'b101 ? {{in_instr[12],in_instr[8],in_instr[10:9],in_instr[6],in_instr[7],in_instr[2],in_instr[11],in_instr[5:3],{9{in_instr[12]}}},5'd0/*x0*/,OPCODE_JAL} : //c.j
            funct3==3'b110 ? {{{4{in_instr[12]}},in_instr[6:5],in_instr[2]},5'd0/*x0*/,{2'b01,rd_q_rs1_q},3'b000,{in_instr[11:10],in_instr[4:3],in_instr[12]},OPCODE_BRANCH} : //c.beqz
            /*funct3==3'b111*/ {{{4{in_instr[12]}},in_instr[6:5],in_instr[2]},5'd0/*x0*/,{2'b01,rd_q_rs1_q},3'b001,{in_instr[11:10],in_instr[4:3],in_instr[12]},OPCODE_BRANCH} //c.bnez
        ) :
        (in_instr[1:0]==OPCODE_C2) ? (
            funct3==3'b000 ? {7'b0000000,in_instr[6:2],rd_rs1,3'b001,rd_rs1,OPCODE_IMMCAL} : //c.slli
            funct3==3'b010 ? {{4'd0,in_instr[3:2],in_instr[12],in_instr[6:4],2'd0},5'd2/*x2*/,3'b010,rd_rs1,OPCODE_LOAD} : //c.lwsp
            funct3==3'b100 ? (
                (~in_instr[12]) ? (
                    (in_instr[6:2]==5'd0) ? {12'd0,rd_rs1,3'b000,5'd0/*x0*/,OPCODE_JALR} : //c.jr
                    /*in_instr[6:2]!=5'd0*/ {7'b0000000,rs2,5'd0/*x0*/,3'b000,rd_rs1,OPCODE_CAL} //c.mv
                ) :
                /*in_instr[12]*/ (
                    (in_instr[6:2]==5'd0) ? {12'd0,rd_rs1,3'b000,5'd1/*x1*/,OPCODE_JALR} : //c.jalr
                    /*in_instr[6:2]!=5'd0*/ {7'b0000000,rs2,rd_rs1,3'b000,rd_rs1,OPCODE_CAL} //c.add
                )
            ) :
            /*funct3==3'b110*/ {{4'd0,in_instr[8:7],in_instr[12]},rs2,5'd2/*x2*/,3'b010,{in_instr[11:9],2'd0},OPCODE_STORE} //c.swsp
        ) : (
        /* OPCODE_NC */
            in_instr
        );
endmodule

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
