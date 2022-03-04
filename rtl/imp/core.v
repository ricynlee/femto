`include "timescale.vh"
`include "femto.vh"

module core (
    input wire  clk,
    input wire  rstn,

    // fault
    output reg              core_fault,
    output reg[`XLEN-1:0]   core_fault_pc,

    // data bus interface
    output wire[`XLEN-1:0]                  dbus_addr, // byte addr
    output wire                             dbus_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0]   dbus_acc,
    input wire[`BUS_WIDTH-1:0]              dbus_rdata,
    output wire[`BUS_WIDTH-1:0]             dbus_wdata,
    output wire                             dbus_req,
    input wire                              dbus_resp,

    // instruction bus interface
    output wire[`XLEN-1:0]                  ibus_addr, // byte addr
    output wire                             ibus_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0]   ibus_acc,
    input wire[`BUS_WIDTH-1:0]              ibus_rdata,
    output wire[`BUS_WIDTH-1:0]             ibus_wdata,
    output wire                             ibus_req,
    input wire                              ibus_resp
);

    `include "core.vh"

    /**********************************************************************************************************************/
    // pipeline flow control
    wire jmp, hld;
    wire[`XLEN-1:0] jmp_addr;

    // data access
    wire d_req;
    wire d_req_w_rb;
    wire[$clog2(`BUS_ACC_CNT)-1:0] d_req_acc;
    wire[`XLEN-1:0] d_req_addr;
    wire[`BUS_WIDTH-1:0] d_req_wdata;

    wire d_req_launched;

    wire d_resp_latched;
    wire d_resp_w_rb;
    wire[$clog2(`BUS_ACC_CNT)-1:0] d_resp_acc;
    wire[`BUS_WIDTH-1:0] d_resp_data;

    // instruction access
    wire i_req;
    wire[`XLEN-1:0] i_req_addr;
    wire[$clog2(`BUS_ACC_CNT)-1:0] i_req_acc;

    wire i_req_launched;

    wire i_resp_latched;
    wire[$clog2(`BUS_ACC_CNT)-1:0] i_resp_acc;
    wire[`ILEN-1:0] i_resp_data;

    // pipeline stages
    wire if_vld;
    wire if_c;
    wire[`ILEN-1:0] if_ir;
    wire[`XLEN-1:0] if_pc;

    wire s1_vld;
    wire s1_c; // whether compressed
    wire[`ILEN-1:0] s1_ir;
    wire[`XLEN-1:0] s1_pc;

    wire s2_vld;
    wire s2_c;
    wire[`ILEN-1:0] s2_ir;
    wire[`XLEN-1:0] s2_pc;

    // other global signals
    wire regfile_wreq;
    wire [3:0] regfile_windex;
    wire [`XLEN-1:0] regfile_wdata;

    wire [3:0] s1_rd; // dest reg index
    wire [`XLEN-1:0] s1_alu_a, s1_alu_b;
    wire [7:0] s1_alu_op; // alu operation
    wire [7:0] s1_op; // instruction operation

    wire s1_j_req;
    wire [`XLEN-1:0] s1_j_lr; // jump link register/return address
    wire s1_d_req;

    wire [3:0] s2_rd; // dest reg index
    wire [`XLEN-1:0] s2_alu_a, s2_alu_b;
    wire [7:0] s2_alu_op; // alu operation
    wire [7:0] s2_op; // instruction operation
    wire [`XLEN-1:0] s2_j_lr; // jump link register/return address

    // fault indicators
    wire undef_instr, overshift;

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

        assign ibus_req   = i_req & ~ibus_busy;
        assign ibus_addr  = i_req_addr;
        assign ibus_w_rb  = 1'b0;
        assign ibus_acc   = i_req_acc;
        assign ibus_wdata = 32'dx; // for error detection in simulation

        assign dbus_req   = d_req & ~dbus_busy;
        assign dbus_addr  = d_req_addr;
        assign dbus_w_rb  = d_req_w_rb;
        assign dbus_acc   = d_req_acc;
        assign dbus_wdata = d_req_wdata;

        assign i_req_launched = ibus_req;
        assign d_req_launched = dbus_req;
     end

    /**********************************************************************************************************************/
    begin:BUS_RESP_CTRL
        wire    ibus_resp_w_rb, dbus_resp_w_rb;
        wire[$clog2(`BUS_ACC_CNT)-1:0]  ibus_resp_acc, dbus_resp_acc;

        wire    i_req_not_cancelled;
        dff #(
            .WIDTH($clog2(`BUS_ACC_CNT) + 1),
            .VALID("sync"),
            .CLEAR("sync") // so as to cancel i_req
        ) ibus_resp_dff (
            .clk(clk                                 ),
            .clr(jmp                                 ),
            .vld(ibus_req                            ),
            .in ({ibus_acc, 1'b1}                    ),
            .out({ibus_resp_acc, i_req_not_cancelled})
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

        assign i_resp_latched = ibus_resp & i_req_not_cancelled;
        assign i_resp_acc = ibus_resp_acc;
        assign i_resp_data = ibus_rdata;

        assign d_resp_latched = dbus_resp;
        assign d_resp_acc = dbus_resp_acc;
        assign d_resp_data = dbus_rdata;
        assign d_resp_w_rb = dbus_resp_w_rb;
    end

    /**********************************************************************************************************************/
    begin:PREFETCHER
        wire[`XLEN-1:0] pf_next_req_addr = jmp ? jmp_addr : (i_req_acc==`BUS_ACC_2B) ? (i_req_addr+2) : (i_req_addr+4);
        dff #(
            .WIDTH      (`XLEN    ),
            .INITIALIZER(`RESET_PC),
            .RESET      ("sync"   ),
            .VALID      ("sync"   )
        ) pf_req_addr_dff ( // note that i_req_addr is not subject to PF Q's in_req, but i_req & i_req_acc are
            .clk (clk                 ),
            .rstn(rstn                ),
            .vld (jmp | i_req_launched),
            .in  (pf_next_req_addr    ),
            .out (i_req_addr          )
        );

        wire i_resp_16_32b = (i_resp_acc==`BUS_ACC_2B);
        wire[1:0] pf_vacant_entry16, pf_filled_entry16;
        assign i_req = (pf_vacant_entry16!=2'd0);
        assign i_req_acc = (i_req_addr[1] || pf_filled_entry16!=2'd0) ? `BUS_ACC_2B : `BUS_ACC_4B;

        wire[`ILEN-1:0] if_ir_raw;
        prefetch_queue prefetch_queue(
            .clk             (clk              ),
            .rstn            (rstn             ),
            .clr             (jmp              ),

            .in_req          (i_resp_latched   ),
            .in_req_16_32bar (i_resp_16_32b    ),
            .in              (i_resp_data      ),
            .vacant_entry16  (pf_vacant_entry16),

            .out_req         (if_vld           ),
            .out_req_16_32bar(if_c             ),
            .out             (if_ir_raw        ),
            .filled_entry16  (pf_filled_entry16)
        );

        assign if_vld = ~hld & ((pf_filled_entry16==2'd2) || (pf_filled_entry16 && if_c)); // instruction fetch control

        expander expander(
            .in_instr (if_ir_raw),
            .out_instr(if_ir    ),
            .out_c    (if_c     )
        );

        wire[`XLEN-1:0] if_next_pc = jmp ? jmp_addr : (if_pc + (if_c ? 2 : 4));
        dff #(
            .WIDTH      (`XLEN    ),
            .INITIALIZER(`RESET_PC),
            .RESET      ("sync"   ),
            .VALID      ("sync"   )
        ) if_pc_dff (
            .clk (clk         ),
            .rstn(rstn        ),
            .vld (jmp | if_vld),
            .in  (if_next_pc  ),
            .out (if_pc       )
        );
    end // PREFETCHER

    /**********************************************************************************************************************/
    begin:PIPELINE // can be seen as part of stage1
        pipeline pipeline(
            .clk   (clk   ),
            .rstn  (rstn  ),
            .clr   (jmp   ),
            .hld   (hld   ),
            .in_ir (if_ir ),
            .in_pc (if_pc ),
            .in_c  (if_c  ),
            .in_vld(if_vld),
            .s1_ir (s1_ir ),
            .s1_pc (s1_pc ),
            .s1_c  (s1_c  ),
            .s1_vld(s1_vld),
            .s2_ir (s2_ir ),
            .s2_pc (s2_pc ),
            .s2_c  (s2_c  ),
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
                if (s1_vld & s1_j_req)
                    next_state = PLC_JUMP_P;
                else if (s1_vld & s1_d_req)
                    next_state = PLC_DATA_I;
                else // do not infer latch
                    next_state = PLC_NORMAL;
            PLC_JUMP_P:
                next_state = PLC_JUMP_I;
            PLC_JUMP_I:
                if (i_req_launched)
                    next_state = PLC_JUMP_E;
                else
                    next_state = PLC_JUMP_I;
            PLC_JUMP_E:
                if (i_resp_latched) begin
                    if (s1_vld & s1_j_req)
                        next_state = PLC_JUMP_P;
                    else if (s1_vld & s1_d_req)
                        next_state = PLC_DATA_I;
                    else // do not infer latch
                        next_state = PLC_NORMAL;
                end else
                    next_state = PLC_JUMP_E;
            PLC_DATA_I:
                if (d_req_launched)
                    next_state = PLC_DATA_E;
                else
                    next_state = PLC_DATA_I;
            PLC_DATA_E:
                if (d_resp_latched) begin
                    if (s1_vld & s1_j_req)
                        next_state = PLC_JUMP_P;
                    else if (s1_vld & s1_d_req)
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
                     (state==PLC_JUMP_E && ~i_resp_latched) ||
                     (state==PLC_DATA_E && ~d_resp_latched);
    end // PIPELINE

    /**********************************************************************************************************************/
    wire trap = 1'b0;
    begin:STAGE1 // instruction expansion & decoding
        // regfile
        wire [`XLEN-1:0] x[0:15];
        regfile regfile(
            .clk   (clk           ),
            .wreq  (regfile_wreq  ),
            .windex(regfile_windex),
            .wdata (regfile_wdata ),
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

        wire[$clog2(`BUS_ACC_CNT)-1:0] s1_d_req_acc;
        wire s1_d_req_w_rb;
        wire[`BUS_WIDTH-1:0] s1_d_req_wdata;
        begin:DECODE
            // decoder
            wire [31:0] i_type_imm = {{20{s1_ir[31]}}, s1_ir[31:20]};
            wire [31:0] s_type_imm = {{20{s1_ir[31]}}, s1_ir[31:25], s1_ir[11:7]};
            wire [31:0] b_type_imm = {{20{s1_ir[31]}}, s1_ir[7], s1_ir[30:25], s1_ir[11:8], 1'b0};
            wire [31:0] u_type_imm = {s1_ir[31:12], 12'd0};
            wire [31:0] j_type_imm = {{11{s1_ir[31]}}, s1_ir[31], s1_ir[19:12], s1_ir[20], s1_ir[30:21], 1'b0};
            wire [6:0]  funct7 = s1_ir[31:25];
            wire [2:0]  funct3 = s1_ir[14:12];
            wire [4:0]  rs2 = s1_ir[24:20];
            wire [4:0]  rs1 = s1_ir[19:15];
            wire [4:0]  rd = s1_ir[11:7];
            wire [31:0] shamt = {27'd0, rs2};
            wire [6:0]  opcode = s1_ir[6:0];

            wire [`XLEN-1:0] rs1_val, rs2_val;
            wire [`XLEN-1:0] imm_val;

            assign rs1_val =
                (regfile_wreq && rs1[3:0]==regfile_windex) ?
                    regfile_wdata :
                /* otherwise */
                    x[rs1[3:0]];

            assign rs2_val =
                (regfile_wreq && rs2[3:0]==regfile_windex) ?
                    regfile_wdata :
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
                /* otherwise */
                    shamt;

            // signals for wider use
            assign s1_rd =
                trap ?
                    4'd0 /* trap seen as an instruction where rd=0 */ :
                (opcode==OPCODE_BRANCH || opcode==OPCODE_STORE || opcode==OPCODE_FENCE) /* rd not available */ ?
                    4'd0 /* available yet should not be used for FENCE.I/FENCE */ :
                /* rd available */
                    rd[3:0];

            assign s1_alu_a =
                trap ?
                    32'h00000084 /* TODO: this should be value of mtvec */ :
                (opcode==OPCODE_LUI) ?
                    {`XLEN{0}} :
                (opcode==OPCODE_AUIPC || opcode==OPCODE_JAL || opcode==OPCODE_BRANCH || opcode==OPCODE_FENCE) ?
                    s1_pc /* do-not-care for FENCE. used for FENCE.I */ :
                /* otherwise */
                    rs1_val;

            assign s1_alu_b =
                trap ?
                    {`XLEN{0}} :
                (opcode==OPCODE_CAL) ?
                    rs2_val :
                /* otherwise */
                    imm_val;

            assign s1_alu_op =
                trap ?
                    ALU_OR /* upon trap, alu calc (mtvec | 0) as jmp dst */ :
                (opcode==OPCODE_CAL || opcode==OPCODE_IMMCAL) ?
                (
                    funct3==3'd1 ?
                        ALU_SL :
                    funct3==3'd2 ?
                        ALU_LT :
                    funct3==3'd3 ?
                        ALU_LTU :
                    funct3==3'd4 ?
                        ALU_XOR :
                    funct3==3'd5 ?
                    (
                        funct7[5]==1'b0 ?
                            ALU_SRL :
                        /* 1'b1 */
                            ALU_SRA
                    ) :
                    funct3==3'd6 ?
                        ALU_OR :
                    funct3==3'd7 ?
                        ALU_AND :
                    /* 3'd0 */
                    (
                        (opcode==OPCODE_CAL && funct7[5]) ?
                            ALU_SUB :
                        /* else */
                            ALU_ADD
                    )
                ) :
                /* otherwise (even if unimplemented) */
                    ALU_ADD;

            assign s1_op =
                trap ?
                    OP_TRAP /* trap jump operation, not a real instruction */ :
                (opcode==OPCODE_LOAD) ?
                (
                    (funct3==3'd4 || funct3==3'd5) ?
                        OP_LDU :
                    /*otherwise*/
                        OP_LD
                ) :
                (opcode==OPCODE_STORE) ?
                    OP_SD :
                (opcode==OPCODE_JAL || (opcode==OPCODE_FENCE && funct3[0] /* FENCE.I */ )) ?
                    OP_JAL :
                (opcode==OPCODE_JALR) ?
                    OP_JALR :
                /* otherwise */
                    OP_STD;

            assign s1_j_req =
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
                trap /* always jump if trap detected */
            );

            assign s1_j_lr =
                ((opcode==OPCODE_JALR) || (opcode==OPCODE_JAL)) ?
                    (s1_pc + (s1_c ? 2 : 4)) :
                /* trap, or no jump at all */
                    s1_pc;

            assign s1_d_req = opcode==OPCODE_LOAD || opcode==OPCODE_STORE;
            assign s1_d_req_acc = (funct3[1:0]==2'd0 ? `BUS_ACC_1B : funct3[1:0]==2'd1 ? `BUS_ACC_2B : `BUS_ACC_4B);
            assign s1_d_req_w_rb = (opcode==OPCODE_STORE);
            assign s1_d_req_wdata = rs2_val;

            assign undef_instr = /* not triggerd upon trap */
                (~trap & s1_vld) && (
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
                    /* undefined / unimplemented opcode */
                        1'b1
                );
        end // DECODE

        dff #(
            .RESET("sync"),
            .VALID("sync"),
            .CLEAR("sync")
        ) d_req_dff (
            .clk (clk              ),
            .rstn(rstn             ),
            .clr (d_req_launched   ),
            .vld (s1_vld & s1_d_req),
            .in  (s1_d_req         ),
            .out (d_req            )
        );

        dff #(
            .WIDTH($clog2(`BUS_ACC_CNT)+1+`BUS_WIDTH),
            .VALID("sync")
        ) d_req_info_dff (
            .clk(clk),
            .vld(s1_vld),
            .in ({s1_d_req_acc,s1_d_req_w_rb,s1_d_req_wdata}),
            .out({d_req_acc,   d_req_w_rb,   d_req_wdata   })
        );
    end // STAGE1

    /**********************************************************************************************************************/
    begin:STAGE2 // executing, mem access & write back
        dff #(
            .WIDTH(4+`XLEN+`XLEN+8+8+`XLEN),
            .VALID("sync")
        ) s2_op_dff (
            .clk(clk),
            .vld(s1_vld),
            .in ({s1_rd,s1_alu_a,s1_alu_b,s1_alu_op,s1_op,s1_j_lr}),
            .out({s2_rd,s2_alu_a,s2_alu_b,s2_alu_op,s2_op,s2_j_lr})
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

        assign jmp_addr = {alu_r[`XLEN-1:1], ((s2_op==OP_JALR) ? 1'b0 : alu_r[0])}; // jmp_addr[0] clamped 1'b0 upon JALR
        assign d_req_addr = alu_r;

        // Regfile W access
        assign regfile_wreq = s2_vld && regfile_windex;
        assign regfile_windex = s2_rd;
        assign regfile_wdata =
            (s2_op==OP_LD) ? (
                (d_resp_acc==`BUS_ACC_1B) ?
                    {{24{d_resp_data[7]}}, d_resp_data[7:0]} :
                (d_resp_acc==`BUS_ACC_2B) ?
                    {{16{d_resp_data[15]}}, d_resp_data[15:0]} :
                /*otherwise*/
                    d_resp_data
            ) :
            (s2_op==OP_LDU) ? (
                (d_resp_acc==`BUS_ACC_1B) ?
                    {24'd0, d_resp_data[7:0]} :
                /*d_resp_acc==`BUS_ACC_2B*/
                    {16'd0, d_resp_data[15:0]}
            ) :
            ((s2_op==OP_JAL) || (s2_op==OP_JALR)) ? (
                s2_j_lr
            ) :
            /* otherwise treated as OP_STD */
                alu_r;

        // CSR write operation upon trap
        // write mepc if s2_op==OP_TRAP

        // Fault signal
        assign overshift = s2_vld && (s2_alu_op==ALU_SL || s2_alu_op==ALU_SRL || s2_alu_op==ALU_SRA) && s2_alu_b[`XLEN-1:5];
    end // STAGE2

    /**********************************************************************************************************************/
    always @(posedge clk) begin
        if (~rstn) begin
            core_fault <= 0;
        end else if (undef_instr) begin
            core_fault <= 1;
            core_fault_pc <= s1_pc;
            $display("FAULT: undefined instruction");
        end else if (overshift) begin
            core_fault <= 1;
            core_fault_pc <= s2_pc;
            $display("FAULT: over shift");
        end
    end
endmodule

/**********************************************************************************************************************/
module alu(
    input wire [7:0]       op,
    input wire [`XLEN-1:0]  a,
    input wire [`XLEN-1:0]  b,
    output wire [`XLEN-1:0] r
);
    wire [`XLEN-1:0] sra_r = $signed(a)>>>b,
                     lt_r  = $signed(a)<$signed(b);

    `include "core.vh"

    assign r =
        op==ALU_ADD ? (a+b)   :
        op==ALU_SUB ? (a-b)   :
        op==ALU_AND ? (a&b)   :
        op==ALU_OR  ? (a|b)   :
        op==ALU_XOR ? (a^b)   :
        op==ALU_LTU ? (a<b)   :
        op==ALU_LT  ? (lt_r) :
        op==ALU_SRL ? (a>>b)  :
        op==ALU_SRA ? (sra_r) :
        op==ALU_SL  ? (a<<b)  :
        0;
endmodule

/**********************************************************************************************************************/
module regfile(
    input wire              clk,

    input wire              wreq,
    input wire [3:0]        windex,
    input wire [`XLEN-1:0]  wdata,

    output wire [`XLEN-1:0] x0,
    output wire [`XLEN-1:0] x1,
    output wire [`XLEN-1:0] x2,
    output wire [`XLEN-1:0] x3,
    output wire [`XLEN-1:0] x4,
    output wire [`XLEN-1:0] x5,
    output wire [`XLEN-1:0] x6,
    output wire [`XLEN-1:0] x7,
    output wire [`XLEN-1:0] x8,
    output wire [`XLEN-1:0] x9,
    output wire [`XLEN-1:0] x10,
    output wire [`XLEN-1:0] x11,
    output wire [`XLEN-1:0] x12,
    output wire [`XLEN-1:0] x13,
    output wire [`XLEN-1:0] x14,
    output wire [`XLEN-1:0] x15
);

    reg [`XLEN-1:0] xreg[1:15];
    assign x0  = 0;
    assign x1  = xreg[1 ];
    assign x2  = xreg[2 ];
    assign x3  = xreg[3 ];
    assign x4  = xreg[4 ];
    assign x5  = xreg[5 ];
    assign x6  = xreg[6 ];
    assign x7  = xreg[7 ];
    assign x8  = xreg[8 ];
    assign x9  = xreg[9 ];
    assign x10 = xreg[10];
    assign x11 = xreg[11];
    assign x12 = xreg[12];
    assign x13 = xreg[13];
    assign x14 = xreg[14];
    assign x15 = xreg[15];

    always @ (posedge clk) begin
        if (wreq && windex) begin
            xreg[windex] <= wdata;
        end
    end
endmodule

/**********************************************************************************************************************/
module prefetch_queue (
    input wire          clk,
    input wire          rstn,

    input wire          in_req,
    input wire          in_req_16_32bar,
    input wire[31:0]    in,

    input wire          out_req,
    input wire          out_req_16_32bar,
    output wire[31:0]   out,

    input wire          clr,

    output wire[1:0]    vacant_entry16,
    output wire[1:0]    filled_entry16
);
    generate
        for(genvar i=0;i<2;i=i+1) begin:pingpong
            wire w, r;
            wire full, empty;
            wire almost_full, almost_empty;
            wire [15:0] din, dout;
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

    // note: both fifos are 2 entries in depth, and we'are not expecting 2-0 situation
    // note: actual capacity of the queue is 4 entries, but we would reserve 2
    assign vacant_entry16 =
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

    assign filled_entry16 =
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

    assign pingpong[0].w = in_req & (~in_req_16_32bar | ~wsel);
    assign pingpong[1].w = in_req & (~in_req_16_32bar | wsel);

    assign pingpong[0].r = out_req & (~out_req_16_32bar | ~rsel);
    assign pingpong[1].r = out_req & (~out_req_16_32bar | rsel);

    assign pingpong[0].din = wsel ? in[31:16] : in[15:0];
    assign pingpong[1].din = wsel ? in[15:0] : in[31:16];

    assign out[15:0] = rsel ? pingpong[1].dout : pingpong[0].dout;
    assign out[31:16] = rsel ? pingpong[0].dout : pingpong[1].dout;

    always @ (posedge clk) begin
        if (~rstn | clr) begin
            wsel <= 1'b0;
            rsel <= 1'b0;
        end else begin
            if (~(pingpong[0].full & pingpong[1].full) & in_req & in_req_16_32bar) begin
                wsel <= ~wsel;
            end
            if (~(pingpong[0].empty & pingpong[1].empty) & out_req & out_req_16_32bar) begin
                rsel <= ~rsel;
            end
        end
    end
endmodule

module expander( // conpressed instruction expansion
    input wire[`ILEN-1:0]   in_instr,
    output wire[`ILEN-1:0]  out_instr,
    output wire             out_c
);

`include "core.vh"

    assign out_c = in_instr[1:0]!=OPCODE_NC;
    // 16-32bit expansion
    wire[1:0] opcode = in_instr[1:0];
    wire[2:0] funct3 = in_instr[15:13];
    wire[4:0] rd_rs1 = in_instr[11:7];
    wire[4:0] rs2 = in_instr[6:2];
    wire[2:0] rd_q_rs1_q = in_instr[9:7];
    wire[2:0] rd_q_rs2_q = in_instr[4:2];

    wire undef_instr_c = out_c &&
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

    assign out_instr =
        undef_instr_c ? {`ILEN{1'b0}} : (
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
            ) :
            /* OPCODE_NC */
                in_instr
        );
endmodule

module pipeline( // SR
    input wire  clk,
    input wire  rstn,

    input wire  clr,
    input wire  hld,

    input wire[`ILEN-1:0]   in_ir,
    input wire[`XLEN-1:0]   in_pc,
    input wire              in_c,
    input wire              in_vld,

    output wire[`ILEN-1:0]  s1_ir,
    output wire[`XLEN-1:0]  s1_pc,
    output wire             s1_c,
    output wire             s1_vld,

    output wire[`ILEN-1:0]  s2_ir,
    output wire[`XLEN-1:0]  s2_pc,
    output wire             s2_c,
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
            s1 <= {in_ir,in_pc,in_c,in_vld};
            s2 <= s1;
        end
    end

    assign {s1_ir,s1_pc,s1_c} = s1[`ILEN+`XLEN+2-1:1];
    assign {s2_ir,s2_pc,s2_c} = s2[`ILEN+`XLEN+2-1:1];
    assign s1_vld = s1[0] & ~hld;
    assign s2_vld = s2[0] & ~hld;
endmodule
