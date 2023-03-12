module pipeline_ctrl (
    input wire clk,
    input wire rstn,

    output wire hld,
    output wire jmp,
    
    input wire hld_req, // hold req pulse from stage id
    input wire run_req, // release req pulse from stage ex
    
    input wire jmp_req // jump req pulse from stage ex
);

    generate
        if (1) begin: GEN_hld
            wire hld_dff_out;
            dff pipeline_hld_dff (
                .clk (clk),
                .rstn(rstn),
                .set (hld_req),
                .setv(1'b1),
                .vld (run_req),
                .in  (1'b0),
                .out (hld_dff_out)
            );
            assign hld = hld_dff_out & ~run_req;
        end
    endgenerate

    generate
        if (1) begin: GEN_jmp
            assign jmp = jmp_req;
        end
    endgenerate

endmodule
