`include "timescale.vh"

module dff_srcv #( // D-type flip-flop w/ sync rst, clr, vld
    parameter   WIDTH = 1,
    parameter   INITV = {WIDTH{1'b0}} // reset value
)(
    input wire              clk,
    input wire              rstn,
    input wire              clr,
    input wire              vld,
    input wire [WIDTH-1:0]  in,
    output wire [WIDTH-1:0] out
);
    reg [WIDTH-1:0] d = INTV;

    always_ff @ (posedge clk) begin
        if (~rstn)
            d <= INTV;
        else if (clr)
            d <= {WIDTH{1'b0}};
        else if (vld)
            d <= in;
    end
    assign out = d;
endmodule

module dff_ar_scv #( // D-type flip-flop w/ async rst & sync clr, vld
    parameter   WIDTH = 1,
    parameter   INITV = {WIDTH{1'b0}} // reset value
)(
    input wire              clk,
    input wire              rstn,
    input wire              clr,
    input wire              vld,
    input wire [WIDTH-1:0]  in,
    output wire [WIDTH-1:0] out
);
    reg [WIDTH-1:0] d = INTV;

    always_ff @ (posedge clk, negedge rstn) begin
        if (~rstn)
            d <= INTV;
        else if (clr)
            d <= {WIDTH{1'b0}};
        else
            d <= in;
    end
    assign out = d;
endmodule

module dff_arc_sv #( // D-type flip-flop w/ async rst, clr & sync vld
    parameter   WIDTH = 1,
    parameter   INITV = {WIDTH{1'b0}} // reset value
)(
    input wire              clk,
    input wire              rstn,
    input wire              clr,
    input wire              vld,
    input wire [WIDTH-1:0]  in,
    output wire [WIDTH-1:0] out
);
    reg [WIDTH-1:0] d = INTV;

    always_ff @ (posedge clk, negedge rstn, posedge clr) begin
        if (~rstn)
            d <= INTV;
        else if (clr)
            d <= {WIDTH{1'b0}};
        else
            d <= in;
    end
    assign out = d;
endmodule

module fifo # ( // fully sync, first-word-fall-through
    parameter   WIDTH = 1,
    parameter   DEPTH = 16, // 2's positive exponent
    parameter   CLEAR = "none" // none, sync
)(
    input wire  clk,
    input wire  rstn,

    input wire [WIDTH-1:0]  din,
    output wire [WIDTH-1:0] dout,

    input wire  w,
    input wire  r,

    output reg  full,
    output wire almost_full,
    output reg  empty,
    output wire almost_empty,

    input wire  clr
);
    localparam PTR_BITS = $clog2(DEPTH);

    reg [WIDTH-1:0] array[0:DEPTH-1];

    reg [PTR_BITS-1:0]  wptr,
                        rptr;
    wire [PTR_BITS-1:0] next_wptr = wptr+1'b1,
                        next_rptr = rptr+1'b1;

    assign almost_empty = (next_rptr == wptr);
    assign almost_full = (next_wptr == rptr);

    assign dout = array[rptr];

    wire _clr;

    generate
        if (CLEAR=="sync") begin
            assign _clr = clr;
        end else begin
            assign _clr = 1'b0;
        end
    endgenerate

    integer elem_cnt;

    always @ (posedge clk) begin
        if (rstn==0) begin
            wptr <= 0;
            rptr <= 0;
            full <= 0;
            empty <= 1;
            elem_cnt <= 0;
        end else if (_clr) begin
            wptr <= rptr;
            full <= 0;
            empty <= 1;
            elem_cnt <= 0;
        end else case ({w, r, full, empty})
            4'b1001: begin
                array[wptr]<=din;
                wptr <= next_wptr;
                empty <= 0;
                elem_cnt <= elem_cnt+1;
            end
            4'b1000: begin
                array[wptr]<=din;
                wptr <= next_wptr;
                if (almost_full) begin
                    full <= 1;
                end
                elem_cnt <= elem_cnt+1;
            end
            4'b0110: begin
                rptr <= next_rptr;
                full <= 0;
                elem_cnt <= elem_cnt-1;
            end
            4'b0100: begin
                rptr <= next_rptr;
                if (almost_empty) begin
                    empty <= 1;
                end
                elem_cnt <= elem_cnt-1;
            end
            4'b1100, 4'b1101, 4'b1110: begin
                rptr <= next_rptr;
                array[wptr]<=din;
                wptr <= next_wptr;
            end
            // default: // doing nothing
        endcase
    end
endmodule
