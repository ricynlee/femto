`include "sim/timescale.vh"

module syncrst_controller #(
    parameter   RST_WIDTH = 8,
    parameter   IN_POLAR  = 1, // 0 - lo active, 1 - hi active
    parameter   OUT_POLAR = 0  // 0 - lo active, 1 - hi active
)(
    input wire                  clk,
    input wire                  rst_in,
    output wire [RST_WIDTH-1:0] rst_out
);

    localparam RST_OUT_ACTIVE_VAL   = OUT_POLAR ? {RST_WIDTH{1'b1}} : {RST_WIDTH{1'b0}},
               RST_OUT_INACTIVE_VAL = OUT_POLAR ? {RST_WIDTH{1'b0}} : {RST_WIDTH{1'b1}};
    // synchronous reset controller for FPGA
    reg [RST_WIDTH-1:0] rst_r = RST_OUT_ACTIVE_VAL; // POR
    assign rst_out = rst_r;

    always @ (posedge clk) begin
        rst_r <= rst_in==IN_POLAR ? RST_OUT_ACTIVE_VAL : RST_OUT_INACTIVE_VAL;
    end
endmodule
