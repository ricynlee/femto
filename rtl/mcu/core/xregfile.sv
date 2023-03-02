module xregfile(
    input wire             clk,

    input wire             wreq,
    input wire[3:0]        windex,
    input wire[31:0]  wdata,

    output wire[31:0] x[0:15]
);

    reg[`XLEN-1:0] xr[1:15];
    assign x[0]  = 32'd0;
    generate
        for (genvar i=1 /*not 0*/; i<16; i=i+1) begin
            assign x[i] = xr[i];
        end
    endgenerate

    always @ (posedge clk) begin
        if (wreq && windex) begin
            xr[windex] <= wdata;
        end
    end
endmodule
