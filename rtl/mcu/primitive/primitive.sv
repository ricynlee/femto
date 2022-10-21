module dff #(  // D-type flip-flop w/ sync rst, set, vld
    parameter WIDTH = 1,
    parameter INITV = {WIDTH{1'b0}}  // reset value
) (
    input  wire             clk,
    input  wire             rstn,
    input  wire             set,
    input  wire             vld,
    input  wire [WIDTH-1:0] setv,
    input  wire [WIDTH-1:0] in,
    output wire [WIDTH-1:0] out
);
    reg [WIDTH-1:0] d = INITV;

    always_ff @(posedge clk) begin
        if (~rstn) d <= INITV;
        else if (set) d <= setv;
        else if (vld) d <= in;
    end
    assign out = d;
endmodule

module fifo #(  // fully sync, first-word-fall-through
    parameter WIDTH = 1,
    parameter DEPTH = 16,     // 2's positive exponent
    parameter CLEAR = "none"  // none, sync
) (
    input wire clk,
    input wire rstn,

    input  wire [WIDTH-1:0] din,
    output wire [WIDTH-1:0] dout,

    input wire w,
    input wire r,

    output reg  full,
    output wire almost_full,
    output reg  empty,
    output wire almost_empty,

    input wire clr
);
    localparam PTR_BITS = $clog2(DEPTH);

    reg [WIDTH-1:0] array[0:DEPTH-1];

    reg [PTR_BITS-1:0] wptr, rptr;
    wire [PTR_BITS-1:0] next_wptr = wptr + 1'b1, next_rptr = rptr + 1'b1;

    assign almost_empty = (next_rptr == wptr);
    assign almost_full  = (next_wptr == rptr);

    assign dout         = array[rptr];

    wire _clr;

    generate
        if (CLEAR == "sync") begin
            assign _clr = clr;
        end else begin
            assign _clr = 1'b0;
        end
    endgenerate

    integer elem_cnt;

    always_ff @(posedge clk) begin
        if (rstn == 0) begin
            wptr     <= 0;
            rptr     <= 0;
            full     <= 0;
            empty    <= 1;
            elem_cnt <= 0;
        end else if (_clr) begin
            wptr     <= rptr;
            full     <= 0;
            empty    <= 1;
            elem_cnt <= 0;
        end else
            case ({
                w, r, full, empty
            })
                4'b1001: begin
                    array[wptr] <= din;
                    wptr        <= next_wptr;
                    empty       <= 0;
                    elem_cnt    <= elem_cnt + 1;
                end
                4'b1000: begin
                    array[wptr] <= din;
                    wptr        <= next_wptr;
                    if (almost_full) begin
                        full <= 1;
                    end
                    elem_cnt <= elem_cnt + 1;
                end
                4'b0110: begin
                    rptr     <= next_rptr;
                    full     <= 0;
                    elem_cnt <= elem_cnt - 1;
                end
                4'b0100: begin
                    rptr <= next_rptr;
                    if (almost_empty) begin
                        empty <= 1;
                    end
                    elem_cnt <= elem_cnt - 1;
                end
                4'b1100, 4'b1101, 4'b1110: begin
                    rptr        <= next_rptr;
                    array[wptr] <= din;
                    wptr        <= next_wptr;
                end
                // default: // doing nothing
            endcase
    end
endmodule
