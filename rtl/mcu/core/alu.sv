module alu(
    input wire  clk,
    input wire rstn,
    input wire[7:0]        op,
    input wire[`XLEN-1:0]  a,
    input wire[`XLEN-1:0]  b,
    output wire[`XLEN-1:0] r,
    output wire bsy
);
    localparam SHIFTWIDTH = $clog2(`XLEN);
    wire[SHIFTWIDTH-1:0] shift = b[SHIFTWIDTH-1:0];

    `include "core.vh"

    assign r =
        op==ALU_ZERO ? ({`XLEN{1'b0}}        ):
        op==ALU_SUB  ? (a-b                  ):
        op==ALU_AND  ? (a&b                  ):
        op==ALU_OR   ? (a|b                  ):
        op==ALU_CLR  ? (a & ~b               ):
        op==ALU_XOR  ? (a^b                  ):
        op==ALU_LTU  ? (a<b                  ):
        op==ALU_LT   ? ($signed(a)<$signed(b)):
        op==ALU_SRL  ? (a>>shift             ):
        op==ALU_SRA  ? ($signed(a)>>>shift   ):
        op==ALU_SL   ? (a<<shift             ):
        /* ALU_ADD */ (a+b                  );
        
    assign bsy = 1'b0;
endmodule


