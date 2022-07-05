module dbg_dm (
    input wire clk,
    input wire rstn,

    output wire halt,
    input wire  halted,

    // dbg rom interface
    input wire[$clog2(`DBGTCM_SIZE)-1:0]    rom_addr,
    input wire                              rom_w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]          rom_acc,
    output reg[`BUS_WIDTH-1:0]              rom_rdata,
    input wire[`BUS_WIDTH-1:0]              rom_wdata,
    input wire                              rom_req,
    output reg                              rom_resp,
    output wire                             rom_fault,

    // dbg tcm interface
    input wire[$clog2(`DBGTCM_SIZE)-1:0]    tcm_addr,
    input wire                              tcm_w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]          tcm_acc,
    output reg[`BUS_WIDTH-1:0]              tcm_rdata,
    input wire[`BUS_WIDTH-1:0]              tcm_wdata,
    input wire                              tcm_req,
    output reg                              tcm_resp,
    output wire                             tcm_fault,

    // abstract cmd interface
    input wire[$clog2(`ABSCMD_SIZE)-1:0]    cmd_addr,
    input wire                              cmd_w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]          cmd_acc,
    output reg[`BUS_WIDTH-1:0]              cmd_rdata,
    input wire[`BUS_WIDTH-1:0]              cmd_wdata,
    input wire                              cmd_req,
    output reg                              cmd_resp,
    output wire                             cmd_fault
);

endmodule
