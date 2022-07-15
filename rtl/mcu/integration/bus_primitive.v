`include "timescale.vh"
`include "femto.vh"

module bus_bridge (
    input wire clk,
    input wire rstn,

    input wire[`XLEN-1:0]                d_addr,
    input wire                           d_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] d_acc,
    input wire[`BUS_WIDTH-1:0]           d_wdata,
    input wire                           d_req,
    output reg                           d_resp,
    output reg[`BUS_WIDTH-1:0]           d_rdata,

    output reg[`XLEN-1:0]                p_addr,
    output reg                           p_w_rb,
    output reg[$clog2(`BUS_ACC_CNT)-1:0] p_acc,
    output reg[`BUS_WIDTH-1:0]           p_wdata,
    output reg                           p_req,
    input wire                           p_resp,
    input wire[`BUS_WIDTH-1:0]           p_rdata
);
    always @ (posedge clk) begin
        if (~rstn) begin
            d_resp <= 1'b0;
            p_req <= 1'b0;
        end else begin
            p_req <= d_req;
            p_addr <= d_addr;
            p_w_rb <= d_w_rb;
            p_acc <= d_acc;
            p_wdata <= d_wdata;
            d_resp <= p_resp;
            d_rdata <= p_rdata;
        end
    end
endmodule

module bus_duplexer(
    input wire  clk,
    input wire  rstn,

    // data bus interface
    input wire[`XLEN-1:0]                d_addr, // byte addr
    input wire                           d_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] d_acc,
    output reg[`BUS_WIDTH-1:0]           d_rdata,
    input wire[`BUS_WIDTH-1:0]           d_wdata,
    input wire                           d_req,
    output reg                           d_resp,
    output reg                           periph_d_fault,

    // instruction bus interface
    input wire[`XLEN-1:0]                i_addr, // byte addr
    input wire                           i_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] i_acc,
    output reg[`BUS_WIDTH-1:0]           i_rdata,
    input wire[`BUS_WIDTH-1:0]           i_wdata,
    input wire                           i_req,
    output reg                           i_resp,
    output reg                           periph_i_fault,

    // memory bus interface
    output reg[`XLEN-1:0]                addr, // byte addr
    output reg                           w_rb,
    output reg[$clog2(`BUS_ACC_CNT)-1:0] acc,
    input wire[`BUS_WIDTH-1:0]           rdata,
    output reg[`BUS_WIDTH-1:0]           wdata,
    output reg                           req,
    input wire                           resp,
    input wire                           fault
);
    wire[`XLEN-1:0]                i_req_addr;
    wire                           i_req_w_rb;
    wire[$clog2(`BUS_ACC_CNT)-1:0] i_req_acc;
    wire[`BUS_WIDTH-1:0]           i_req_wdata;
    dff #(
        .WIDTH(`XLEN+$clog2(`BUS_ACC_CNT)+`BUS_WIDTH),
        .VALID("async")
    ) i_req_info_dff (
        .clk(clk                                 ),
        .vld(i_req                               ),
        .in ({i_addr, i_acc, i_wdata}            ),
        .out({i_req_addr, i_req_acc, i_req_wdata})
    );
    assign  i_req_w_rb=1'b0;

    wire[`XLEN-1:0]                d_req_addr;
    wire                           d_req_w_rb;
    wire[$clog2(`BUS_ACC_CNT)-1:0] d_req_acc;
    wire[`BUS_WIDTH-1:0]           d_req_wdata;
    dff #(
        .WIDTH(`XLEN+1+$clog2(`BUS_ACC_CNT)+`BUS_WIDTH),
        .VALID("async")
    ) d_req_info_dff (
        .clk(clk                                             ),
        .vld(d_req                                           ),
        .in ({d_addr, d_w_rb, d_acc, d_wdata}                ),
        .out({d_req_addr, d_req_w_rb, d_req_acc, d_req_wdata})
    );

    // state control
    wire i_access_ongoing;
    dff #(
        .VALID("sync"),
        .RESET("sync")
    ) i_req_dff (
        .clk (clk             ),
        .rstn(rstn            ),
        .vld (i_req | i_resp  ),
        .in  (i_req           ),
        .out (i_access_ongoing)
    );

    wire d_access_ongoing;
    dff #(
        .VALID("sync"),
        .RESET("sync")
    ) d_req_dff (
        .clk (clk                 ),
        .rstn(rstn                ),
        .vld (d_req | d_resp),
        .in  (d_req            ),
        .out (d_access_ongoing )
    );

    localparam N = 0,
               I = 1,
               D = 2;
    reg[7:0] state, next_state;
    always @ (posedge clk) begin
        if (~rstn) begin
            state <= N;
        end else begin
            state <= next_state;
        end
    end

    always @ (*) case (state)
        default:
            if (d_req)
                next_state = D;
            else if (i_req)
                next_state = I;
            else
                next_state = N;
        I:
            if (~resp)
                next_state = I;
            else if (d_req | d_access_ongoing)
                next_state = D;
            else if (i_req)
                next_state = I;
            else
                next_state = N;
        D:
            if (~resp)
                next_state = D;
            else if (i_req | i_access_ongoing)
                next_state = I;
            else if (d_req)
                next_state = D;
            else
                next_state = N;
    endcase

    // signal dispatcher
    always @ (*) case (state)
        default: req = i_req | d_req;
        I:       req = resp & (d_req | d_access_ongoing | i_req);
        D:       req = resp & (i_req | i_access_ongoing | d_req);
    endcase

    always @ (*) case (next_state) // req operation (combinatorial fault operation)
        default: begin
            addr = {`XLEN{1'bx}};
            w_rb = 1'bx;
            acc = {$clog2(`BUS_ACC_CNT){1'bx}};
            wdata = {`BUS_WIDTH{1'bx}};
            periph_d_fault = 1'b0;
            periph_i_fault = 1'b0;
        end
        I: begin
            addr = i_req_addr;
            w_rb = i_req_w_rb;
            acc = i_req_acc;
            wdata = i_req_wdata;
            periph_d_fault = 1'b0;
            periph_i_fault = fault;
        end
        D: begin
            addr = d_req_addr;
            w_rb = d_req_w_rb;
            acc = d_req_acc;
            wdata = d_req_wdata;
            periph_d_fault = fault;
            periph_i_fault = 1'b0;
        end
    endcase

    always @ (*) case (state) // resp operation
        default: begin
            d_resp = 1'b0;
            d_rdata = {`BUS_WIDTH{1'bx}};
            i_resp = 1'b0;
            i_rdata = {`BUS_WIDTH{1'bx}};
        end
        I: begin
            d_resp = 1'b0;
            d_rdata = {`BUS_WIDTH{1'bx}};
            i_resp = resp;
            i_rdata = rdata;
        end
        D: begin
            d_resp = resp;
            d_rdata = rdata;
            i_resp = 1'b0;
            i_rdata = {`BUS_WIDTH{1'bx}};
        end
    endcase
endmodule
