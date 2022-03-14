/***************************************** per riscv std *****************************************/
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

// interrupt mcause exception code
localparam  MCAUSE_MEXTINT = {1'b1, 31'd11};

// csr addr encoding
localparam  CSR_ADDR_MSTATUS = 12'h300,
            CSR_ADDR_MIE     = 12'h304,
            CSR_ADDR_MTVEC   = 12'h305,
            CSR_ADDR_MEPC    = 12'h341,
            CSR_ADDR_MCAUSE  = 12'h342,
            CSR_ADDR_MTVAL   = 12'h343,
            CSR_ADDR_MIP     = 12'h344;

/* trap csr notes

 * mstatus // mie & mpie function, other are WPRI fields
           // mie is hw cleared upon traps, and works only on interrupts
 * mtvec   // trap jmp dst pc
 * mepc    // erroneous instruction addr(s2_pc) for exception
           // unexecuted instruction(s1_pc) addr for interrupt
           // works for both exceptions and interrupts
 * mcause  // distinguishes exceptions/interrupts
 * mtval   // extra info of a trap
 * mie     // interrupt (not trap) enablement control
 * mip     // interrupt (not trap) pending flags

 * Talking about a RISCV MCU (M-mode only core):
 * If software is to handle nested interrupts properly, the compiler needs to protect handler context
 *  - mstatus (MPIE matters)
 *  - mepc
 *  - mcause
 *  - mtval
 *  - mie
 * Only external interrupts are implemented among all kind of traps.
 * Nested exceptions, esp. w/ priority arbitration can be a headache, so exceptions are treated as fatal faults.

 */

// csr field definition
`define MIE  3  // mstatus.MIE - global int enable
`define MPIE 7  // mstatus.MPIE - prev MIE
`define MEIE 11 // mie.MEIE - ext int enable
`define MEIP 11 // mip.MEIP - ext int pending

/***************************************** femto defined *****************************************/
// ex/wb stage opcode
localparam  WB_OP_UNDEF = 8'd0,
            WB_OP_STD   = 8'd1, // Write regfile only
            WB_OP_JAL   = 8'd2,
            WB_OP_JALR  = 8'd3,
            WB_OP_LD    = 8'd4, // load
            WB_OP_LDU   = 8'd5, // load unsigned
            WB_OP_SD    = 8'd6, // store
            WB_OP_CSR   = 8'd7,
            WB_OP_TRAP  = 8'd8; // trap jump

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

// bound with csr_addr to csr_index logic
localparam  CSR_INDEX_MSTATUS = 4'b0_000,
            CSR_INDEX_MIE     = 4'b0_100,
            CSR_INDEX_MTVEC   = 4'b0_101,
            CSR_INDEX_MEPC    = 4'b1_001,
            CSR_INDEX_MCAUSE  = 4'b1_010,
            CSR_INDEX_MTVAL   = 4'b1_011,
            CSR_INDEX_MIP     = 4'b1_100,
            CSR_INDEX_INVLD   = 4'b1_111;
