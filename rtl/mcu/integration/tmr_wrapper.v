`include "timescale.vh"
`include "femto.vh"

module tmr_wrapper (
    input wire clk,
    input wire rstn,

    input wire[`XLEN-1:0]                p_addr, // byte addr
    input wire                           p_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] p_acc,
    output wire[`BUS_WIDTH-1:0]          p_rdata,
    input wire[`BUS_WIDTH-1:0]           p_wdata,
    input wire                           p_req,
    output wire                          p_resp,
    output wire                          tmr_fault,

    output wire interrupt
);
    timer_controller timer_controller (
        .clk (clk ),
        .rstn(rstn),

        .interrupt(interrupt),

        .addr (p_addr[$clog2(`TMR_SIZE)-1:0]),
        .w_rb (p_w_rb                       ),
        .acc  (p_acc                        ),
        .wdata(p_wdata                      ),
        .rdata(p_rdata                      ),
        .req  (p_req                        ),
        .resp (p_resp                       ),
    
        .fault(tmr_fault                    )
    );
endmodule
