`include "timescale.vh"
`include "simpaths.vh"

module simtop #(
    parameter HEX_PATH = `HEX_PATH
);

    reg clk = 0;
    initial forever #41.667 clk<=~clk;

    reg rst = 1;
    initial #200us @(negedge clk) rst = 0;

    wire [3:0] led;
    wire uart_rxd, uart_txd;

    wire nor_sck;
    wire nor_csb;
    wire [3:0]  nor_sio;

    pullup(nor_sio[0]);
    pullup(nor_sio[1]);
    pullup(nor_sio[2]);
    pullup(nor_sio[3]);

    localparam  DPI_SEL = 1, QPI_SEL = 2, SPI_SEL = 0;
    reg[1:0]    norflash_sel = SPI_SEL;
    dpinor dpinorflash(
        .sck(nor_sck     ),
        .csb(nor_csb | (norflash_sel!=DPI_SEL)),
        .dio(nor_sio[1:0])
    );
    initial $readmemh({HEX_PATH, "nor-init.hex"}, dpinorflash.array);

    qpinor qpinorflash(
        .sck(nor_sck),
        .csb(nor_csb | (norflash_sel!=QPI_SEL)),
        .dio(nor_sio)
    );
    initial $readmemh({HEX_PATH, "nor-init.hex"}, qpinorflash.array);

    MX25U51245G # (
        .Init_File({HEX_PATH, "nor-init.hex"})
    ) spinorflash (
        .SCLK (nor_sck   ),
        .CS   (nor_csb | (norflash_sel!=SPI_SEL)),
        .SI   (nor_sio[0]),
        .SO   (nor_sio[1]),
        .WP   (nor_sio[2]),
        .SIO3 (nor_sio[3]),
        .RESET(1'b1      )
    );
    initial #10ns spinorflash.Status_Reg[6] = 1'b1; // Quad enabled by default

    sram sram();
    initial $readmemh({HEX_PATH, "sram-init.hex"}, sram.array);

    wrapper top (
        .sysclk     (clk),
        .sysrst     (rst),
        .led_r      (led[3]),
        .led_g      (led[2]),
        .led_b      (led[1]),
        .button     (led[0]),
        .uart_tx    (uart_txd), // loopback
        .uart_rx    (uart_txd),
        .sram_ce_bar(sram.sram_ce_bar),
        .sram_oe_bar(sram.sram_oe_bar),
        .sram_we_bar(sram.sram_we_bar),
        .sram_data  (sram.sram_data  ),
        .sram_addr  (sram.sram_addr  ),
        .qspi_sck   (nor_sck),
        .qspi_csb   (nor_csb),
        .qspi_sio   (nor_sio)
    );

    // internal reset
    initial begin
        force top.rst = 1'b1;
        #8us;
        @(posedge top.clk);
        release top.rst;
    end

`include "simfeature/endsim.vh"
`include "simfeature/print.vh"
`include "simfeature/norsel.vh"
`include "simfeature/interrupt.vh"

endmodule
