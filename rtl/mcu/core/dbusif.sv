module dbusif (
    input clk,
    input rstn,

    // processor interface
    input wire       data_req, // data access, pipeline ensures no overlapping reqs
    input wire       data_w_rb,
    input wire[1:0]  data_size,
    input wire[31:0] data_addr,
    input wire[31:0] data_wd, // write data
    output wire[31:0] data_rd, // read data
    output wire       data_done, // r/w access done
    output wire       data_err, // bus access has error

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
    assign haddr = data_addr;
    assign hprot = 1'b1; // always set "data access"
    assign hsize = data_size;
    assign hwrite = data_w_rb;
    assign htrans = data_req;

    assign hwdata = data_wd; // pipeline ensures: one clk later than data_req

    assign data_rd = hrdata;
    assign data_err = hresp;

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
            assign data_done = hready & prev_trans_req_vld;
        end
    endgenerate
endmodule
