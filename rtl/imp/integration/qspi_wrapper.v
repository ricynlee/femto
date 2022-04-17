`include "timescale.vh"
`include "femto.vh"

module qspi_wrapper (
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

    input wire[`XLEN-1:0]                qspi_d_addr, // byte addr
    input wire                           qspi_d_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] qspi_d_acc,
    output wire[`BUS_WIDTH-1:0]          qspi_d_rdata,
    input wire[`BUS_WIDTH-1:0]           qspi_d_wdata,
    input wire                           qspi_d_req,
    output wire                          qspi_d_resp,
    output wire                          qspi_fault,

    output wire      spi_csb,
    output wire      spi_sclk,
    output wire[3:0] spi_dir,
    output wire[3:0] spi_mosi,
    input wire[3:0]  spi_miso
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

        .periph_d_fault(nor_d_fault),

        .i_addr (nor_i_addr ),
        .i_w_rb (nor_i_w_rb ),
        .i_acc  (nor_i_acc  ),
        .i_wdata(nor_i_wdata),
        .i_rdata(nor_i_rdata),
        .i_req  (nor_i_req  ),
        .i_resp (nor_i_resp ),

        .periph_i_fault(nor_i_fault),

        .addr (nor_addr ),
        .w_rb (nor_w_rb ),
        .acc  (nor_acc  ),
        .rdata(nor_rdata),
        .wdata(nor_wdata),
        .req  (nor_req  ),
        .resp (nor_resp ),
        .fault(nor_fault)
    );

    qspi_controller qspi_controller (
        .clk (clk ),
        .rstn(rstn),

        .nor_addr (nor_addr[$clog2(`NOR_SIZE)-1:0]),
        .nor_w_rb (nor_w_rb                       ),
        .nor_acc  (nor_acc                        ),
        .nor_rdata(nor_rdata                      ),
        .nor_wdata(nor_wdata                      ),
        .nor_req  (nor_req                        ),
        .nor_resp (nor_resp                       ),
        .nor_fault(nor_fault                      ),

        .qspi_addr (qspi_d_addr[$clog2(`QSPI_SIZE)-1:0]),
        .qspi_w_rb (qspi_d_w_rb                        ),
        .qspi_acc  (qspi_d_acc                         ),
        .qspi_wdata(qspi_d_wdata                       ),
        .qspi_rdata(qspi_d_rdata                       ),
        .qspi_req  (qspi_d_req                         ),
        .qspi_resp (qspi_d_resp                        ),
        .qspi_fault(qspi_fault                         ),

        .spi_csb (spi_csb ),
        .spi_sclk(spi_sclk),
        .spi_dir (spi_dir ),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso)
    );
endmodule
