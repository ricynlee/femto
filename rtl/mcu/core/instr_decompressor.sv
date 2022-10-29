module instr_decompressor( // conpressed instruction expansion
    input wire[31:0] in_instr,
    output reg[31:0] out_instr,  // decompressed instruction
    output wire      instr_compressed // compressed instruction flag (whether in_instr is compressed)
);
// instruction with OPCODE_NC are fed through instr_decompressor
`include "core.vh"

    assign instr_compressed = in_instr[1:0]!=OPCODE_NC;
    // 16-32bit expansion
    wire[1:0] opcode = in_instr[1:0];
    wire[2:0] funct3 = in_instr[15:13];
    wire[4:0] rd_rs1 = in_instr[11:7]; /// rd or rs1
    wire[4:0] rs2 = in_instr[6:2];
    wire[2:0] rd_a_rs1_a = in_instr[9:7]; // rd' or rs1', apostrophe
    wire[2:0] rd_a_rs2_a = in_instr[4:2]; // rd' or rs2', apostrophe

    always @ (*) case (opcode)
        OPCODE_C0: case (funct3)
            3'b000: // supports nzuimm==0 (functions as nop)
                out_instr = {{2'd0,in_instr[10:7],in_instr[12:11],in_instr[5],in_instr[6],2'd0},5'd2/*x2*/,3'b000,{2'b01,rd_a_rs2_a},OPCODE_IMMCAL}; //c.addi4spn
            3'b010:
                out_instr = {{5'd0,in_instr[5],in_instr[12:10],in_instr[6],2'd0},{2'b01,rd_a_rs1_a},3'b010,{2'b01,rd_a_rs2_a},OPCODE_LOAD}; //c.lw
            3'b110:
                out_instr = {{5'd0,in_instr[5],in_instr[12]},{2'b01,rd_a_rs2_a},{2'b01,rd_a_rs1_a},3'b010,{in_instr[11:10],in_instr[6],2'd0},OPCODE_STORE}; //c.sw
            default:
                out_instr = ILLEGAL_INSTR;
        endcase
        OPCODE_C1: case (funct3)
            3'b000: // supports nzimm==0, rs1/rd==0 (functions as nop)
                out_instr = {{{7{in_instr[12]}},in_instr[6:2]},rd_rs1,3'b000,rd_rs1,OPCODE_IMMCAL}; //c.addi
            3'b001:
                out_instr = {{in_instr[12],in_instr[8],in_instr[10:9],in_instr[6],in_instr[7],in_instr[2],in_instr[11],in_instr[5:3],{9{in_instr[12]}}},5'd1/*x1*/,OPCODE_JAL}; //c.jal
            3'b010: // supports rd==0 (functions as nop)
                out_instr = {{{7{in_instr[12]}},in_instr[6:2]},5'd0/*x0*/,3'b000,rd_rs1,OPCODE_IMMCAL}; //c.li
            3'b011:
                if (rd_rs1==5'd2) // supports nzimm==0 (functions as nop)
                    out_instr = {{{3{in_instr[12]}},in_instr[4:3],in_instr[5],in_instr[2],in_instr[6],4'd0},5'd2/*x2*/,3'b000,5'd2/*x2*/,OPCODE_IMMCAL}; //c.addi16sp
                else // supports nzimm==0 (functions as nop)
                    out_instr = {{{15{in_instr[12]}},in_instr[6:2]},rd_rs1,OPCODE_LUI}; //c.lui
            3'b100: case (in_instr[11:10])
                2'b00: // supports nzuimm===0 (functions as nop), ignores nzuimm[5]
                    out_instr = {7'b0000000,in_instr[6:2],{2'b01,rd_a_rs1_a},3'b101,{2'b01,rd_a_rs1_a},OPCODE_IMMCAL}; //c.srli
                2'b01: // supports nzuimm===0 (functions as nop), ignores nzuimm[5]
                    out_instr = {7'b0100000,in_instr[6:2],{2'b01,rd_a_rs1_a},3'b101,{2'b01,rd_a_rs1_a},OPCODE_IMMCAL}; //c.srai
                2'b10:
                    out_instr = {{{7{in_instr[12]}},in_instr[6:2]},{2'b01,rd_a_rs1_a},3'b111,{2'b01,rd_a_rs1_a},OPCODE_IMMCAL}; //c.andi
                default/* 2'b11 */: case ({in_instr[12], in_instr[6:5]})
                    3'b000:
                        out_instr = {7'b0100000,{2'b01,rd_a_rs2_a},{2'b01,rd_a_rs1_a},3'b000,{2'b01,rd_a_rs1_a},OPCODE_CAL}; //c.sub
                    3'b001:
                        out_instr = {7'b0000000,{2'b01,rd_a_rs2_a},{2'b01,rd_a_rs1_a},3'b100,{2'b01,rd_a_rs1_a},OPCODE_CAL}; //c.xor
                    3'b010:
                        out_instr = {7'b0000000,{2'b01,rd_a_rs2_a},{2'b01,rd_a_rs1_a},3'b110,{2'b01,rd_a_rs1_a},OPCODE_CAL}; //c.or
                    3'b011:
                        out_instr = {7'b0000000,{2'b01,rd_a_rs2_a},{2'b01,rd_a_rs1_a},3'b111,{2'b01,rd_a_rs1_a},OPCODE_CAL}; //c.and
                    default:
                        out_instr = ILLEGAL_INSTR;
                endcase
            3'b101:
                out_instr = {{in_instr[12],in_instr[8],in_instr[10:9],in_instr[6],in_instr[7],in_instr[2],in_instr[11],in_instr[5:3],{9{in_instr[12]}}},5'd0/*x0*/,OPCODE_JAL}; //c.j
            3'b110:
                out_instr = {{{4{in_instr[12]}},in_instr[6:5],in_instr[2]},5'd0/*x0*/,{2'b01,rd_a_rs1_a},3'b000,{in_instr[11:10],in_instr[4:3],in_instr[12]},OPCODE_BRANCH}; //c.beqz
            default/* 3'b111 */:
                out_instr = {{{4{in_instr[12]}},in_instr[6:5],in_instr[2]},5'd0/*x0*/,{2'b01,rd_a_rs1_a},3'b001,{in_instr[11:10],in_instr[4:3],in_instr[12]},OPCODE_BRANCH}; //c.bnez
        endcase
        OPCODE_C2: case (funct3)
            3'b000: // supports rs1/rd==0, nzimm==0 (functions as nop)
                out_instr = {7'b0000000,in_instr[6:2],rd_rs1,3'b001,rd_rs1,OPCODE_IMMCAL}; //c.slli
            3'b010: // supports rd==0 (functions as nop)
                out_instr = {{4'd0,in_instr[3:2],in_instr[12],in_instr[6:4],2'd0},5'd2/*x2*/,3'b010,rd_rs1,OPCODE_LOAD}; //c.lwsp
            3'b100: case (in_instr[12])
                1'b0:
                    if (rs2==5'd0) // allows rs1==0 (jalr x0, 0+x0)
                        out_instr = {12'd0,rd_rs1,3'b000,5'd0/*x0*/,OPCODE_JALR}; //c.jr
                    else // supports rd==0 (functions as nop)
                        out_instr = {7'b0000000,rs2,5'd0/*x0*/,3'b000,rd_rs1,OPCODE_CAL}; //c.mv
                default/* 1'b1 */:
                    if (rd_rs1==5'd0 && rs2==5'd0)
                        out_instr = 32'b000000000001_00000_000_00000_1110011; // c.ebreak
                    else if (/* rd_rs1!=5'd0 && */ rs2==5'd0)
                        out_instr = {12'd0,rd_rs1,3'b000,5'd1/*x1*/,OPCODE_JALR}; //c.jalr
                    else /* if (rs2!=5'd0) */ // supports rd==0 (functions as nop)
                        out_instr = {7'b0000000,rs2,rd_rs1,3'b000,rd_rs1,OPCODE_CAL}; //c.add
            3'b110:
                out_instr = {{4'd0,in_instr[8:7],in_instr[12]},rs2,5'd2/*x2*/,3'b010,{in_instr[11:9],2'd0},OPCODE_STORE}; //c.swsp
            default:
                out_instr = ILLEGAL_INSTR;
        endcase
        default/* OPCODE_NC */:
            out_instr = in_instr;
    endcase
endmodule
