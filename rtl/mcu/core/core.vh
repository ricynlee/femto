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
`define OP_ALU_IDX 3:0
localparam OP_ALU_ZERO = 4'h0,
           OP_ALU_A    = 4'h1, // a direct to output
           OP_ALU_B    = 4'h2, // b direct to output
           OP_ALU_ADD  = 4'h3,
           OP_ALU_SUB  = 4'h4,
           OP_ALU_AND  = 4'h5,
           OP_ALU_OR   = 4'h6,
           OP_ALU_SET  = ALU_OR, // set bits where there are corresponding 1's
           OP_ALU_CLR  = 4'h7, // clear bits where there are corresponding 1's
           OP_ALU_XOR  = 4'h8,
           OP_ALU_LT   = 4'h9, // larger than, signed
           OP_ALU_LTU  = 4'ha, // larger than, unsigned
           OP_ALU_SRL  = 4'hb, // shift right, logical
           OP_ALU_SRA  = 4'hc, // shift right, arithemetic
           OP_ALU_SL   = 4'hd; // shift left
           
// x regfile opcode
`define OP_X_IDX 6:4
localparam OP_X_FROM_ALU = 3'd0,
           OP_X_FROM_SD  = 3'd1, // signed data
           OP_X_FROM_UD  = 3'd2, // unsigned data
           OP_X_FROM_CSR = 3'd3,
           OP_X_FROM_LR  = 3'd4; // return address/next PC, for link register

localparam OP_WR_CSR = OP_X_FROM_CSR; // alias

// interrupt opcode
`define OP_INT_IDX 9:7
localparam OP_INT_NONE = 3'd0, // normal exec
           OP_INT_INT  = 3'd1, // interrupt
           OP_INT_INTS = 3'd2, // interrupt succession
           OP_INT_DBG  = 3'd3, // debug exception (implemented as interrupt)
           OP_INT_MRET = 3'd4,
           OP_INT_DRET = 3'd5;

// opcode by instruction decoder
localparam OP_INT  = {OP_INT_INT,  OP_X_FROM_ALU, OP_ALU_ZERO},
           OP_INTS = {OP_INT_INTS, OP_X_FROM_ALU, OP_ALU_ZERO},

           OP_MRET = {OP_INT_MRET, OP_X_FROM_ALU, OP_ALU_ZERO},
           OP_DRET = {OP_INT_DRET, OP_X_FROM_ALU, OP_ALU_ZERO},

           OP_LUI     = {OP_INT_NONE, OP_X_FROM_ALU, OP_ALU_A   },
           OP_AUIPC   = {OP_INT_NONE, OP_X_FROM_ALU, OP_ALU_ADD },
           OP_JAL     = {OP_INT_NONE, OP_X_FROM_LR,  OP_ALU_ZERO},
           OP_JALR    = {OP_INT_NONE, OP_X_FROM_LR,  OP_ALU_ZERO},
           OP_BEQ     = {OP_INT_NONE, },
           OP_BNE     = {OP_INT_NONE, },
           OP_BLT     = {OP_INT_NONE, },
           OP_BGE     = {OP_INT_NONE, },
           OP_BLTU    = {OP_INT_NONE, },
           OP_BGEU    = {OP_INT_NONE, },
           OP_LB      = {OP_INT_NONE, },
           OP_LH      = {OP_INT_NONE, },
           OP_LW      = {OP_INT_NONE, },
           OP_LBU     = {OP_INT_NONE, },
           OP_LHU     = {OP_INT_NONE, },
           OP_SB      = {OP_INT_NONE, },
           OP_SH      = {OP_INT_NONE, },
           OP_SW      = {OP_INT_NONE, },
           OP_ADDI    = {OP_INT_NONE, },
           OP_SLTI    = {OP_INT_NONE, },
           OP_SLTIU   = {OP_INT_NONE, },
           OP_XORI    = {OP_INT_NONE, },
           OP_ORI     = {OP_INT_NONE, },
           OP_ANDI    = {OP_INT_NONE, },
           OP_SLLI    = {OP_INT_NONE, },
           OP_SRLI    = {OP_INT_NONE, },
           OP_SRAI    = {OP_INT_NONE, },
           OP_ADD     = {OP_INT_NONE, },
           OP_SUB     = {OP_INT_NONE, },
           OP_SLL     = {OP_INT_NONE, },
           OP_SLT     = {OP_INT_NONE, },
           OP_SLTU    = {OP_INT_NONE, },
           OP_XOR     = {OP_INT_NONE, },
           OP_SRL     = {OP_INT_NONE, },
           OP_SRA     = {OP_INT_NONE, },
           OP_OR      = {OP_INT_NONE, },
           OP_AND     = {OP_INT_NONE, },
           OP_FENCE   = {OP_INT_NONE, },
           OP_FENCE_I = {OP_INT_NONE, },
           OP_EBREAK  = {OP_INT_DBG, OP_X_FROM_ALU, OP_ALU_NOP},
           OP_CSRRW   = {OP_INT_NONE, },
           OP_CSRRS   = {OP_INT_NONE, },
           OP_CSRRC   = {OP_INT_NONE, },
           OP_CSRRWI  = {OP_INT_NONE, },
           OP_CSRRSI  = {OP_INT_NONE, },
           OP_CSRRCI  = {OP_INT_NONE, };

/* ex/wb stage opcode notes
 * jump requests are initiated id stage but jump occurs a clock later
 * jump addr are calculated in ex/wb stage and is right a clock later than coresponding jump requests
 * alu output is always seen as jump addr but is only effective when there is a pending jump request
 */

// implemented CSRs
localparam CSR_NUM = 10;
// bound with csr_addr to csr_index logic
`define CSR_ADDR_TO_IDX   {csr_addr[10] /*trap/dbg csr distinguisher*/, (csr_addr[10] ? csr_addr[4] : csr_addr[6]), csr_addr[1:0]}
localparam CSR_IDX_MSTATUS = 4'd0 ,
           CSR_IDX_MTVEC   = 4'd1 ,
           CSR_IDX_MIP     = 4'd4 ,
           CSR_IDX_MEPC    = 4'd5 ,
           CSR_IDX_MCAUSE  = 4'd6 ,
           CSR_IDX_MTVAL   = 4'd7 ,
           CSR_IDX_TDATA1  = 4'd9 ,
           CSR_IDX_TDATA2  = 4'd10,
           CSR_IDX_DCSR    = 4'd12,
           CSR_IDX_DPC     = 4'd13;
