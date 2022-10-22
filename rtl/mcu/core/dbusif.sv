module dbusif (
    input clk,
    input rstn,

    // processor interface
    input wire       acc_req, // (data) access, pipeline ensures no overlapping reqs
    input wire       acc_w_rb,
    input wire[1:0]  acc_size,
    input wire[31:0] acc_addr,
    input wire[31:0] acc_wdata,
    
    output wire       data_vld, // r/w access done
    output wire[31:0] data,
    output wire       data_has_fault, // resp's correspoding acess

    // bus interface (ahblite-like)
    output wire [31:0] haddr,
    output wire        hprot,   // data/instruction access indicator
    output wire [ 1:0] hsize,
    output wire        hwrite,
    output wire [31:0] hwdata,
    output wire        htrans,  // indicate whether the transfer is valid, bit 1 of AHB HTRANS
    input  wire [31:0] hrdata,
    input  wire        hresp,
    input  wire        hready
);
    assign haddr = acc_addr;
    assign hprot = 1'b1; // always set "data access"
    assign hsize = acc_size;
    assign hwrite = acc_w_rb;
    assign htrans = acc_req;

    assign hwdata = acc_wdata; // pipeline ensures: one clk later than acc_req

    assign data = hrdata;
    assign data_has_fault = hresp;

    generate
        if (1) begin : GEN_data_vld
            wire prev_trans_req_vld;
            dff prev_trans_req_vld_dff (
                .clk (clk),
                .rstn(rstn),
                .set (htrans),
                .setv(1'b1),
                .vld (hready),
                .in  (1'b0),
                .out (prev_trans_req_vld)
            );
            assign data_vld = hready & prev_trans_req_vld;
        end
    endgenerate
endmodule
