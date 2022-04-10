`include "timescale.vh"
`include "femto.vh"

module qspinor_wrapper (
    input wire clk,
    input wire rstn,

    input wire[`XLEN-1:0]                nor_d_addr, // byte addr
    input wire                           nor_d_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] nor_d_acc,
    output wire[`BUS_WIDTH-1:0]          nor_d_rdata,
    input wire[`BUS_WIDTH-1:0]           nor_d_wdata,
    input wire                           nor_d_req,
    output wire                          nor_d_resp,
    output wire                          nor_d_fault,

    input wire[`XLEN-1:0]                nor_i_addr, // byte addr
    input wire                           nor_i_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] nor_i_acc,
    output wire[`BUS_WIDTH-1:0]          nor_i_rdata,
    input wire[`BUS_WIDTH-1:0]           nor_i_wdata,
    input wire                           nor_i_req,
    output wire                          nor_i_resp,
    output wire                          nor_i_fault,

    input wire[`XLEN-1:0]                qspinor_d_addr, // byte addr
    input wire                           qspinor_d_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] qspinor_d_acc,
    output wire[`BUS_WIDTH-1:0]          qspinor_d_rdata,
    input wire[`BUS_WIDTH-1:0]           qspinor_d_wdata,
    input wire                           qspinor_d_req,
    output wire                          qspinor_d_resp,
    output wire                          qspinor_d_fault,

    output wire      qspi_csb,
    output wire      qspi_sclk,
    output wire[3:0] qspi_dir,
    output wire[3:0] qspi_mosi,
    input wire[3:0]  qspi_miso
);
    wire[`XLEN-1:0]                nor_addr;
    wire                           nor_w_rb;
    wire[$clog2(`BUS_ACC_CNT)-1:0] nor_acc;
    wire[`BUS_WIDTH-1:0]           nor_rdata;
    wire[`BUS_WIDTH-1:0]           nor_wdata;
    wire                           nor_req;
    wire                           nor_resp;
    wire                           nor_fault;

    bus_duplexer bus_duplexer (
        .clk (clk ),
        .rstn(rstn),

        .d_addr (nor_d_addr ),
        .d_w_rb (nor_d_w_rb ),
        .d_acc  (nor_d_acc  ),
        .d_wdata(nor_d_wdata),
        .d_rdata(nor_d_rdata),
        .d_req  (nor_d_req  ),
        .d_resp (nor_d_resp ),
        .d_fault(nor_d_fault),

        .i_addr (nor_i_addr ),
        .i_w_rb (nor_i_w_rb ),
        .i_acc  (nor_i_acc  ),
        .i_wdata(nor_i_wdata),
        .i_rdata(nor_i_rdata),
        .i_req  (nor_i_req  ),
        .i_resp (nor_i_resp ),
        .i_fault(nor_i_fault),

        .addr (nor_addr ),
        .w_rb (nor_w_rb ),
        .acc  (nor_acc  ),
        .rdata(nor_rdata),
        .wdata(nor_wdata),
        .req  (nor_req  ),
        .resp (nor_resp ),
        .fault(nor_fault)
    );

    qspinor_controller qspinor_controller (
        .clk         (clk ),
        .nor_rstn    (rstn),
        .qspinor_rstn(rstn),

        .nor_addr (nor_addr[$clog2(`NOR_SIZE)-1:0]),
        .nor_w_rb (nor_w_rb                       ),
        .nor_acc  (nor_acc                        ),
        .nor_rdata(nor_rdata                      ),
        .nor_wdata(nor_wdata                      ),
        .nor_req  (nor_req                        ),
        .nor_resp (nor_resp                       ),
        .nor_fault(nor_fault                      ),

        .qspinor_addr (qspinor_d_addr[$clog2(`QSPINOR_SIZE)-1:0]),
        .qspinor_w_rb (qspinor_d_w_rb                           ),
        .qspinor_acc  (qspinor_d_acc                            ),
        .qspinor_wdata(qspinor_d_wdata                          ),
        .qspinor_rdata(qspinor_d_rdata                          ),
        .qspinor_req  (qspinor_d_req                            ),
        .qspinor_resp (qspinor_d_resp                           ),
        .qspinor_fault(qspinor_d_fault                          ),

        .qspi_csb (qspi_csb ),
        .qspi_sclk(qspi_sclk),
        .qspi_dir (qspi_dir ),
        .qspi_mosi(qspi_mosi),
        .qspi_miso(qspi_miso)
    );
endmodule
