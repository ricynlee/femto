`include "timescale.vh"
`include "femto.vh"

module rst_wrapper (
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

    input wire                  rst_ib,
    output wire[`RST_WIDTH-1:0] rst_ob,

    input wire            soc_fault,
    input wire[7:0]       soc_fault_cause,
    input wire[`XLEN-1:0] soc_fault_addr
);
    rst_controller rst_controller (
        .clk (clk),

        .rst_ib(rst_ib),
        .rst_ob(rst_ob),

        .soc_fault      (soc_fault      ),
        .soc_fault_cause(soc_fault_cause),
        .soc_fault_addr (soc_fault_addr ),

        .addr (p_addr[$clog2(`RST_SIZE)-1:0]),
        .w_rb (p_w_rb                       ),
        .acc  (p_acc                        ),
        .wdata(p_wdata                      ),
        .rdata(p_rdata                      ),
        .req  (p_req                        ),
        .resp (p_resp                       ),
        .fault(p_fault                      )
    );
endmodule
