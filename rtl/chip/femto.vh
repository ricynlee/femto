`ifndef FEMTO_HEADER
`define FEMTO_HEADER

/* sys clk speed */
`define SYSCLK_FREQ         (12000000) // 12MHz

/* core */
`define ILEN                (32) // max instruction len
`define XLEN                (32) // pc/xreg width

`define RESET_PC            (32'h0000_0000)

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

/* addressable controllers / mem map */
`define ROM_ADDR            (32'h0000_0000)
`define ROM_SIZE            (4*1024)        // 4KB, 2's exponent
`define ROM_VA_MASK         ({{(32-$clog2(`ROM_SIZE)){1'b0}},{$clog2(`ROM_SIZE){1'b1}}})
`define ROM_VA_WIDTH        ($clog2(`ROM_SIZE))
`define ROM_CS_MASK         (~`ROM_VA_MASK)

`define TCM_ADDR            (32'h1000_0000)
`define TCM_SIZE            (4*1024)        // 4KB, 2's exponent
`define TCM_VA_MASK         ({{(32-$clog2(`TCM_SIZE)){1'b0}},{$clog2(`TCM_SIZE){1'b1}}})
`define TCM_VA_WIDTH        ($clog2(`TCM_SIZE))
`define TCM_CS_MASK         (~`TCM_VA_MASK)

`define SRAM_ADDR           (32'h2000_0000)
`define SRAM_SIZE           (512*1024)      // 512KB
`define SRAM_VA_MASK        ({{(32-$clog2(`SRAM_SIZE)){1'b0}},{$clog2(`SRAM_SIZE){1'b1}}})
`define SRAM_VA_WIDTH       ($clog2(`SRAM_SIZE))
`define SRAM_CS_MASK        (~`SRAM_VA_MASK)

`define NOR_ADDR            (32'h3000_0000) // Serial NOR read - direct bus access
`define NOR_SIZE            (16*1024*1024)  // 16MB - max range of 3-byte mode
`define NOR_VA_MASK         ({{(32-$clog2(`NOR_SIZE)){1'b0}},{$clog2(`NOR_SIZE){1'b1}}})
`define NOR_VA_WIDTH        ($clog2(`NOR_SIZE))
`define NOR_CS_MASK         (~`NOR_VA_MASK)

`define GPIO_ADDR           (32'h4000_0000)
`define GPIO_VA_MASK        (32'h0000_0007) // 8B valid address range
`define GPIO_VA_WIDTH       ($clog2(`GPIO_VA_MASK+1))
`define GPIO_CS_MASK        (~`GPIO_VA_MASK)

`define UART_ADDR           (32'h5000_0000)
`define UART_VA_MASK        (32'h0000_0003) // 4B valid address range
`define UART_VA_WIDTH       ($clog2(`UART_VA_MASK+1))
`define UART_CS_MASK        (~`UART_VA_MASK)

`define QSPINOR_ADDR        (32'h6000_0000) // Serial NOR access - ip commands
`define QSPINOR_VA_MASK     (32'h0000_0007) // 8B valid address range
`define QSPINOR_VA_WIDTH    ($clog2(`QSPI_VA_MASK+1))
`define QSPINOR_CS_MASK     (~`QSPI_VA_MASK)

`define TMR_ADDR            (32'h7000_0000) // system timer
`define TMR_VA_MASK         (32'h0000_0003) // 4B valid address range
`define TMR_VA_WIDTH        ($clog2(`TMR_VA_MASK+1))
`define TMR_CS_MASK         (~`TMR_VA_MASK)

`define RST_ADDR            (32'hf000_0000) // system reset
`define RST_VA_MASK         (32'h0000_0003) // 4B valid address range
`define RST_VA_WIDTH        ($clog2(`RST_VA_MASK+1))
`define RST_CS_MASK         (~`RST_VA_MASK)

/* gpio */
`define GPIO_WIDTH          (4) // required <=32

/* nor/qspinor */
`define QSPINOR_MODE        (3) // 0 or 3
`define QSPINOR_X1          (2'd0)
`define QSPINOR_X2          (2'd1)
`define QSPINOR_X4          (2'd2)

/* uart */
`define UART_BAUD           (57600)

/* rst */
`define RST_CORE            ( 0)
`define RST_BUS             ( 1)
`define RST_ROM             ( 2)
`define RST_TCM             ( 3)
`define RST_SRAM            ( 4)
`define RST_NOR             ( 5)
`define RST_GPIO            ( 6)
`define RST_UART            ( 7)
`define RST_QSPI            ( 8)
`define RST_TMR             ( 9)

`define RST_WIDTH           (10)

`endif // FEMTO_HEADER
