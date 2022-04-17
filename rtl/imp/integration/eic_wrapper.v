`include "timescale.vh"
`include "femto.vh"

module eic_wrapper (
    input wire  clk,
    input wire  rstn,

    input wire[`XLEN-1:0]                p_addr, // byte addr
    input wire                           p_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] p_acc,
    output wire[`BUS_WIDTH-1:0]          p_rdata,
    input wire[`BUS_WIDTH-1:0]           p_wdata,
    input wire                           p_req,
    output wire                          p_resp,

    output wire                          eic_fault,

    output wire                      ext_int_trigger,
    input wire                       ext_int_handled,
    input wire[`EXT_INT_SRC_NUM-1:0] ext_int_src // int from ip, posedge active
);

    extint_controller extint_controller (
        .clk (clk ),
        .rstn(rstn),

        .ext_int_trigger(ext_int_trigger),
        .ext_int_handled(ext_int_handled),
        .ext_int_src    (ext_int_src    ),

        .addr (p_addr[$clog2(`EIC_SIZE)-1:0]),
        .w_rb (p_w_rb                       ),
        .acc  (p_acc                        ),
        .wdata(p_wdata                      ),
        .rdata(p_rdata                      ),
        .req  (p_req                        ),
        .resp (p_resp                       ),
        .fault(eic_fault                    )
    );
endmodule
