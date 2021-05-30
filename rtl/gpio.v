`include "sim/timescale.vh"

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
