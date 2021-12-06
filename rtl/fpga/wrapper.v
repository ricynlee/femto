`include "timescale.vh"

// fpga wrapper - this is not part of the mcu
module wrapper(
    input wire  sysclk,
    input wire  sysrst,

    output wire led_r,
    output wire led_g,
    output wire led_b,
    input wire  button,

    input wire  uart_rx,
    output wire uart_tx,

    // output wire       sram_ce_bar,
    // output wire       sram_oe_bar,
    // output wire       sram_we_bar,
    // inout wire[7:0]   sram_data  ,
    // output wire[18:0] sram_addr  ,
    // 
    // output wire     qspi_sck,
    // output wire     qspi_csb,
    // inout wire[3:0] qspi_sio
    output wire ada_sck,
    output wire ada_ws,
    input wire  ada_sd,
    output wire ada_lrs
);

    wire    clk;
    clk_gen clk_gen
    (
        .clk_out(clk),
        .clk_in(sysclk)
    );

    wire    rst;
    deglitcher sysrst_deglitcher (
        .clk(clk   ),
        .in (sysrst),
        .out(rst   )
    );

    wire    btn;
    deglitcher button_deglitcher (
        .clk(clk   ),
        .in (button),
        .out(btn   )
    );

    femto femto (
        .clk (clk ),
        .rstn(~rst),

        .gpio({led_b, led_g, led_r, btn}),

        .uart_rx(uart_rx),
        .uart_tx(uart_tx),

        // .sram_ce_bar(sram_ce_bar),
        // .sram_oe_bar(sram_oe_bar),
        // .sram_we_bar(sram_we_bar),
        // .sram_data  (sram_data  ),
        // .sram_addr  (sram_addr  ),
        // 
        // .qspi_sck(qspi_sck),
        // .qspi_csb(qspi_csb),
        // .qspi_sio(qspi_sio)
        .ada_sck(ada_sck),
        .ada_ws (ada_ws ),
        .ada_sd (ada_sd ),
        .ada_lrs(ada_lrs)
    );

endmodule

module deglitcher (
    input wire  clk,
    input wire  in,
    output wire out
);
    (*asyc_reg="true"*) reg[2:0]    v = 3'b000;
    reg[10:0] cnt;
    always @ (posedge clk) begin
        cnt <= cnt+1;

        if (cnt==0)
            v <= {v[1:0], in};
    end

    assign  out = (v==3'b000 || v==3'b001 || v==3'b010 || v==3'b100) ? 1'b0 : 1'b1;
endmodule
