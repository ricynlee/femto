`include "femto.vh"
`include "timescale.vh"

module rst_controller (
    input wire  clk,

    input wire                  rst_ib, // lo active
    output wire[`RST_WIDTH-1:0] rst_ob, // lo active

    input wire            soc_fault,
    input wire[7:0]       soc_fault_cause,
    input wire[`XLEN-1:0] soc_fault_addr,

    input wire[$clog2(`RST_SIZE)-1:0]   addr,
    input wire                          w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]      acc,
    output reg[`BUS_WIDTH-1:0]          rdata,
    input wire[`BUS_WIDTH-1:0]          wdata,
    input wire                          req,
    output wire                         resp,
    output wire                         fault
);
    /*
     * Register map
     *  Name   | Address | Size | Access | Note
     *  RST    | 0       | 2    | W      | -
     *  CAUSE  | 2       | 2    | R      | -
     *  INFO   | 4       | 4    | R      | Core fault PC/bus fault addr
     *
     * RST
     *  (15:1) | RESET(0)
     * CAUSE
     *  (15:8) | CAUSE(7:0)
     */

    // fault generation
    wire invld_addr = (addr != 0) && (addr != 2) && (addr != 4);
    wire invld_acc  = (addr==4) ? (acc != `BUS_ACC_4B) : (acc != `BUS_ACC_2B);
    wire invld_wr   = addr ? w_rb : ~w_rb;

    wire invld      = |{invld_addr,invld_acc,invld_wr};
    assign fault    = req & invld;

    // rst info
    reg[7:0]       rst_cause_r = `RST_CAUSE_POR;
    reg[`XLEN-1:0] rst_info_r;
    always @ (posedge clk) begin
        if (~rst_ib)
            rst_cause_r <= `RST_CAUSE_HW;
        else if (req & ~invld & wdata[0])
            rst_cause_r <= `RST_CAUSE_SW;
        else if (soc_fault) begin
            rst_cause_r <= soc_fault_cause;
            rst_info_r <= soc_fault_addr;
        end
    end

    // resp generation
    reg resp_r = 1'b0; // initially no resp (FPGA synthesizable)
    assign resp = resp_r;
    always @ (posedge clk) begin
        resp_r <= req & ~invld;
        if (req & ~invld) begin
            if (addr[1]) // CAUSE
                rdata <= rst_cause_r;
            else if (addr[2]) // INFO
                rdata <= rst_info_r;
        end
    end

    // reset generation
    reg [`RST_WIDTH-1:0] rst_r = {`RST_WIDTH{1'b0}}; // initially POR (FPGA synthesizable)
    assign rst_ob = rst_r;

    always @ (posedge clk) begin
        if (~rst_ib) begin // external reset input: highest priority
            rst_r <= {`RST_WIDTH{1'b0}};
        end else if (req & ~invld & wdata[0]) begin
            rst_r <= {`RST_WIDTH{1'b0}};
        end else if (soc_fault) begin
            rst_r <= {`RST_WIDTH{1'b0}};
        end else begin
            rst_r <= {`RST_WIDTH{1'b1}};
        end
    end
endmodule
