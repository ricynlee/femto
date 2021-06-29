`include "sim/timescale.vh"

module dff #( // D-type flip-flop
    parameter   WIDTH       = 1,
    parameter   RESET       = "none", // async, sync, none
    parameter   CLEAR       = "none", // async, sync, none
    parameter   VALID       = "none", // async, sync, none
    parameter   INITIALIZER = 0 // reset value
)(
    input wire              clk,
    input wire              rstn,
    input wire              clr,
    input wire              vld,
    input wire [WIDTH-1:0]  in,
    output wire [WIDTH-1:0] out
);
    reg [WIDTH-1:0] d;

    generate
        if (RESET=="none" && CLEAR=="none" && VALID=="none") begin
            always @ (posedge clk) begin
                d <= in;
            end
            assign out = d;
        end else if (RESET=="none" && CLEAR=="none" && VALID=="sync") begin
            always @ (posedge clk) begin
                if(vld) d <= in;
            end
            assign out = d;
        end else if (RESET=="none" && CLEAR=="none" && VALID=="async") begin
            always @ (posedge clk) begin
                if(vld) d <= in;
            end
            assign out = vld ? in : d;
        end else if (RESET=="none" && CLEAR=="sync" && VALID=="none") begin
            always @ (posedge clk) begin
                if(clr)
                    d <= {WIDTH{1'b0}};
                else
                    d <= in;
            end
            assign out = d;
        end else if (RESET=="none" && CLEAR=="sync" && VALID=="sync") begin
            always @ (posedge clk) begin
                if(clr)
                    d <= {WIDTH{1'b0}};
                else if(vld)
                    d <= in;
            end
            assign out = d;
        end else if (RESET=="none" && CLEAR=="sync" && VALID=="async") begin
            always @ (posedge clk) begin
                if(clr)
                    d <= {WIDTH{1'b0}};
                else if(vld)
                    d <= in;
            end
            assign out = vld ? in : d;
        end else if (RESET=="none" && CLEAR=="async" && VALID=="none") begin
            always @ (posedge clk) begin
                if(clr)
                    d <= {WIDTH{1'b0}};
                else
                    d <= in;
            end
            assign out = clr ? {WIDTH{1'b0}} : d;
        end else if (RESET=="none" && CLEAR=="async" && VALID=="sync") begin
            always @ (posedge clk) begin
                if(clr)
                    d <= {WIDTH{1'b0}};
                else if(vld)
                    d <= in;
            end
            assign out = clr ? {WIDTH{1'b0}} : d;
        end else if (RESET=="none" && CLEAR=="async" && VALID=="async") begin
            always @ (posedge clk) begin
                if(clr)
                    d <= {WIDTH{1'b0}};
                else if(vld)
                    d <= in;
            end
            assign out = clr ? {WIDTH{1'b0}} : (vld ? in : d);
        end else if (RESET=="sync" && CLEAR=="none" && VALID=="none") begin
            always @ (posedge clk) begin
                if(rstn)
                    d <= in;
                else
                    d <= INITIALIZER;
            end
            assign out = d;
        end else if (RESET=="sync" && CLEAR=="none" && VALID=="sync") begin
            always @ (posedge clk) begin
                if(rstn) begin
                    if(vld) d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = d;
        end else if (RESET=="sync" && CLEAR=="none" && VALID=="async") begin
            always @ (posedge clk) begin
                if(rstn) begin
                    if(vld) d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = vld ? in : d;
        end else if (RESET=="sync" && CLEAR=="sync" && VALID=="none") begin
            always @ (posedge clk) begin
                if(rstn) begin
                    if(clr)
                        d <= {WIDTH{1'b0}};
                    else
                        d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = d;
        end else if (RESET=="sync" && CLEAR=="sync" && VALID=="sync") begin
            always @ (posedge clk) begin
                if(rstn) begin
                    if(clr)
                        d <= {WIDTH{1'b0}};
                    else if(vld)
                        d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = d;
        end else if (RESET=="sync" && CLEAR=="sync" && VALID=="async") begin
            always @ (posedge clk) begin
                if(rstn) begin
                    if(clr)
                        d <= {WIDTH{1'b0}};
                    else if(vld)
                        d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = vld ? in : d;
        end else if (RESET=="sync" && CLEAR=="async" && VALID=="none") begin
            always @ (posedge clk) begin
                if(rstn) begin
                    if(clr)
                        d <= {WIDTH{1'b0}};
                    else
                        d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = clr ? {WIDTH{1'b0}} : d;
        end else if (RESET=="sync" && CLEAR=="async" && VALID=="sync") begin
            always @ (posedge clk) begin
                if(rstn) begin
                    if(clr)
                        d <= {WIDTH{1'b0}};
                    else if(vld)
                        d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = clr ? {WIDTH{1'b0}} : d;
        end else if (RESET=="sync" && CLEAR=="async" && VALID=="async") begin
            always @ (posedge clk) begin
                if(rstn) begin
                    if(clr)
                        d <= {WIDTH{1'b0}};
                    else if(vld)
                        d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = clr ? {WIDTH{1'b0}} : (vld ? in : d);
        end else if (RESET=="async" && CLEAR=="none" && VALID=="none") begin
            always @ (posedge clk, negedge rstn) begin
                if(rstn)
                    d <= in;
                else
                    d <= INITIALIZER;
            end
            assign out = d;
        end else if (RESET=="async" && CLEAR=="none" && VALID=="sync") begin
            always @ (posedge clk, negedge rstn) begin
                if(rstn) begin
                    if(vld) d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = d;
        end else if (RESET=="async" && CLEAR=="none" && VALID=="async") begin
            always @ (posedge clk, negedge rstn) begin
                if(rstn) begin
                    if(vld) d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = rstn ? (vld ? in : d) : INITIALIZER;
        end else if (RESET=="async" && CLEAR=="sync" && VALID=="none") begin
            always @ (posedge clk, negedge rstn) begin
                if(rstn) begin
                    if(clr)
                        d <= {WIDTH{1'b0}};
                    else
                        d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = d;
        end else if (RESET=="async" && CLEAR=="sync" && VALID=="sync") begin
            always @ (posedge clk, negedge rstn) begin
                if(rstn) begin
                    if(clr)
                        d <= {WIDTH{1'b0}};
                    else if(vld)
                        d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = d;
        end else if (RESET=="async" && CLEAR=="sync" && VALID=="async") begin
            always @ (posedge clk, negedge rstn) begin
                if(rstn) begin
                    if(clr)
                        d <= {WIDTH{1'b0}};
                    else if(vld)
                        d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = rstn ? (vld ? in : d) : INITIALIZER;
        end else if (RESET=="async" && CLEAR=="async" && VALID=="none") begin
            always @ (posedge clk, negedge rstn) begin
                if(rstn) begin
                    if(clr)
                        d <= {WIDTH{1'b0}};
                    else
                        d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = rstn ? (clr ? {WIDTH{1'b0}} : d) : INITIALIZER;
        end else if (RESET=="async" && CLEAR=="async" && VALID=="sync") begin
            always @ (posedge clk, negedge rstn) begin
                if(rstn) begin
                    if(clr)
                        d <= {WIDTH{1'b0}};
                    else if(vld)
                        d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = rstn ? (clr ? {WIDTH{1'b0}} : d) : INITIALIZER;
        end else if (RESET=="async" && CLEAR=="async" && VALID=="async") begin
            always @ (posedge clk, negedge rstn) begin
                if(rstn) begin
                    if(clr)
                        d <= {WIDTH{1'b0}};
                    else if(vld)
                        d <= in;
                end else
                    d <= INITIALIZER;
            end
            assign out = rstn ? (clr ? {WIDTH{1'b0}} : (vld ? in : d)) : INITIALIZER;
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
