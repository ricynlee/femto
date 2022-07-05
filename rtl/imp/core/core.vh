/***************************************** per riscv std *****************************************/
// id opcode
localparam OPCODE_C0 = 2'b00,
           OPCODE_C1 = 2'b01,
           OPCODE_C2 = 2'b10,
           OPCODE_NC = 2'b11; // non-compressed

localparam OPCODE_IMMCAL = 7'b0010011,
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

// external interrupt (not for all traps!) mcause exception code
// localparam MCAUSE_MEXTINT = {1'b1, 31'd11};

// trap csr addr encoding
localparam CSR_ADDR_MSTATUS = 12'h300,
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
 *  - mcause (not required for femto as only ext ints are supported)
 *  - mie (not required if not changed in int handler)
 *  - mtval in case of exceptions, etc.
 * Only external interrupts are implemented among all kind of traps.
 * Nested exceptions, esp. w/ priority arbitration can be a headache, so exceptions are treated as fatal faults.

 */

// debug/trigger csr addr encoding
localparam CSR_ADDR_DCSR    = 12'h7b0,
           CSR_ADDR_DPC     = 12'h7b1,
           CSR_ADDR_TSELECT = 12'h7a0,
           CSR_ADDR_TDATA1  = 12'h7a1,
           CSR_ADDR_TDATA2  = 12'h7a2,
           CSR_ADDR_TINFO   = 12'h7a4;

/* trap csr notes

 * dcsr
 * dpc
 * tselect (hardwired to zero because only one trigger is supported)
 * tdata1
 * tdata2
 * tinfo (not required because only type 2 is supported)

 * Only one type-2 trigger is to be implemented, as HW data/instruction breakpoint.

 */

/***************************************** femto defined *****************************************/
// ex/wb stage opcode
localparam OP_UNDEF = 8'd0,
           OP_STD   = 8'd1, // write/no change regfile
           OP_JAL   = 8'd2,
           OP_JALR  = 8'd3,
           OP_LD    = 8'd4, // load
           OP_LDU   = 8'd5, // load unsigned
           OP_CSR   = 8'd6,
           OP_TRAP  = 8'd7, // trap jump
           OP_TRET  = 8'd8, // trap return
           OP_TSUC  = 8'd9; // trap succesion (trap-upon-mret)

// ex/wb alu opcode
localparam ALU_ADD  = 8'h1,
           ALU_SUB  = 8'h2,
           ALU_AND  = 8'h3,
           ALU_OR   = 8'h4,
           ALU_SET  = ALU_OR,
           ALU_CLR  = 8'h5,
           ALU_XOR  = 8'h6,
           ALU_LT   = 8'h7,
           ALU_LTU  = 8'h8,
           ALU_SRL  = 8'h9,
           ALU_SRA  = 8'ha,
           ALU_SL   = 8'hb;

// implemented CSRs
localparam CSR_NUM = 8;
// bound with csr_addr to csr_index logic
`define CSR_ADDR_TO_INDEX   {csr_addr[10], csr_addr[6]|csr_addr[4], csr_addr[0]}
localparam CSR_INDEX_MSTATUS = 3'd0,
           CSR_INDEX_MTVEC   = 3'd1,
           CSR_INDEX_MIP     = 3'd2,
           CSR_INDEX_MEPC    = 3'd3,
           CSR_INDEX_TDATA2  = 3'd4,
           CSR_INDEX_TDATA1  = 3'd5,
           CSR_INDEX_DCSR    = 3'd6,
           CSR_INDEX_DPC     = 3'd7;
