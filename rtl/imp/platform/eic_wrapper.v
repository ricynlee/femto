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
    output wire                          p_fault,

    output wire                      ext_int_trigger,
    input wire                       ext_int_handled,
    input wire[`EXT_INT_SRC_NUM-1:0] ext_int_src_vect, // int from ip, posedge active

);
    extint_controller extint_controller (
        .clk (clk ),
        .rstn(rstn),

        .ext_int_trigger (ext_int_trigger ),
        .ext_int_handled (ext_int_handled ),
        .ext_int_src_vect(ext_int_src_vect),

        .addr (p_addr[$clog2(`EIC_SIZE)-1:0]),
        .w_rb (p_w_rb                       ),
        .acc  (p_acc                        ),
        .wdata(p_wdata                      ),
        .rdata(p_eic_rdata                  ),
        .req  (p_eic_req                    ),
        .resp (p_eic_resp                   ),
        .fault(p_fault                      )
    );
endmodule
