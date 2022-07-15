
module merger # (
    parameter WIDTH = 2
) (
    input wire i0,
    input wire i1,
    output wire[WIDTH-1:0] o
);

    assign o[0] = i0;
    assign o[1] = i1;

endmodule
