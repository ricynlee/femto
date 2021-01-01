`include "sim/timescale.vh"
`include "femto.vh"

module tcm_controller #(
    BYTE_ADDR_WIDTH = 12
)(
    input wire clk,
    input wire rstn,

    input wire req,
    output reg resp,

    input wire [BYTE_ADDR_WIDTH-1:0]        addr, // byte addr
    input wire                              wr_b,
    input wire [$clog2(`BUS_ACC_CNT)-1:0]   acc,
    input wire [31:0]                       wdata,
    output reg [31:0]                       rdata,
    output wire                             fault
);
    wire invld_acc = 0;
    wire invld_wr = 0;
    wire invld_d = 0;
    assign fault = invld_acc | invld_wr | invld_d;

    reg [31:0]   array[0:(1<<(BYTE_ADDR_WIDTH-2))-1];

    wire [BYTE_ADDR_WIDTH-3:0]      cell_addr = addr[BYTE_ADDR_WIDTH-1:2];
    wire [1:0]                      byte_sel[0:`BUS_ACC_CNT-1];
    assign byte_sel[`BUS_ACC_1B] = addr[1:0];
    assign byte_sel[`BUS_ACC_2B] = {addr[1], 1'b0};
    assign byte_sel[`BUS_ACC_4B] = 2'd0;
    assign byte_sel[`BUS_ACC_RSV] = 2'd0;

    always @ (posedge clk) begin
        if (rstn==0) begin
            resp <= 0;
        end else begin
            resp <= req;
        end
    end

    always @ (posedge clk) begin
        if (rstn==0) begin
            rdata <= 32'h00000000;
        end else if (req) begin
            if (~wr_b) begin // read
                rdata[7:0]   <= array[cell_addr][{byte_sel[acc] | 0, 3'd0}+:8];
                rdata[15:8]  <= array[cell_addr][{byte_sel[acc] | 1, 3'd0}+:8];
                rdata[23:16] <= array[cell_addr][{byte_sel[acc] | 2, 3'd0}+:8];
                rdata[31:24] <= array[cell_addr][{byte_sel[acc] | 3, 3'd0}+:8];
            end else begin
                if (acc==`BUS_ACC_1B) begin // write 1B
                    array[cell_addr][byte_sel[`BUS_ACC_1B]+:8] <= wdata[7:0];
                end else if (acc==`BUS_ACC_2B) begin // write 2B
                    array[cell_addr][byte_sel[`BUS_ACC_2B]+:16] <= wdata[15:0];
                end else if (acc==`BUS_ACC_4B) begin // write 4B
                    array[cell_addr] <= wdata;
                end
            end
        end
    end
endmodule

module rom_controller #(
    BYTE_ADDR_WIDTH = 12
)(
    input wire clk,
    input wire rstn,

    input wire req,
    output reg resp,

    input wire [BYTE_ADDR_WIDTH-1:0]        addr, // byte addr
    input wire                              wr_b,
    input wire [$clog2(`BUS_ACC_CNT)-1:0]   acc,
    input wire [31:0]                       wdata,
    output reg [31:0]                       rdata,
    output wire                             fault
);
    wire invld_acc = 0; // we don't need to handle unaligned r/w here
    wire invld_wr  = req & wr_b;
    wire invld_d = 0;
    assign fault = invld_acc | invld_wr | invld_d;

    wire [31:0]  array[0:(1<<(BYTE_ADDR_WIDTH-2))-1];

    wire [BYTE_ADDR_WIDTH-3:0]      cell_addr = addr[BYTE_ADDR_WIDTH-1:2];
    wire [1:0]                      byte_sel[0:`BUS_ACC_CNT-1];
    assign byte_sel[`BUS_ACC_1B] = addr[1:0];
    assign byte_sel[`BUS_ACC_2B] = {addr[1], 1'b0};
    assign byte_sel[`BUS_ACC_4B] = 2'd0;
    assign byte_sel[`BUS_ACC_RSV] = 2'd0;

    always @ (posedge clk) begin
        if (rstn==0) begin
            resp <= 0;
        end else begin
            resp <= req;
        end
    end

`include "rom.vh"

    always @ (posedge clk) begin
        if (rstn==0) begin
            rdata <= 32'h00000000;
        end else if (req) begin // read
            rdata[7:0]   <= array[cell_addr][{byte_sel[acc] | 0, 3'd0}+:8];
            rdata[15:8]  <= array[cell_addr][{byte_sel[acc] | 1, 3'd0}+:8];
            rdata[23:16] <= array[cell_addr][{byte_sel[acc] | 2, 3'd0}+:8];
            rdata[31:24] <= array[cell_addr][{byte_sel[acc] | 3, 3'd0}+:8];
        end
    end
endmodule

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
    keeper #(
        .WIDTH      (1   ),
        .INITIALIZER(1'b0)
    ) wr_b_keeper (
        .clk   (clk      ),
        .rstn  (rstn     ),
        .vld   (req      ),
        .in    (wr_b     ),
        .out   (sram_wr_b)
    );

    wire [1:0] sram_acc_bmax;
    keeper #(
        .WIDTH      (2),
        .INITIALIZER(4)
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
        .INITIALIZER(0),
        .CLEAR ("none")
    ) boff_dff (
        .clk (clk ),
        .rstn(rstn),
        .in  (sram_acc_bmax==boff?boff_dff_o:boff+8'd1),
        .out (boff_dff_o)
    );
    assign boff = req ? 8'd0 : boff_dff_o;

    wire resp_pending;
    keeper #(
        .WIDTH      (1),
        .INITIALIZER(0)
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
    keeper #(
        .WIDTH(19)
    ) addr_align_keeper (
        .clk   (clk       ),
        .rstn  (rstn      ),
        .vld   (req       ),
        .in    (acc==`BUS_ACC_1B ? addr : acc==`BUS_ACC_2B ? {addr[18:1], 1'b0} : {addr[18:2], 2'd0}),
        .out   (addr_align)
    );

    assign sram_addr = addr_align | boff;

    wire [`BUS_WIDTH-1:0] sram_wdata;
    keeper wdata_keeper(
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

module gpio_controller(
    input wire  clk,
    input wire  rstn,

    input wire [0:0]                      addr,
    input wire                            wr_b,
    input wire [$clog2(`BUS_ACC_CNT)-1:0] acc,
    output wire [`BUS_WIDTH-1:0]          rdata,
    input wire [`BUS_WIDTH-1:0]           wdata,
    input wire                            req,
    output reg                            resp,
    output wire                           fault,

    inout wire [`GPIO_DBW-1:0] io
);
    wire invld_acc = req && (acc!=`BUS_ACC_4B); // we don't need to handle unaligned r/w here
    wire invld_wr = 0;
    wire invld_d = 0;
    assign fault = invld_acc | invld_wr | invld_d;

    reg [`GPIO_DBW-1:0] dir;
    wire [`GPIO_DBW-1:0] i;
    reg [`GPIO_DBW-1:0] o;

    generate
        for (genvar index=0; index<`GPIO_DBW; index=index+1) begin
            assign io[index] = dir[index] ? o[index] : 1'bz;
            assign i[index] = (dir[index]==1'b0) ? io[index] : o[index];
        end
    endgenerate

    (*async_reg = "true"*) reg [`GPIO_DBW-1:0] rdata_r;
    assign rdata = {{(`BUS_WIDTH-`GPIO_DBW){1'b0}}, rdata_r};
    always @ (posedge clk) begin
        if (rstn==0) begin
            dir <= 0; // I
            o <= 0;
        end else if (req) begin
            if (addr==0 && wr_b==0) begin
                rdata_r <= i;
            end else if (addr==0 && wr_b==1) begin
                o <= wdata[`GPIO_DBW-1:0];
            end else if (addr==1 && wr_b==0) begin
                rdata_r <= dir;
            end else if (addr==1 && wr_b==1) begin
                dir <= wdata[`GPIO_DBW-1:0];
            end
        end
    end

    always @ (posedge clk) begin
        if (rstn==0) begin
            resp <= 0;
        end else begin
            resp <= req;
        end
    end
endmodule

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
