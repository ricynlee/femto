// ex/wb stage opcode
localparam  OP_UNDEF = 8'd0,
            OP_STD   = 8'd1, // Write regfile only
            OP_JAL   = 8'd2,
            OP_JALR  = 8'd3,
            OP_LD    = 8'd4, // load
            OP_LDU   = 8'd5, // load unsigned
            OP_SD    = 8'd6, // store

            OP_TRAP  = 8'd7; // trap jump, not a real instruction

// ex/wb alu opcode
localparam  ALU_ADD  = 8'h1,
            ALU_SUB  = 8'h2,
            ALU_AND  = 8'h3,
            ALU_OR   = 8'h4,
            ALU_XOR  = 8'h5,
            ALU_LT   = 8'h6,
            ALU_LTU  = 8'h7,
            ALU_SRL  = 8'h8,
            ALU_SRA  = 8'h9,
            ALU_SL   = 8'ha,
            ALU_NOP  = 8'h0;

// id opcode
localparam  OPCODE_C0 = 2'b00,
            OPCODE_C1 = 2'b01,
            OPCODE_C2 = 2'b10,
            OPCODE_NC = 2'b11; // non-compressed

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
            OPCODE_SYSTEM = 7'b1110011;

