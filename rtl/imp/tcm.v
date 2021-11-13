`include "femto.vh"
`include "timescale.vh"

module tcm_controller(
    input wire clk,
    input wire rstn,

    input wire[`TCM_VA_WIDTH-1:0]   addr,
    input wire                      w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]  acc,
    output reg[`BUS_WIDTH-1:0]      rdata,
    input wire[`BUS_WIDTH-1:0]      wdata,
    input wire                      req,
    output reg                      resp,
    output wire                     fault
);
    // fault generation
    wire invld_addr = 0;
    wire invld_acc  = (addr[0]==1'd1 && acc!=`BUS_ACC_1B) || (addr[1:0]==2'd2 && acc==`BUS_ACC_4B);
    wire invld_wr   = 0;
    wire invld_d    = 0;

    wire invld      = |{invld_addr,invld_acc,invld_wr,invld_d};
    assign fault    = req & invld;

    // resp generation
    always @ (posedge clk) begin
        if (~rstn) begin
            resp <= 0;
        end else begin
            resp <= req & ~invld;
        end
    end

    // array operations
    reg [31:0]  array[0:(1<<(`TCM_VA_WIDTH-2))-1];

    wire [`TCM_VA_WIDTH-3:0]    cell_addr = addr[`TCM_VA_WIDTH-1:2];
    wire [1:0]                  byte_sel[0:`BUS_ACC_CNT-1];
    assign byte_sel[`BUS_ACC_1B] = addr[1:0];
    assign byte_sel[`BUS_ACC_2B] = {addr[1], 1'b0};
    assign byte_sel[`BUS_ACC_4B] = 2'd0;

    always @ (posedge clk) begin
        if (req) begin
            if (~w_rb) begin // read
                rdata[7:0]   <= array[cell_addr][{byte_sel[acc] | 0, 3'd0}+:8];
                rdata[15:8]  <= array[cell_addr][{byte_sel[acc] | 1, 3'd0}+:8];
                rdata[23:16] <= array[cell_addr][{byte_sel[acc] | 2, 3'd0}+:8];
                rdata[31:24] <= array[cell_addr][{byte_sel[acc] | 3, 3'd0}+:8];
            end else begin
                if (acc==`BUS_ACC_1B) begin // write 1B
                    array[cell_addr][{byte_sel[`BUS_ACC_1B], 3'd0}+:8] <= wdata[7:0];
                end else if (acc==`BUS_ACC_2B) begin // write 2B
                    array[cell_addr][{byte_sel[`BUS_ACC_2B], 3'd0}+:16] <= wdata[15:0];
                end else if (acc==`BUS_ACC_4B) begin // write 4B
                    array[cell_addr] <= wdata;
                end
            end
        end
    end
endmodule
