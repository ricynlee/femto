module csregfile(
    input wire             clk,

    input wire             wreq,
    input wire[3:0]        windex,
    input wire[`XLEN-1:0]  wdata,

    output wire[`XLEN-1:0] csr[0:15]
);

    reg[`XLEN-1:0] csreg[0:15];
    generate
        for (genvar i=0; i<16; i=i+1) begin
            assign csr[i] = csreg[i];
        end
    endgenerate

    always @ (posedge clk) begin
        if (wreq && windex) begin
            csreg[windex] <= wdata;
        end
    end
endmodule
