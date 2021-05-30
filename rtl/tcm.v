`include "sim/timescale.vh"
// `include "femto.vh"

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
