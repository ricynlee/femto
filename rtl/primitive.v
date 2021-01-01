`include "sim/timescale.vh"

module keeper # (
    parameter   WIDTH       = 32,
    parameter   INITIALIZER = 0
)(
    input wire  clk,
    input wire  rstn,
    // Input
    input wire              vld,
    input wire [WIDTH-1:0]  in,
    // Output
    output wire [WIDTH-1:0] out
);
    reg [WIDTH-1:0] keeper_reg;
    always @ (posedge clk) begin
        if (rstn==0) begin
            keeper_reg <= INITIALIZER;
        end else if(vld) begin
            keeper_reg <= in;
        end
    end

    assign out = vld ? in : keeper_reg;
endmodule

module dff #( // D-type flip-flop
    parameter   WIDTH       = 1,
    parameter   INITIALIZER = 0,
    parameter   VALID       = "none", // sync, none
    parameter   RESET       = "sync", // async, sync, none
    parameter   CLEAR       = "async" // async, sync, none
)(
    input wire              clk,
    input wire              rstn,
    input wire              clr,
    input wire              vld,
    input wire [WIDTH-1:0]  in,
    output wire [WIDTH-1:0] out
);
    reg [WIDTH-1:0] d;
    wire _clr;
    wire [WIDTH-1:0] _in;

    generate
        if (CLEAR=="none") begin
            assign _clr = 0;
        end else begin
            assign _clr = clr;
        end

        if (VALID=="none")begin
            assign _in = in;
        end else begin
            assign _in = vld ? in : d;
        end

        if (RESET=="sync") begin
            always @ (posedge clk) begin
                if (rstn==0) begin
                    d <= INITIALIZER;
                end else if (_clr) begin
                    d <= {WIDTH{1'b0}};
                end else begin
                    d <= _in;
                end
            end
        end else if (RESET=="async") begin
            always @ (posedge clk, negedge rstn) begin
                if (rstn==0) begin
                    d <= INITIALIZER;
                end else if (_clr) begin
                    d <= {WIDTH{1'b0}};
                end else begin
                    d <= _in;
                end
            end
        end else begin
            always @ (posedge clk) begin
                if (_clr) begin
                    d <= {WIDTH{1'b0}};
                end else begin
                    d <= _in;
                end
            end
        end

        if (CLEAR=="async") begin
            assign out = _clr ? {WIDTH{1'b0}} : d;
        end else begin
            assign out = d;
        end
    endgenerate
endmodule

module fifo # (
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

    always @ (posedge clk) begin
        if (rstn==0) begin
            wptr <= 0;
            rptr <= 0;
            full <= 0;
            empty <= 1;
        end else if (_clr) begin
            wptr <= rptr;
            full <= 0;
            empty <= 1;
        end else case ({w, r, full, empty})
            4'b1001: begin
                array[wptr]<=din;
                wptr <= next_wptr;
                empty <= 0;
            end
            4'b1000: begin
                array[wptr]<=din;
                wptr <= next_wptr;
                if (almost_full) begin
                    full <= 1;
                end
            end
            4'b0110: begin
                rptr <= next_rptr;
                full <= 0;
            end
            4'b0100: begin
                rptr <= next_rptr;
                if (almost_empty) begin
                    empty <= 1;
                end
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

module mask_gen(
    input wire [5:0]    width, // width>32 is seen as 32
    output wire [31:0]  mask
);
    wire [5:0] width_cutoff = {width[5], {5{~width[5]}}} & width;
    wire [32:0] mask_plus_1 = (1<<width);

    assign mask[31] = mask_plus_1[32];
    generate
        for(genvar i=0; i<31; i=i+1) begin
            assign mask[i] = mask_plus_1[i+1] | mask[i+1];
        end
    endgenerate
endmodule
