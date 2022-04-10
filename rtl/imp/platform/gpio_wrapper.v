`include "timescale.vh"
`include "femto.vh"

module gpio_wrapper (
    input wire clk,
    input wire rstn,

    input wire[`XLEN-1:0]                p_addr, // byte addr
    input wire                           p_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] p_acc,
    output wire[`BUS_WIDTH-1:0]          p_rdata,
    input wire[`BUS_WIDTH-1:0]           p_wdata,
    input wire                           p_req,
    output wire                          p_resp,
    output wire                          p_fault,

    output wire[`GPIO_WIDTH-1:0] dir,
    input wire[`GPIO_WIDTH-1:0]  i,
    output wire[`GPIO_WIDTH-1:0] o
);
    gpio_controller gpio_controller (
        .clk (clk ),
        .rstn(rstn),

        .dir(dir),
        .i  (i  ),
        .o  (o  ),

        .addr (p_addr[$clog2(`GPIO_SIZE)-1:0]),
        .w_rb (p_w_rb                        ),
        .acc  (p_acc                         ),
        .wdata(p_wdata                       ),
        .rdata(p_rdata                       ),
        .req  (p_req                         ),
        .resp (p_resp                        ),
        .fault(p_fault                       )
    );
endmodule
