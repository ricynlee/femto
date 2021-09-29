`include "femto.vh"
`include "timescale.vh"

(* keep_hierarchy = "yes" *)
module rst_controller(
    input wire  clk,

    input wire                  rst_ib, // lo active
    output wire[`RST_WIDTH-1:0] rst_ob, // lo active

    input wire[`RST_VA_WIDTH-1:0]   addr,
    input wire                      w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]  acc,
    output wire[`BUS_WIDTH-1:0]     rdata,
    input wire[`BUS_WIDTH-1:0]      wdata,
    input wire                      req,
    output wire                     resp,
    output wire                     fault
);
    /*
     * Register map
     *  Name | Address | Size | Access | Note
     *  RST  | 0       | 1    | W      | <RST_WIDTH, reset single module. Otherwise, reset all.
     */

    // fault generation
    wire invld_addr = (addr!=0);
    wire invld_acc  = (acc != `BUS_ACC_1B);
    wire invld_wr   = (w_rb != 1'b1);
    wire invld_d    = (wdata>`RST_WIDTH);

    wire invld      = |{invld_addr,invld_acc,invld_wr,invld_d};
    assign fault    = req & invld;

    // resp generation
    reg resp_r = 1'b0; // initially no resp (FPGA synthesizable)
    assign resp = resp_r;

    always @ (posedge clk) begin
        resp_r <= req & ~invld;
    end

    // reset generation
    reg [`RST_WIDTH-1:0] rst_r = {`RST_WIDTH{1'b0}}; // initially POR (FPGA synthesizable)
    assign rst_ob = rst_r;

    always @ (posedge clk) begin
        if (~rst_ib) begin // external reset input: higher priority
            rst_r <= {`RST_WIDTH{1'b0}};
        end else if (req & ~invld) begin
            if (wdata==0)
                rst_r <= {`RST_WIDTH{1'b0}};
            else
                rst_r <= ~(1<<(wdata-1));
        end else begin
            rst_r <= {`RST_WIDTH{1'b1}};
        end
    end
endmodule
