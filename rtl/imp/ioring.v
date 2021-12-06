`include "timescale.vh"
`include "simpaths.vh"

module ioring(
    // from/to modules
    input wire[`GPIO_WIDTH-1:0]     gpio_dir,
    output wire[`GPIO_WIDTH-1:0]    gpio_i  ,
    input wire[`GPIO_WIDTH-1:0]     gpio_o  ,

    output wire  uart_rx,
    input wire   uart_tx,

    input wire  ada_sck,
    input wire  ada_ws,
    output wire ada_sd,
    input wire  ada_lrs,

    // from/to pads
    inout wire[`GPIO_WIDTH-1:0] pad_gpio,

    input wire  pad_uart_rx,
    output wire pad_uart_tx,

    output wire pad_ada_sck,
    output wire pad_ada_ws,
    input wire  pad_ada_sd,
    output wire pad_ada_lrs
);

    assign  gpio_i = pad_gpio;
    //// ... generic option
    // generate for (genvar i=0; i<`GPIO_WIDTH; i=i+1)
    //     assign  pad_gpio[i] = gpio_dir[i]==`IOR_DIR_OUT ? gpio_o[i] : 1'bz;
    // endgenerate
    //// ... or board spec, for protection purposes
    assign  pad_gpio = {gpio_o[3:1], 1'bz};

    assign  pad_uart_tx = uart_tx;
    assign  uart_rx = pad_uart_rx;

    assign  pad_ada_sck = ada_sck;
    assign  pad_ada_ws = ada_ws;
    assign  ada_sd = pad_ada_sd;
    assign  pad_ada_lrs = ada_lrs;
endmodule
