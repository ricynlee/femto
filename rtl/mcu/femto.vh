`ifndef FEMTO_HEADER
`define FEMTO_HEADER

/* sys clk speed */
`define SYSCLK_FREQ         (24000000) // 24MHz

/* core */
`define ILEN                (32) // max instruction len
`define XLEN                (32) // pc/xreg width

`define RESET_PC            (32'h0000_0000)

/* interrupt */
`define INT_RST_EN          (1'b0) // interrupt enabled or not at rst
`define EXT_INT_SRC_NUM     (2)    // <=XLEN

`define EXT_INT_SRC_TMR     (0)
`define EXT_INT_SRC_UART    (1)

/* bus */
`define BUS_WIDTH           (`XLEN) // bus width

`define BUS_ACC_1B          (2'd0)
`define BUS_ACC_2B          (2'd1)
`define BUS_ACC_4B          (2'd2)
`define BUS_ACC_CNT         (2'd3)
`define BUS_ACC_WIDTH       ($clog2(`BUS_ACC_CNT))

/* io ring */
`define IOR_DIR_IN          (1'b0)
`define IOR_DIR_OUT         (~`IOR_DIR_IN)

// Memory Map /////////////////////////////////////////////////////////////////////////////////////
/* high speed: ibus/dbus */
`define ROM_BASE            (32'h0000_0000)
`define ROM_SIZE            (4*1024) // 4KB, 2's exponent

`define DBGTCM_BASE         (32'h0001_0000)
`define DBGTCM_SIZE         (256) // 256, 2's exponent

`define TCM_BASE            (32'h1000_0000)
`define TCM_SIZE            (4*1024) // 4KB, 2's exponent

`define SRAM_BASE           (32'h2000_0000)
`define SRAM_SIZE           (512*1024) // 512KB

`define NOR_BASE            (32'h3000_0000) // Serial NOR read - direct bus access
`define NOR_SIZE            (16*1024*1024)  // 16MB - max range of 3-byte mode

`define QSPI_BASE           (32'h4000_0000) // Serial NOR access - ip commands
`define QSPI_SIZE           (8)             // 8B valid address range

`define BRIDGE_BASE         (32'h8000_0000)
`define BRIDGE_SIZE         (32'h8000_0000) // 2GB valid address range

/* low speed: pbus (sub-bus of bridge) */

`define EIC_BASE            (32'h8000_0000) // external interrupt controller
`define EIC_SIZE            (4)             // 4B valid address range

`define UART_BASE           (32'h9000_0000)
`define UART_SIZE           (4) // 4B valid address range

`define GPIO_BASE           (32'ha000_0000)
`define GPIO_SIZE           (8) // 8B valid address range

`define TMR_BASE            (32'hb000_0000)
`define TMR_SIZE            (8) // 8B valid address range

`define ABSCMD_BASE         (32'hc000_0000)
`define ABSCMD_SIZE         ()

`define RST_BASE            (32'hf000_0000)
`define RST_SIZE            (8) // 8B valid address range

// Peripheral configuration ///////////////////////////////////////////////////////////////////////
/* gpio */
`define GPIO_WIDTH          (4) // required <=32

/* nor/qspinor */
`define QSPI_MODE           (3) // 0 or 3
`define QSPI_X1             (2'd0)
`define QSPI_X2             (2'd1)
`define QSPI_X4             (2'd2)

/* uart */
`define UART_BAUD           (57600)
`define UART_FIFO_DEPTH     (8)

/* qspinor */
`define QSPI_FIFO_DEPTH     (16)

/* timer */
`define TMR_TICK            (1000000) // 1MHz
`define TMR_DIV             (`SYSCLK_FREQ/`TMR_TICK)

/* rst */
`define RST_WIDTH           (10)

/* fault / rst cause */
`define RST_CAUSE_POR       (8'd0)
`define RST_CAUSE_HW        (8'd1)
`define RST_CAUSE_SW        (8'd2)
`define RST_FAULT_CORE      (8'd3)
`define RST_FAULT_IBUS      (8'd4) // bus req points to nothing
`define RST_FAULT_DBUS      (8'd5) // bus req points to nothing
`define RST_FAULT_IPER      (8'd6)
`define RST_FAULT_DPER      (8'd7)

`endif // FEMTO_HEADER
