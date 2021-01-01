`ifndef FEMTO_HEADER
`define FEMTO_HEADER

`define ILEN            (32) // fixed for femto
`define XLEN            (32) // pc/xreg width
`define BUS_WIDTH       (`ILEN) // bus width

// bus
`define BUS_NDEV            (6) // No. of devices connected to bus
`define BUS_IDEV_ROM        (0) // ROM  0x00000000
`define BUS_IDEV_TCM        (1) // TCM  0x10000000
`define BUS_IDEV_SRAM       (2) // SRAM 0x20000000
`define BUS_IDEV_QSPINOR    (3) // QSPINOR 0x30000000
`define BUS_IDEV_GPIO       (4) // GPIO 0x40000000
`define BUS_IDEV_UART       (5) // UART 0x50000000

`define BUS_ACC_1B      (0)
`define BUS_ACC_2B      (1)
`define BUS_ACC_4B      (2)
`define BUS_ACC_RSV     (3) // Regarded as 4B
`define BUS_ACC_CNT     (4)
`define BUS_ACC_I       `BUS_ACC_4B // Instruction access

`define GPIO_DBW            (4)
`define ROM_ABW             (12)
`define TCM_ABW             (12)
`define SRAM_ABW            (19)
// `define QSPINOR_ABW         (22) // on board qspi nor
`define QSPINOR_ABW         (24) // off board dspi nor

// core
`define RESET_PC        (32'h0000_0000)
`define NOP_INSTR       (32'h0000_0013)

`define PC_INC          (0)
`define PC_STD          (`PC_INC) // synonym of PC_INC
`define PC_JMP          (1)
`define PC_MUX_CNT      (2)

`define BUS_R_I         (0) // Bus req/resp: instruction
`define BUS_R_D         (1) // Bus req/resp: data
`define BUS_R_CNT       (2)

`define OP_UNDEF        (8'd0)
`define OP_STD          (8'd1) // Write regfile only
`define OP_JAL          (8'd2)
`define OP_JALR         (8'd3)
`define OP_LB           (8'd4)
`define OP_LH           (8'd5)
`define OP_LW           (8'd6)
`define OP_LBU          (8'd7)
`define OP_LHU          (8'd8)

`define ALU_ADD         (8'h1)
`define ALU_SUB         (8'h2)
`define ALU_AND         (8'h3)
`define ALU_OR          (8'h4)
`define ALU_XOR         (8'h5)
`define ALU_LT          (8'h6)
`define ALU_LTU         (8'h7)
`define ALU_SRL         (8'h8)
`define ALU_SRA         (8'h9)
`define ALU_SL          (8'ha)
`define ALU_NOP         (8'h0)

`endif // FEMTO_HEADER
