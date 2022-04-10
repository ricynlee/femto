`include "timescale.vh"
`include "femto.vh"

module ibus_conn # (
    parameter SLAVE_CNT = 4,
    parameter rom_BASE = 32'h00000000,
    parameter rom_SPAN = 12,
    parameter tcm_BASE = 32'h10000000,
    parameter tcm_SPAN = 12,
    parameter sram_BASE = 32'h20000000,
    parameter sram_SPAN = 19,
    parameter nor_BASE = 32'h30000000,
    parameter nor_SPAN = 24
) (
    input wire clk,
    input wire rstn,

    input wire m_req,
    input wire[`XLEN-1:0] m_addr,
    input wire m_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] m_acc,
    input wire[`BUS_WIDTH-1:0] m_wdata,
    output wire m_resp,
    output reg[`BUS_WIDTH-1:0] m_rdata,
    output wire m_fault, // fault indicator from submodule

    output wire s_rom_req,
    output wire[rom_SPAN-1:0] s_rom_addr,
    output wire s_rom_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_rom_acc,
    output wire[`BUS_WIDTH-1:0] s_rom_wdata,
    input wire s_rom_resp,
    input wire[`BUS_WIDTH-1:0] s_rom_rdata,
    input wire s_rom_fault,

    output wire s_tcm_req,
    output wire[tcm_SPAN-1:0] s_tcm_addr,
    output wire s_tcm_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_tcm_acc,
    output wire[`BUS_WIDTH-1:0] s_tcm_wdata,
    input wire s_tcm_resp,
    input wire[`BUS_WIDTH-1:0] s_tcm_rdata,
    input wire s_tcm_fault,

    output wire s_sram_req,
    output wire[sram_SPAN-1:0] s_sram_addr,
    output wire s_sram_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_sram_acc,
    output wire[`BUS_WIDTH-1:0] s_sram_wdata,
    input wire s_sram_resp,
    input wire[`BUS_WIDTH-1:0] s_sram_rdata,
    input wire s_sram_fault,

    output wire s_nor_req,
    output wire[nor_SPAN-1:0] s_nor_addr,
    output wire s_nor_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_nor_acc,
    output wire[`BUS_WIDTH-1:0] s_nor_wdata,
    input wire s_nor_resp,
    input wire[`BUS_WIDTH-1:0] s_nor_rdata,
    input wire s_nor_fault,

    output wire bus_fault // no bus slave is selected
);
    // req demux
    wire[SLAVE_CNT-1:0] bus_slave_sel;
    assign bus_slave_sel[0] = ((m_addr & ~{{`XLEN-rom_SPAN{1'b0}}, {rom_SPAN{1'b1}}}) == rom_BASE);
    assign s_rom_req = m_req & bus_slave_sel[0];
    assign s_rom_addr = m_addr[rom_SPAN-1:0];
    assign s_rom_w_rb = m_w_rb;
    assign s_rom_acc = m_acc;
    assign s_rom_wdata = m_wdata;
    assign bus_slave_sel[1] = ((m_addr & ~{{`XLEN-tcm_SPAN{1'b0}}, {tcm_SPAN{1'b1}}}) == tcm_BASE);
    assign s_tcm_req = m_req & bus_slave_sel[1];
    assign s_tcm_addr = m_addr[tcm_SPAN-1:0];
    assign s_tcm_w_rb = m_w_rb;
    assign s_tcm_acc = m_acc;
    assign s_tcm_wdata = m_wdata;
    assign bus_slave_sel[2] = ((m_addr & ~{{`XLEN-sram_SPAN{1'b0}}, {sram_SPAN{1'b1}}}) == sram_BASE);
    assign s_sram_req = m_req & bus_slave_sel[2];
    assign s_sram_addr = m_addr[sram_SPAN-1:0];
    assign s_sram_w_rb = m_w_rb;
    assign s_sram_acc = m_acc;
    assign s_sram_wdata = m_wdata;
    assign bus_slave_sel[3] = ((m_addr & ~{{`XLEN-nor_SPAN{1'b0}}, {nor_SPAN{1'b1}}}) == nor_BASE);
    assign s_nor_req = m_req & bus_slave_sel[3];
    assign s_nor_addr = m_addr[nor_SPAN-1:0];
    assign s_nor_w_rb = m_w_rb;
    assign s_nor_acc = m_acc;
    assign s_nor_wdata = m_wdata;

    assign bus_fault = m_req & ~|bus_slave_sel;

    // resp mux
    always @ (*) begin
        if (s_rom_resp) m_rdata = s_rom_rdata;
        else if (s_tcm_resp) m_rdata = s_tcm_rdata;
        else if (s_sram_resp) m_rdata = s_sram_rdata;
        else m_rdata = s_nor_rdata;
    end

    assign m_resp = |{s_rom_resp, s_tcm_resp, s_sram_resp, s_nor_resp};
    assign m_fault = |{s_rom_fault, s_tcm_fault, s_sram_fault, s_nor_fault};
endmodule
