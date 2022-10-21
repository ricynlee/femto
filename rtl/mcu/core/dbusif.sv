
module dbusif (
    input clk,
    input rstn,
    // processor interface
    input wire       acc_req, // (data) access
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

endmodule
