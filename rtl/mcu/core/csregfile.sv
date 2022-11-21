`include "core.vh"

// defined in core.vh
// CSR_IDX_MSTATUS 4'b0000  0
// CSR_IDX_MEPC    4'b0001  1
// CSR_IDX_MCAUSE  4'b0010  2
// CSR_IDX_MTVAL   4'b0011  3
// CSR_IDX_MIP     4'b0100  4
// CSR_IDX_MTVEC   4'b0101  5
// CSR_IDX_TDATA1  4'b1001  9
// CSR_IDX_TDATA2  4'b1010 10
// CSR_IDX_DCSR    4'b1100 12
// CSR_IDX_DPC     4'b1101 13

module csregfile (
    input wire clk,
    input wire rstn,

    input wire        wreq,
    input wire [ 3:0] windex,
    input wire [31:0] wdata,

    output wire [31:0] csr[0:15],

    input wire ext_int_req
);

    wire mip_MEIP;

    assign mip_MEIP         = ext_int_req;

    assign csr[CSR_IDX_MIP] = {4'd0, mip_MEIP, 27'd0}; // MEIE not implemented

    always_ff @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            mstatus_MIE <= `RESET_IE;
        end
    end
endmodule
