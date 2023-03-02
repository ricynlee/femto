`include "timescale.vh"
`include "femto.vh"

module ibus_conn # (
    parameter ROM_BASE = `ROM_BASE,
    parameter ROM_SPAN = $clog2(`ROM_SIZE),
    parameter DBGTCM_BASE = `DBGTCM_BASE,
    parameter DBGTCM_SPAN = $clog2(`DBGTCM_SIZE),
    parameter TCM_BASE = `TCM_BASE,
    parameter TCM_SPAN = $clog2(`TCM_SIZE),
    parameter SRAM_BASE = `SRAM_BASE,
    parameter SRAM_SPAN = $clog2(`SRAM_SIZE),
    parameter NOR_BASE = `NOR_BASE,
    parameter NOR_SPAN = $clog2(`NOR_SIZE)
) (
    input wire clk,

    input wire m_req,
    input wire[`XLEN-1:0] m_addr,
    input wire m_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] m_acc,
    input wire[`BUS_WIDTH-1:0] m_wdata,
    output wire m_resp,
    output wire[`BUS_WIDTH-1:0] m_rdata,

    output wire s_rom_req,
    output wire[`XLEN-1:0] s_rom_addr,
    output wire s_rom_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_rom_acc,
    output wire[`BUS_WIDTH-1:0] s_rom_wdata,
    input wire s_rom_resp,
    input wire[`BUS_WIDTH-1:0] s_rom_rdata,

    output wire s_dbgtcm_req,
    output wire[`XLEN-1:0] s_dbgtcm_addr,
    output wire s_dbgtcm_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_dbgtcm_acc,
    output wire[`BUS_WIDTH-1:0] s_dbgtcm_wdata,
    input wire s_dbgtcm_resp,
    input wire[`BUS_WIDTH-1:0] s_dbgtcm_rdata,

    output wire s_tcm_req,
    output wire[`XLEN-1:0] s_tcm_addr,
    output wire s_tcm_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_tcm_acc,
    output wire[`BUS_WIDTH-1:0] s_tcm_wdata,
    input wire s_tcm_resp,
    input wire[`BUS_WIDTH-1:0] s_tcm_rdata,

    output wire s_sram_req,
    output wire[`XLEN-1:0] s_sram_addr,
    output wire s_sram_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_sram_acc,
    output wire[`BUS_WIDTH-1:0] s_sram_wdata,
    input wire s_sram_resp,
    input wire[`BUS_WIDTH-1:0] s_sram_rdata,

    output wire s_nor_req,
    output wire[`XLEN-1:0] s_nor_addr,
    output wire s_nor_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_nor_acc,
    output wire[`BUS_WIDTH-1:0] s_nor_wdata,
    input wire s_nor_resp,
    input wire[`BUS_WIDTH-1:0] s_nor_rdata,

    output wire bus_fault, // no bus slave is selected
    output wire[`XLEN-1:0] bus_fault_addr,
    input wire bus_halt // force halt bus
);
    localparam SLAVE_CNT = 5;

    // req demux
    wire[SLAVE_CNT-1:0] bus_slave_sel;
    assign bus_slave_sel[0] = ((m_addr & ~{{(`XLEN-ROM_SPAN){1'b0}}, {ROM_SPAN{1'b1}}}) == ROM_BASE);
    assign s_rom_req = m_req & bus_slave_sel[0];
    assign s_rom_addr = m_addr;
    assign s_rom_w_rb = m_w_rb;
    assign s_rom_acc = m_acc;
    assign s_rom_wdata = m_wdata;
    assign bus_slave_sel[1] = ((m_addr & ~{{(`XLEN-DBGTCM_SPAN){1'b0}}, {DBGTCM_SPAN{1'b1}}}) == DBGTCM_BASE);
    assign s_dbgtcm_req = m_req & bus_slave_sel[1];
    assign s_dbgtcm_addr = m_addr;
    assign s_dbgtcm_w_rb = m_w_rb;
    assign s_dbgtcm_acc = m_acc;
    assign s_dbgtcm_wdata = m_wdata;
    assign bus_slave_sel[2] = ((m_addr & ~{{(`XLEN-TCM_SPAN){1'b0}}, {TCM_SPAN{1'b1}}}) == TCM_BASE);
    assign s_tcm_req = m_req & bus_slave_sel[2];
    assign s_tcm_addr = m_addr;
    assign s_tcm_w_rb = m_w_rb;
    assign s_tcm_acc = m_acc;
    assign s_tcm_wdata = m_wdata;
    assign bus_slave_sel[3] = ((m_addr & ~{{(`XLEN-SRAM_SPAN){1'b0}}, {SRAM_SPAN{1'b1}}}) == SRAM_BASE);
    assign s_sram_req = m_req & bus_slave_sel[3];
    assign s_sram_addr = m_addr;
    assign s_sram_w_rb = m_w_rb;
    assign s_sram_acc = m_acc;
    assign s_sram_wdata = m_wdata;
    assign bus_slave_sel[4] = ((m_addr & ~{{(`XLEN-NOR_SPAN){1'b0}}, {NOR_SPAN{1'b1}}}) == NOR_BASE);
    assign s_nor_req = m_req & bus_slave_sel[4];
    assign s_nor_addr = m_addr;
    assign s_nor_w_rb = m_w_rb;
    assign s_nor_acc = m_acc;
    assign s_nor_wdata = m_wdata;

    assign bus_fault = m_req & ~|bus_slave_sel;
    assign bus_fault_addr = m_addr;

    // resp mux
    reg[`BUS_WIDTH-1:0] m_rdata_latch;
    always @ (posedge clk) begin
        m_rdata_latch <= m_rdata;
    end

    assign m_rdata =
        s_rom_resp ? s_rom_rdata :
        s_dbgtcm_resp ? s_dbgtcm_rdata :
        s_tcm_resp ? s_tcm_rdata :
        s_sram_resp ? s_sram_rdata :
        s_nor_resp ? s_nor_rdata :
        /* otherwise */ m_rdata_latch;

    assign m_resp = ~bus_halt & |{s_rom_resp, s_dbgtcm_resp, s_tcm_resp, s_sram_resp, s_nor_resp};
endmodule