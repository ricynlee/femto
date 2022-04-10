`include "timescale.vh"
`include "femto.vh"

module rom_wrapper (
    input wire  clk,
    input wire  rstn,

    // data bus interface
    input wire[`XLEN-1:0]                d_addr, // byte addr
    input wire                           d_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] d_acc,
    output wire[`BUS_WIDTH-1:0]          d_rdata,
    input wire[`BUS_WIDTH-1:0]           d_wdata,
    input wire                           d_req,
    output wire                          d_resp,
    output wire                          d_fault,

    // instruction bus interface
    input wire[`XLEN-1:0]                i_addr, // byte addr
    input wire                           i_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] i_acc,
    output wire[`BUS_WIDTH-1:0]          i_rdata,
    input wire[`BUS_WIDTH-1:0]           i_wdata,
    input wire                           i_req,
    output wire                          i_resp,
    output wire                          i_fault
);
    wire[`XLEN-1:0]                addr;
    wire                           w_rb;
    wire[$clog2(`BUS_ACC_CNT)-1:0] acc;
    wire[`BUS_WIDTH-1:0]           rdata;
    wire[`BUS_WIDTH-1:0]           wdata;
    wire                           req;
    wire                           resp;
    wire                           fault;

    bus_duplexer bus_duplexer (
        .clk       (clk ),
        .rstn      (rstn),

        .d_addr (d_addr ),
        .d_w_rb (d_w_rb ),
        .d_acc  (d_acc  ),
        .d_wdata(d_wdata),
        .d_rdata(d_rdata),
        .d_req  (d_req  ),
        .d_resp (d_resp ),
        .d_fault(d_fault),

        .i_addr (i_addr ),
        .i_w_rb (i_w_rb ),
        .i_acc  (i_acc  ),
        .i_wdata(i_wdata),
        .i_rdata(i_rdata),
        .i_req  (i_req  ),
        .i_resp (i_resp ),
        .i_fault(i_fault),

        .addr  (addr ),
        .w_rb  (w_rb ),
        .acc   (acc  ),
        .rdata (rdata),
        .wdata (wdata),
        .req   (req  ),
        .resp  (resp ),
        .fault (fault)
    );

    rom_controller rom_controller (
        .clk (clk ),
        .rstn(rstn),

        .addr (addr[$clog2(`ROM_SIZE)-1:0]),
        .w_rb (w_rb                       ),
        .acc  (acc                        ),
        .rdata(rdata                      ),
        .wdata(wdata                      ),
        .req  (req                        ),
        .resp (resp                       ),
        .fault(fault                      )
    );
endmodule
