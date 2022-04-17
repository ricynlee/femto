
module splitter # (
    parameter WIDTH = 10
) (
    input wire[WIDTH-1:0] i,
    output wire o0,
    output wire o1,
    output wire o2,
    output wire o3,
    output wire o4,
    output wire o5,
    output wire o6,
    output wire o7,
    output wire o8,
    output wire o9
);

    assign o0 = i[0];
    assign o1 = i[1];
    assign o2 = i[2];
    assign o3 = i[3];
    assign o4 = i[4];
    assign o5 = i[5];
    assign o6 = i[6];
    assign o7 = i[7];
    assign o8 = i[8];
    assign o9 = i[9];

endmodule
