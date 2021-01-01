`include "sim/timescale.vh"
`include "femto.vh"

`define NOP_AS_FENCE_I  // JAL_AS_FENCE_I/NOP_AS_FENCE_I
/* FENCE.I */
/* for current 2-stage pipelined non-cached core, NOP (ADDI x0, ?, ?) works */
/* for a deeper pipeline, JAL (JAL x0, pc+4) can be a must */
/* FENCE */
/* NOP (ADDI x0, ?, ?) always works for a single-hart design */

// Actually 2-stage pipelined core
module core (
    input wire  clk,
    input wire  rstn,

    // fault
    output reg              core_fault,
    output reg [`XLEN-1:0]  core_fault_pc,

    // bus interface
    output wire [`XLEN-1:0]                 bus_addr, // byte addr
    output wire                             bus_wr_b,
    output wire [$clog2(`BUS_ACC_CNT)-1:0]  bus_acc,
    input wire [`BUS_WIDTH-1:0]             bus_rdata,
    output wire [`BUS_WIDTH-1:0]            bus_wdata,
    output wire                             bus_req,
    input wire                              bus_resp
);

    /**********************************************************************************************************************/
    // BEGIN {IF & MEM} // mem timing mode supported: data comes no later than next req

    // Feedback signals
    reg [$clog2(`BUS_R_CNT)-1:0] bus_req_type;
    wire [`XLEN-1:0] dreq_addr;
    reg [`BUS_WIDTH-1:0] dreq_wdata;
    reg [$clog2(`BUS_ACC_CNT)-1:0] dreq_acc;
    reg dreq_wr_b;
    reg jump;

    // Mem access req mux
    wire [`XLEN-1:0] pc_IF;
    bus_req_mux bus_req_mux(
        .bus_req_type(bus_req_type),
        .ireq_addr   (pc_IF       ),
        .dreq_addr   (dreq_addr   ),
        .dreq_acc    (dreq_acc    ),
        .dreq_wr_b   (dreq_wr_b   ),
        .bus_addr    (bus_addr    ),
        .bus_acc     (bus_acc     ),
        .bus_wr_b    (bus_wr_b    )
    );
    assign bus_wdata = dreq_wdata;

    wire [$clog2(`BUS_R_CNT)-1:0] bus_resp_type;
    wire [`XLEN-1:0] bus_resp_addr; // bus_resp corresponding addr, typ. pc of fetched instruction

    dff #(
        .WIDTH($clog2(`BUS_R_CNT)+`XLEN),
        .VALID("sync"                  ),
        .RESET("none"                  ),
        .CLEAR("none"                  )
    ) bus_rr_dff (
        .clk(clk                          ),
        .vld(bus_req                      ),
        .in ({bus_req_type,bus_addr}      ),
        .out({bus_resp_type,bus_resp_addr})
    );

    // PC mux
    wire [$clog2(`PC_MUX_CNT)-1:0] pc_sel = jump ? `PC_JMP : `PC_INC;
    wire [`XLEN-1:0] pc_jump_addr;
    wire ireq_launched = bus_req && bus_req_type==`BUS_R_I; // IF req vld
    pc_IF_mux pc_IF_mux(
        .clk         (clk          ),
        .rstn        (rstn         ),
        .pc_sel      (pc_sel       ),
        .pc_inc_trig (ireq_launched),
        .pc_jump_addr(pc_jump_addr ),
        .pc_out      (pc_IF        )
    );
    wire iresp_latched = bus_resp_type==`BUS_R_I && bus_resp;
    wire dreq_launched = bus_req && bus_req_type==`BUS_R_D;
    wire dresp_latched = bus_resp_type==`BUS_R_D && bus_resp;

    wire held_for_jump, held_for_dreq;
    keeper #(
        .WIDTH(1)
    ) held_for_jump_keeper (
        .clk (clk                 ),
        .rstn(rstn                ),
        .vld (jump | iresp_latched),
        .in  (jump                ),
        .out (held_for_jump       )
    );

    keeper #(
        .WIDTH(1)
    ) held_for_dreq_keeper (
        .clk (clk                                    ),
        .rstn(rstn                                   ),
        .vld (bus_req_type==`BUS_R_D || dresp_latched),
        .in  (bus_req_type==`BUS_R_D                 ),
        .out (held_for_dreq                          )
    );

    wire pipeline_held = held_for_jump | held_for_dreq;
    wire pipeline_was_held;
    dff #(
        .CLEAR("none")
    ) prev_hold_dff (
        .clk (clk              ),
        .rstn(rstn             ),
        .in  (pipeline_held    ),
        .out (pipeline_was_held)
    );
    wire pipeline_released = {pipeline_was_held, pipeline_held}==2'b10;

    // Initial bus req
    reg init_bus_req;
    reg init_bus_req_sent;
    always @ (posedge clk) begin
        if (rstn==0) begin
            init_bus_req <= 0;
            init_bus_req_sent <= 0;
        end else if (init_bus_req_sent==0) begin
            init_bus_req <= 1;
            init_bus_req_sent <= 1;
        end else begin
            init_bus_req <= 0;
        end
    end
    assign bus_req = init_bus_req | bus_resp;

    // END {IF & MEM}
    /**********************************************************************************************************************/
    wire IF2ID_vld = (iresp_latched & ~pipeline_held) | pipeline_released;

    wire [`ILEN-1:0] ir_ID;
    keeper #(
        .WIDTH      (`ILEN     ),
        .INITIALIZER(`NOP_INSTR) // this initializer can be ignored
    ) ir_IF2ID_keeper (
        .clk (clk          ),
        .rstn(rstn         ),
        .vld (iresp_latched),
        .in  (bus_rdata    ),
        .out (ir_ID        )
    );

    wire [`XLEN-1:0] pc_ID;
    keeper #(
        .WIDTH      (`XLEN    ),
        .INITIALIZER(`RESET_PC) // this initializer can be ignored
    ) pc_IF2ID_keeper (
        .clk (clk          ),
        .rstn(rstn         ),
        .vld (iresp_latched),
        .in  (bus_resp_addr),
        .out (pc_ID        )
    );
    /**********************************************************************************************************************/
    // BEGIN {ID}
    localparam  OPCODE_IMMCAL = 7'b0010011,
                OPCODE_LUI    = 7'b0110111,
                OPCODE_AUIPC  = 7'b0010111,
                OPCODE_CAL    = 7'b0110011,
                OPCODE_JAL    = 7'b1101111,
                OPCODE_JALR   = 7'b1100111,
                OPCODE_BRANCH = 7'b1100011,
                OPCODE_LOAD   = 7'b0000011,
                OPCODE_STORE  = 7'b0100011,
                OPCODE_FENCE  = 7'b0001111,
                //
                OPCODE_SYSTEM = 7'b1110011;

    wire [31:0] i_type_imm = {{20{ir_ID[31]}}, ir_ID[31:20]};
    wire [31:0] s_type_imm = {{20{ir_ID[31]}}, ir_ID[31:25], ir_ID[11:7]};
    wire [31:0] b_type_imm = {{20{ir_ID[31]}}, ir_ID[7], ir_ID[30:25], ir_ID[11:8], 1'b0};
    wire [31:0] u_type_imm = {ir_ID[31:12], 12'd0};
    wire [31:0] j_type_imm = {{11{ir_ID[31]}}, ir_ID[31], ir_ID[19:12], ir_ID[20], ir_ID[30:21], 1'b0};
    wire [6:0]  funct7 = ir_ID[31:25];
    wire [2:0]  funct3 = ir_ID[14:12];
    wire [4:0]  rs2   = ir_ID[24:20];
    wire [4:0]  rs1   = ir_ID[19:15];
    wire [4:0]  rd    = ir_ID[11:7];
    wire [31:0] shamt = {27'd0, rs2};
    wire [6:0]  opcode = ir_ID[6:0];

    // Reg file (read-only)
    wire [`XLEN-1:0] x[0:15];
    wire regfile_wreq;
    wire [3:0] regfile_windex;
    wire [`XLEN-1:0] regfile_wdata;
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

    // Decode
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
        (opcode==OPCODE_LUI || opcode==OPCODE_AUIPC) ? 
            u_type_imm :
        (opcode==OPCODE_JAL) ? 
            j_type_imm :
        (opcode==OPCODE_JALR || opcode==OPCODE_LOAD || (opcode==OPCODE_IMMCAL && funct3^3'b001 && funct3^3'b101) || opcode==OPCODE_FENCE) ? 
            i_type_imm /* available (yet do-not-care) for FENCE.I, do-not-care (and unavailable) for FENCE */:
        (opcode==OPCODE_BRANCH) ?
            b_type_imm :
        (opcode==OPCODE_STORE) ?
            s_type_imm :
        /* otherwise */
            shamt;
    wire [3:0] rd_ID =
        (opcode==OPCODE_BRANCH || opcode==OPCODE_STORE || opcode==OPCODE_FENCE) /* rd not available */ ?
            4'd0 /* available yet should not be used for FENCE.I/FENCE */ :
        /* rd available */
            rd[3:0];
    wire [`XLEN-1:0] alu_a_ID =
        (opcode==OPCODE_LUI) ?
            x[0] :
        (opcode==OPCODE_AUIPC || opcode==OPCODE_JAL || opcode==OPCODE_BRANCH || opcode==OPCODE_FENCE) ?
            pc_ID /* do-not-care for FENCE. used for FENCE.I if JAL-as-FENCE.I, otherwise do-not-care */ :
        /* otherwise */
            rs1_val;
    wire [`XLEN-1:0] alu_b_ID =
        (opcode==OPCODE_CAL) ?
            rs2_val :
        (opcode==OPCODE_FENCE) ?
            4 /* do-not-care for FENCE. used for FENCE.I if JAL-as-FENCE.I, otherwise do-not-care */ :
        /* otherwise */
            imm_val;
    wire [7:0] alu_op_ID =
        (opcode==OPCODE_CAL || opcode==OPCODE_IMMCAL) ?
        (
            funct3==3'd1 ?
                `ALU_SL :
            funct3==3'd2 ?
                `ALU_LT :
            funct3==3'd3 ?
                `ALU_LTU :
            funct3==3'd4 ?
                `ALU_XOR :
            funct3==3'd5 ?
            (
                funct7[5]==1'b0 ?
                    `ALU_SRL :
                /* 1'b1 */
                    `ALU_SRA
            ) :
            funct3==3'd6 ?
                `ALU_OR :
            funct3==3'd7 ?
                `ALU_AND :
            /* 3'd0 */
            (
                (opcode==OPCODE_CAL && funct7[5]) ?
                    `ALU_SUB :
                /* else */
                    `ALU_ADD
            )
        ) :
        /* otherwise (even if unimplemented) */
            `ALU_ADD;

    wire branch_vld =
        opcode==OPCODE_BRANCH &&
        (
            funct3[2:1]==2'd2 ?
                (funct3[0]^($signed(rs1_val)<$signed(rs2_val))/* ({~rs1_val[`XLEN-1], rs1_val[`XLEN-2:0]}<{~rs2_val[`XLEN-1], rs2_val[`XLEN-2:0]}) */) :
            funct3[2:1]==2'd3 ?
                (funct3[0]^(rs1_val<rs2_val)) :
            /* 2'd0 or undefined */
                (funct3[0]^(rs1_val==rs2_val))
        );
    
    wire [7:0] op_ID =
        (opcode==OPCODE_LOAD) ?
            (
                funct3==3'd0 ?
                    `OP_LB :
                funct3==3'd1 ?
                    `OP_LH :
                funct3==3'd4 ?
                    `OP_LBU :
                funct3==3'd5 ?
                    `OP_LHU :
                /* seen as LW */
                    `OP_LW
            ) :
`ifdef JAL_AS_FENCE_I
        (opcode==OPCODE_JAL || (opcode==OPCODE_FENCE && funct3[0] /* FENCE.I */ )) ?
`else
        (opcode==OPCODE_JAL) ?
`endif
            `OP_JAL :
        (opcode==OPCODE_JALR) ?
            `OP_JALR :
        /* otherwise */
            `OP_STD;

    // Initiate data/jump req
    always @ (posedge clk) begin
        if (rstn==0) begin
            jump <= 0;
            bus_req_type <= `BUS_R_I;
        end else begin
            if (IF2ID_vld) begin
`ifdef JAL_AS_FENCE_I
                jump <= (opcode==OPCODE_JALR || opcode==OPCODE_JAL || branch_vld || (opcode==OPCODE_FENCE && funct3[0] /* FENCE.I */ ));
`else
                jump <= (opcode==OPCODE_JALR || opcode==OPCODE_JAL || branch_vld);
`endif
                bus_req_type <= (opcode==OPCODE_LOAD || opcode==OPCODE_STORE) ? `BUS_R_D : `BUS_R_I;
                dreq_acc <= funct3[1:0]==2'd0 ? `BUS_ACC_1B : funct3[1:0]==2'd1 ? `BUS_ACC_2B : `BUS_ACC_4B;
                dreq_wr_b <= (opcode==OPCODE_STORE);
                dreq_wdata <= rs2_val;
            end else if (ireq_launched) begin
                jump <= 0;
            end else if (dreq_launched) begin
                bus_req_type <= `BUS_R_I;
            end
        end
    end

    // Fault
    wire undef_instr =
        IF2ID_vld && (
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

    // END {ID}
    /**********************************************************************************************************************/
    wire [`XLEN-1:0] pc_EX;
    dff #(
        .WIDTH(`XLEN ),
        .RESET("none"),
        .CLEAR("none"),
        .VALID("sync")
    ) pc_ID2EX_dff (
        .clk(clk      ),
        .vld(IF2ID_vld),
        .in (pc_ID    ),
        .out(pc_EX    )
    );

    wire [`XLEN-1:0] ir_EX;
    dff #(
        .WIDTH(`XLEN ),
        .RESET("none"),
        .CLEAR("none"),
        .VALID("sync")
    ) ir_ID2EX_dff (
        .clk(clk      ),
        .vld(IF2ID_vld),
        .in (ir_ID    ),
        .out(ir_EX    )
    );

    wire [3:0] rd_EX;
    dff #(
        .WIDTH(4),
        .RESET("none"),
        .CLEAR("none"),
        .VALID("sync")
    ) rd_ID2EX_dff (
        .clk(clk      ),
        .vld(IF2ID_vld),
        .in (rd_ID    ),
        .out(rd_EX    )
    );

    wire [7:0] alu_op_EX;
    dff #(
        .WIDTH(8),
        .RESET("none"),
        .CLEAR("none"),
        .VALID("sync")
    ) alu_op_ID2EX_dff (
        .clk(clk      ),
        .vld(IF2ID_vld),
        .in (alu_op_ID),
        .out(alu_op_EX)
    );

    wire [`XLEN-1:0] alu_a_EX;
    dff #(
        .WIDTH(`XLEN),
        .RESET("none"),
        .CLEAR("none"),
        .VALID("sync")
    ) alu_a_ID2EX_dff (
        .clk(clk      ),
        .vld(IF2ID_vld),
        .in (alu_a_ID ),
        .out(alu_a_EX )
    );

    wire [`XLEN-1:0] alu_b_EX;
    dff #(
        .WIDTH(`XLEN),
        .RESET("none"),
        .CLEAR("none"),
        .VALID("sync")
    ) alu_b_ID2EX_dff (
        .clk(clk      ),
        .vld(IF2ID_vld),
        .in (alu_b_ID ),
        .out(alu_b_EX )
    );

    wire [7:0] op_EX;
    dff #(
        .WIDTH      (8        ),
        .INITIALIZER(`OP_UNDEF),
        .CLEAR      ("none"   ),
        .VALID      ("sync"   )
    ) op_ID2EX_dff (
        .clk (clk      ),
        .rstn(rstn     ),
        .vld (IF2ID_vld),
        .in  (op_ID    ),
        .out (op_EX    )
    );

    wire ID2EX_vld;
    dff #(
        .CLEAR("none")
    ) ID2EX_vld_dff (
        .clk (clk      ),
        .rstn(rstn     ),
        .in  (IF2ID_vld),
        .out (ID2EX_vld)
    );
    /**********************************************************************************************************************/
    // BEGIN {EX}
    wire calc_ret_pc = (op_EX==`OP_JAL || op_EX==`OP_JALR) && iresp_latched && ~jump;
    wire [`XLEN-1:0] alu_a_pc = pc_EX;
    wire [`XLEN-1:0] alu_b_4  = 4;
    wire [`XLEN-1:0] alu_r;
    alu alu(
        .op(calc_ret_pc ? `ALU_ADD : alu_op_EX),
        .a (calc_ret_pc ? alu_a_pc : alu_a_EX ),
        .b (calc_ret_pc ? alu_b_4  : alu_b_EX ),
        .r (alu_r                             )
    );

    // Fault
    wire overshift = ID2EX_vld && (alu_op_EX==`ALU_SL || alu_op_EX==`ALU_SRL || alu_op_EX==`ALU_SRA) && alu_b_EX[`XLEN-1:5];

    assign pc_jump_addr = op_EX==`OP_JALR ? {alu_r[`XLEN-1:1], 1'b0} : alu_r;
    assign dreq_addr = alu_r;

    assign regfile_wreq = regfile_windex &&
        (
            (op_EX==`OP_JAL || op_EX==`OP_JALR) ?
                (iresp_latched & ~pipeline_held) :
            (op_EX==`OP_LB || op_EX==`OP_LH || op_EX==`OP_LW || op_EX==`OP_LBU || op_EX==`OP_LHU) ?
                (dresp_latched & ~pipeline_held) :
            /* otherwise */
                ID2EX_vld
        );
    assign regfile_windex = rd_EX;
    assign regfile_wdata =
        (op_EX==`OP_LB) ?
            {{24{bus_rdata[7]}}, bus_rdata[7:0]} :
        (op_EX==`OP_LH) ?
            {{16{bus_rdata[15]}}, bus_rdata[15:0]} :
        (op_EX==`OP_LW) ?
            (bus_rdata) :
        (op_EX==`OP_LBU) ?
            {24'd0, bus_rdata[7:0]} :
        (op_EX==`OP_LHU) ?
            {16'd0, bus_rdata[15:0]} :
        /* otherwise `OP_STD */
            alu_r;
    // END {EX}
    /**********************************************************************************************************************/
    always @(posedge clk) begin
        if (rstn==0) begin
            core_fault <= 0;
        end else if (undef_instr) begin
            core_fault <= 1;
            core_fault_pc <= pc_ID;
        end else if (overshift) begin
            core_fault <= 1;
            core_fault_pc <= pc_EX;
        end
    end

endmodule

/****************************************************************/
// submodules
module bus_req_mux(
    input wire [$clog2(`BUS_R_CNT)-1:0] bus_req_type,

    // I req input
    input wire [`XLEN-1:0]  ireq_addr, // pc_IF

    // D req input
    input wire [`XLEN-1:0]                  dreq_addr,
    input wire [$clog2(`BUS_ACC_CNT)-1:0]   dreq_acc,
    input wire                              dreq_wr_b,

    // bus req output
    output wire [`XLEN-1:0]                 bus_addr,
    output wire [$clog2(`BUS_ACC_CNT)-1:0]  bus_acc,
    output wire                             bus_wr_b
);
    assign bus_addr = bus_req_type==`BUS_R_D ? dreq_addr : ireq_addr;
    assign bus_acc = bus_req_type==`BUS_R_D ? dreq_acc : `BUS_ACC_I ;
    assign bus_wr_b = bus_req_type==`BUS_R_I ? 0 : dreq_wr_b;
endmodule

module pc_IF_mux(
    input wire clk,
    input wire rstn,

    input wire [$clog2(`PC_MUX_CNT)-1:0]    pc_sel,

    // required by PC_INC
    input wire pc_inc_trig, // pc increase trigger

    // required by PC_JMP
    input wire [`XLEN-1:0]  pc_jump_addr,

    // output
    output wire [`XLEN-1:0] pc_out
);
    reg [`XLEN-1:0] pc_IF_reg;
    always  @ (posedge clk) begin
        if (rstn==0) begin
            pc_IF_reg <= `RESET_PC;
        end else if (pc_inc_trig) begin
            pc_IF_reg <= pc_out + 4;
        end
    end

    assign pc_out = pc_sel==`PC_INC ? pc_IF_reg : pc_jump_addr;
endmodule

module alu(
    input wire [7:0]       op,
    input wire [`XLEN-1:0]  a,
    input wire [`XLEN-1:0]  b,
    output wire [`XLEN-1:0] r
);
    wire [`XLEN-1:0] sra_r = $signed(a)>>>b,
                     lt_r  = $signed(a)<$signed(b);

    assign r =
        op==`ALU_ADD ? (a+b)   :
        op==`ALU_SUB ? (a-b)   :
        op==`ALU_AND ? (a&b)   :
        op==`ALU_OR  ? (a|b)   :
        op==`ALU_XOR ? (a^b)   :
        op==`ALU_LTU ? (a<b)   :
        op==`ALU_LT  ? (lt_r) :
        op==`ALU_SRL ? (a>>b)  :
        op==`ALU_SRA ? (sra_r) :
        op==`ALU_SL  ? (a<<b)  :
        0;
endmodule

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
