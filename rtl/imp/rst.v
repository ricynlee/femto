`include "femto.vh"
`include "timescale.vh"

module rst_controller(
    input wire  clk,

    input wire                  rst_ib, // lo active
    output wire[`RST_WIDTH-1:0] rst_ob  // lo active
);
    // reset generation
    reg [`RST_WIDTH-1:0] rst_r = {`RST_WIDTH{1'b0}}; // initially POR (FPGA synthesizable)
    assign rst_ob = rst_r;

    always @ (posedge clk) begin
        if (~rst_ib) begin // external reset input: higher priority
            rst_r <= {`RST_WIDTH{1'b0}};
        end else begin
            rst_r <= {`RST_WIDTH{1'b1}};
        end
    end
endmodule
