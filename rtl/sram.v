`include "sim/timescale.vh"

module sram_controller(
    input wire  clk, // <=100MHz
    input wire  rstn, // sync
    // user interface
    input wire  req,
    output reg  resp,
    input wire  wr_b,
    input wire [$clog2(`BUS_ACC_CNT)-1:0]   acc,
    input wire  [18:0]                      addr,
    input wire  [31:0]                      wdata,
    output wire [31:0]                      rdata,
    output wire                             fault,
    // peripheral interface
    output wire         sram_ce_bar,
    output wire         sram_oe_bar,
    output wire         sram_we_bar,
    inout wire  [7:0]   sram_data,
    output wire [18:0]  sram_addr
);
    wire invld_acc = 0; // we don't need to handle unaligned r/w here
    wire invld_wr = 0;
    wire invld_d = 0;
    assign fault = invld_acc | invld_wr | invld_d;

    wire sram_wr_b;
    dff #(
        .RESET("sync"),
        .VALID("async")
    ) wr_b_keeper (
        .clk   (clk      ),
        .rstn  (rstn     ),
        .vld   (req      ),
        .in    (wr_b     ),
        .out   (sram_wr_b)
    );

    wire [1:0] sram_acc_bmax;
    dff #(
        .WIDTH(2),
        .RESET("sync"),
        .VALID("async")
    ) acc_bmax_keeper (
        .clk   (clk ),
        .rstn  (rstn),
        .vld   (req ),
        .in    (acc==`BUS_ACC_1B ? 2'd0 : (acc==`BUS_ACC_2B ? 2'd1 : 2'd3)),
        .out   (sram_acc_bmax)
    );

    wire [7:0] boff;
    wire [7:0] boff_dff_o;
    dff #(
        .WIDTH      (8),
        .RESET ("sync")
    ) boff_dff (
        .clk (clk ),
        .rstn(rstn),
        .in  (sram_acc_bmax==boff?boff_dff_o:boff+8'd1),
        .out (boff_dff_o)
    );
    assign boff = req ? 8'd0 : boff_dff_o;

    wire resp_pending;
    dff #(
        .RESET("sync"),
        .VALID("async")
    ) resp_pending_keeper (
        .clk   (clk     ),
        .rstn  (rstn    ),
        .vld   (req|resp),
        .in    (req     ),
        .out   (resp_pending)
    );

    always @(posedge clk) begin
        if (rstn==0) begin
            resp <= 0;
        end else if (resp_pending==0) begin
            resp <= 0;
        end else if (resp_pending && boff==sram_acc_bmax) begin
            resp <= 1;
        end else if (req) begin
            resp <= 0;
        end
    end

    wire [18:0] addr_align;
    dff #(
        .WIDTH(19),
        .RESET("sync"),
        .VALID("async")
    ) addr_align_keeper (
        .clk   (clk       ),
        .rstn  (rstn      ),
        .vld   (req       ),
        .in    (acc==`BUS_ACC_1B ? addr : acc==`BUS_ACC_2B ? {addr[18:1], 1'b0} : {addr[18:2], 2'd0}),
        .out   (addr_align)
    );

    assign sram_addr = addr_align | boff;

    wire [`BUS_WIDTH-1:0] sram_wdata;
    dff #(
        .WIDTH(32),
        .RESET("sync"),
        .VALID("async")
    ) wdata_keeper(
        .clk   (clk       ),
        .rstn  (rstn      ),
        .vld   (req       ),
        .in    (wdata     ),
        .out   (sram_wdata)
    );

    wire [7:0]   wr_sram_data = resp_pending ? sram_wdata[{boff, 3'd0}+:8] : 0;
    wire [7:0]   rd_sram_data;
    assign  sram_data = sram_we_bar ? 8'hzz : wr_sram_data;
    assign  rd_sram_data = sram_we_bar ? sram_data : 8'h00;

    (*async_reg*) reg [31:0] rd_sram_data_r;
    assign rdata = rd_sram_data_r;
    always @ (posedge clk) begin
        if (resp_pending && sram_wr_b==0) begin
            rd_sram_data_r[{boff, 3'd0}+:8]<=rd_sram_data;
        end
    end

    assign  sram_we_bar = resp_pending ? ~sram_wr_b : 1;

    assign  sram_oe_bar = 1'b0;
    assign  sram_ce_bar = 1'b0;
endmodule
