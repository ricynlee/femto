`include "timescale.vh"
`include "simpaths.vh"

(* keep_hierarchy = "yes" *)
module ioring(
    // from/to modules
    input wire[`GPIO_WIDTH-1:0]     gpio_dir,
    output wire[`GPIO_WIDTH-1:0]    gpio_i  ,
    input wire[`GPIO_WIDTH-1:0]     gpio_o  ,

    output wire  uart_rx,
    input wire   uart_tx,

    input wire          sram_ce_bar  ,
    input wire          sram_oe_bar  ,
    input wire          sram_we_bar  ,
    input wire          sram_data_dir,
    output wire[7:0]    sram_data_in ,
    input wire[7:0]     sram_data_out,
    input wire[18:0]    sram_addr    ,

    input wire          qspi_csb ,
    input wire          qspi_sclk,
    input wire[3:0]     qspi_dir ,
    input wire[3:0]     qspi_mosi,
    output wire[3:0]    qspi_miso,

    // from/to pads
    inout wire[`GPIO_WIDTH-1:0] pad_gpio,

    input wire  pad_uart_rx,
    output wire pad_uart_tx,

    output wire         pad_sram_ce_bar,
    output wire         pad_sram_oe_bar,
    output wire         pad_sram_we_bar,
    inout wire[7:0]     pad_sram_data  ,
    output wire[18:0]   pad_sram_addr  ,

    output wire     pad_qspi_sck,
    output wire     pad_qspi_csb,
    inout wire[3:0] pad_qspi_sio
);

    assign  gpio_i = pad_gpio;
    //// ... generic option
    // generate for (genvar i=0; i<`GPIO_WIDTH; i=i+1)
    //     assign  pad_gpio[i] = gpio_dir[i]==`IOR_DIR_OUT ? gpio_o[i] : 1'bz;
    // endgenerate
    //// ... or board spec
    assign  pad_gpio = {gpio_o[3:1], 1'bz};

    assign  pad_uart_tx = uart_tx;
    assign  uart_rx = pad_uart_rx;

    assign  pad_sram_ce_bar = sram_ce_bar;
    assign  pad_sram_oe_bar = sram_oe_bar;
    assign  pad_sram_we_bar = sram_we_bar;
    assign  pad_sram_data = sram_data_dir==`IOR_DIR_OUT ? sram_data_out : 8'dz;
    assign  sram_data_in = pad_sram_data;
    assign  pad_sram_addr = sram_addr;

    assign  pad_qspi_csb = qspi_csb;
    assign  pad_qspi_sck = qspi_sclk;

    assign  qspi_miso = pad_qspi_sio;
    generate for (genvar i=0; i<4; i=i+1)
            assign  pad_qspi_sio[i] = qspi_dir[i]==`IOR_DIR_OUT ? qspi_mosi[i] : 1'bz;
    endgenerate
endmodule
