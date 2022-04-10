`include "timescale.vh"

module sram_controller(
    input wire  clk,  // <100MHz
    input wire  rstn, // sync

    // user interface
    input wire[$clog2(`SRAM_SIZE)-1:0]  addr,
    input wire                          w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]      acc,
    output reg[`BUS_WIDTH-1:0]          rdata,
    input wire[`BUS_WIDTH-1:0]          wdata,
    input wire                          req,
    output reg                          resp,
    output wire                         fault,

    // peripheral interface
    output wire         sram_ce_bar,
    output wire         sram_oe_bar,
    output wire         sram_we_bar,
    output wire         sram_data_dir,
    input wire[7:0]     sram_data_in,
    output wire[7:0]    sram_data_out,
    output wire[18:0]   sram_addr
);
    // fault generation
    wire invld_addr = 0;
    wire invld_acc  = (addr[0]==1'd1 && acc!=`BUS_ACC_1B) || (addr[1:0]==2'd2 && acc==`BUS_ACC_4B);
    wire invld_wr   = 0;

    wire invld      = |{invld_addr,invld_acc,invld_wr};
    assign fault    = req & invld;

    // latch request
    wire                     req_w_rb;
    wire[`SRAM_VA_WIDTH-1:0] req_addr;
    wire[`BUS_ACC_WIDTH-1:0] req_acc;
    wire[`BUS_WIDTH-1:0]     req_wdata;
    dff #(
        .WIDTH(1+`SRAM_VA_WIDTH+`BUS_ACC_WIDTH+`BUS_WIDTH),
        .VALID("async")
    ) req_acc_dff (
        .clk(clk         ),
        .vld(req & ~invld),
        .in ({w_rb, addr, acc, wdata}                ),
        .out({req_w_rb, req_addr, req_acc, req_wdata})
    );

    // busy
    wire busy;
    dff #(
        .VALID("async")
    ) busy_dff (
        .clk(clk                  ),
        .vld((req & ~invld) | resp),
        .in (req & ~invld         ),
        .out(busy                 )
    );

    // counter
    wire [1:0]  offset;
    reg  [1:0]  offset_r;
    always @ (posedge clk) begin
        if (req & ~invld)
            offset_r <= 1;
        else if (offset_r)
            offset_r <= offset_r+1;
    end
    assign  offset = (req & ~invld) ? 2'd0 : offset_r;

    // resp generation
    always @(posedge clk) begin
        if (~rstn) begin
            resp <= 0;
        end else if (busy)
            case (offset)
            0:
                resp <= (req_acc==`BUS_ACC_1B);
            1:
                resp <= (req_acc==`BUS_ACC_2B);
            3:
                resp <= 1;
            endcase
        else // !busy
            resp <= 0;
    end

    // execution
    assign sram_addr = req_addr | offset;

    assign sram_data_dir = (busy & req_w_rb) ? `IOR_DIR_OUT : `IOR_DIR_IN;
    assign sram_data_out = req_wdata[{offset, 3'd0}+:8];

    always @ (posedge clk) if (busy) rdata[{offset, 3'd0}+:8] <= sram_data_in;

    assign sram_we_bar = busy ? ~req_w_rb : 1;

    assign sram_oe_bar = 1'b0;
    assign sram_ce_bar = 1'b0;
endmodule
