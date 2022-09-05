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

localparam ILLEGAL_INSTR = {`ILEN{1'b0}};

// trap csr addr encoding
localparam CSR_ADDR_MSTATUS = 12'h300,
           CSR_ADDR_MIE     = 12'h304,
           CSR_ADDR_MTVEC   = 12'h305,
           CSR_ADDR_MEPC    = 12'h341,
           CSR_ADDR_MCAUSE  = 12'h342,
           CSR_ADDR_MTVAL   = 12'h343,
           CSR_ADDR_MIP     = 12'h344;

// trap csr field definition
`define MIE  3  // mstatus.MIE - global int enable
`define MPIE 7  // mstatus.MPIE - prev MIE
`define MEIE 11 // mie.MEIE - ext int enable
`define MEIP 11 // mip.MEIP - ext int pending

// trap cause
localparam MCAUSE_EXT_INT        = {1'b1, 31'd11}, // external interrupt
           MCAUSE_IBUS_MISALIGN  = {1'b0, 31'd0 }, // merged to the next mcause val
           MCAUSE_IBUS_FAULT     = {1'b0, 31'd1 }, // instruction access fault
           MCAUSE_IILEGAL_INSTR  = {1'b0, 31'd2 }, // illegal instruction
           MCAUSE_BREAKPOINT     = {1'b0, 31'd3 }, // femto does not implement this exception
           MCAUSE_LOAD_MISALIGN  = {1'b0, 31'd4 }, // merged to the next mcause val
           MCAUSE_LOAD_FAULT     = {1'b0, 31'd5 }, // load data access fault
           MCAUSE_STORE_MISALIGN = {1'b0, 31'd6 }, // merged to the next mcause val
           MCAUSE_STORE_FAULT    = {1'b0, 31'd7 }; // store data access fault
           // note: femto bus is not gonna distinguish "misalign" & "fault"
           // note: femto always sees ebreak as dbg trigger event rather than an exception

/* trap csr notes

 * mstatus // mie & mpie function, other are WPRI fields
           // mie is hw cleared upon traps, and works only on interrupts
 * mtvec   // trap jmp dst pc
 * mepc    // erroneous instruction addr(s2_pc) for exception
           // unexecuted instruction(s1_pc) addr for interrupt
           // works for both exceptions and interrupts
 * mcause  // distinguishes exceptions/interrupts
 * mtval   // extra info of a trap: e.g. access fault addr or illegal instruction encoding
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

/* debug/trigger csr notes
 * dcsr
 * dpc (pc upon debugger interrupting exec flow)
 * tselect (hardwired to zero because only one trigger is supported, to be dbg mode sw-implemented)
 * tdata1
 * tdata2
 * tinfo (hardwired because only type 2 is supported, to be dbg mode sw-implemented)
 * Only one type-2 trigger is to be implemented, as hw instruction breakpoint.
 */

/***************************************** femto defined *****************************************/
// alu opcode
`define ALU_OP_WIDTH 4
localparam ALU_ZERO = 4'h0,
           ALU_A    = 4'h1, // a direct to output
           ALU_B    = 4'h2, // b direct to output
           ALU_ADD  = 4'h3,
           ALU_SUB  = 4'h4,
           ALU_AND  = 4'h5,
           ALU_OR   = 4'h6,
           ALU_SET  = ALU_OR, // set bits where there are corresponding 1's
           ALU_CLR  = 4'h7, // clear bits where there are corresponding 1's
           ALU_XOR  = 4'h8,
           ALU_LT   = 4'h9, // larger than, signed
           ALU_LTU  = 4'ha, // larger than, unsigned
           ALU_SRL  = 4'hb, // shift right, logical
           ALU_SRA  = 4'hc, // shift right, arithemetic
           ALU_SL   = 4'hd; // shift left

// x regfile write opcode
`define X_OP_WIDTH 3
localparam X_FROM_ALU = 3'd0,
           X_FROM_SD  = 3'd1, // signed data
           X_FROM_UD  = 3'd2, // unsigned data
           X_FROM_CSR = 3'd3,
           X_FROM_LR  = 3'd4; // return address/next PC, for link register

// interrupt opcode
`define INT_OP_WIDTH 3
localparam OP_INT_NONE = 3'd0, // normal exec
           OP_INT_INT  = 3'd1, // interrupt
           OP_INT_INTS = 3'd2, // interrupt succession
           OP_INT_DBG  = 3'd3, // debug exception (implemented as interrupt)
           OP_INT_MRET = 3'd4,
           OP_INT_DRET = 3'd5;

/* ex/wb stage opcode notes
 * jump requests are initiated id stage but jump occurs a clock later
 * jump addr are calculated in ex/wb stage and is right a clock later than coresponding jump requests
 * alu output is always seen as jump addr but is only effective when there is a pending jump request
 */

// implemented CSRs
// bound with csr_addr to csr_index logic
`define CSR_IDX_WIDTH 4
`define CSR_ADDR_TO_IDX   {csr_addr[10] /*trap/dbg csr distinguisher*/, (csr_addr[4] ^ csr_addr[2]), csr_addr[1:0]}
localparam CSR_IDX_MSTATUS = 4'b0000,
           CSR_IDX_MEPC    = 4'b0001,
           CSR_IDX_MCAUSE  = 4'b0010,
           CSR_IDX_MTVAL   = 4'b0011,
           CSR_IDX_MIP     = 4'b0100,
           CSR_IDX_MTVEC   = 4'b0101,
           CSR_IDX_TDATA1  = 4'b1001,
           CSR_IDX_TDATA2  = 4'b1010,
           CSR_IDX_DCSR    = 4'b1100,
           CSR_IDX_DPC     = 4'b1101;
