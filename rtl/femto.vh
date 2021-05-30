`ifndef FEMTO_HEADER
`define FEMTO_HEADER

`define ILEN            (32) // max instruction len
`define XLEN            (32) // pc/xreg width
`define BUS_WIDTH       (`XLEN) // bus width

// bus
`define BUS_IDEV_ROM        (0) // ROM  0x00000000
`define BUS_IDEV_TCM        (1) // TCM  0x10000000
`define BUS_IDEV_SRAM       (2) // SRAM 0x20000000
`define BUS_IDEV_QSPINOR    (3) // QSPINOR 0x30000000
`define BUS_IDEV_GPIO       (4) // GPIO 0x40000000
`define BUS_IDEV_UART       (5) // UART 0x50000000
`define BUS_NDEV            (6) // No. of devices connected to bus

`define BUS_ACC_1B      (2'd0)
`define BUS_ACC_2B      (2'd1)
`define BUS_ACC_4B      (2'd2)
`define BUS_ACC_CNT     (2'd3)

`define GPIO_DBW            (4)
`define ROM_ABW             (12)
`define TCM_ABW             (12)
`define SRAM_ABW            (19)
// `define QSPINOR_ABW         (22) // on board qspi nor
`define QSPINOR_ABW         (24) // off board dspi nor

// core
`define RESET_PC        (32'h0000_0000)

`endif // FEMTO_HEADER
