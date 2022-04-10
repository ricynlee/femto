`include "timescale.vh"
`include "femto.vh"

module pbus_conn # (
    parameter SLAVE_CNT = 5,
    parameter eic_BASE = 32'h80000000,
    parameter eic_SPAN = 2,
    parameter uart_BASE = 32'h90000000,
    parameter uart_SPAN = 2,
    parameter gpio_BASE = 32'ha0000000,
    parameter gpio_SPAN = 3,
    parameter tmr_BASE = 32'hb0000000,
    parameter tmr_SPAN = 3,
    parameter rst_BASE = 32'hf0000000,
    parameter rst_SPAN = 3
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

    output wire s_eic_req,
    output wire[eic_SPAN-1:0] s_eic_addr,
    output wire s_eic_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_eic_acc,
    output wire[`BUS_WIDTH-1:0] s_eic_wdata,
    input wire s_eic_resp,
    input wire[`BUS_WIDTH-1:0] s_eic_rdata,
    input wire s_eic_fault,

    output wire s_uart_req,
    output wire[uart_SPAN-1:0] s_uart_addr,
    output wire s_uart_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_uart_acc,
    output wire[`BUS_WIDTH-1:0] s_uart_wdata,
    input wire s_uart_resp,
    input wire[`BUS_WIDTH-1:0] s_uart_rdata,
    input wire s_uart_fault,

    output wire s_gpio_req,
    output wire[gpio_SPAN-1:0] s_gpio_addr,
    output wire s_gpio_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_gpio_acc,
    output wire[`BUS_WIDTH-1:0] s_gpio_wdata,
    input wire s_gpio_resp,
    input wire[`BUS_WIDTH-1:0] s_gpio_rdata,
    input wire s_gpio_fault,

    output wire s_tmr_req,
    output wire[tmr_SPAN-1:0] s_tmr_addr,
    output wire s_tmr_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_tmr_acc,
    output wire[`BUS_WIDTH-1:0] s_tmr_wdata,
    input wire s_tmr_resp,
    input wire[`BUS_WIDTH-1:0] s_tmr_rdata,
    input wire s_tmr_fault,

    output wire s_rst_req,
    output wire[rst_SPAN-1:0] s_rst_addr,
    output wire s_rst_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_rst_acc,
    output wire[`BUS_WIDTH-1:0] s_rst_wdata,
    input wire s_rst_resp,
    input wire[`BUS_WIDTH-1:0] s_rst_rdata,
    input wire s_rst_fault,

    output wire bus_fault // no bus slave is selected
);
    // req demux
    wire[SLAVE_CNT-1:0] bus_slave_sel;
    assign bus_slave_sel[0] = ((m_addr & ~{{`XLEN-eic_SPAN{1'b0}}, {eic_SPAN{1'b1}}}) == eic_BASE);
    assign s_eic_req = m_req & bus_slave_sel[0];
    assign s_eic_addr = m_addr[eic_SPAN-1:0];
    assign s_eic_w_rb = m_w_rb;
    assign s_eic_acc = m_acc;
    assign s_eic_wdata = m_wdata;
    assign bus_slave_sel[1] = ((m_addr & ~{{`XLEN-uart_SPAN{1'b0}}, {uart_SPAN{1'b1}}}) == uart_BASE);
    assign s_uart_req = m_req & bus_slave_sel[1];
    assign s_uart_addr = m_addr[uart_SPAN-1:0];
    assign s_uart_w_rb = m_w_rb;
    assign s_uart_acc = m_acc;
    assign s_uart_wdata = m_wdata;
    assign bus_slave_sel[2] = ((m_addr & ~{{`XLEN-gpio_SPAN{1'b0}}, {gpio_SPAN{1'b1}}}) == gpio_BASE);
    assign s_gpio_req = m_req & bus_slave_sel[2];
    assign s_gpio_addr = m_addr[gpio_SPAN-1:0];
    assign s_gpio_w_rb = m_w_rb;
    assign s_gpio_acc = m_acc;
    assign s_gpio_wdata = m_wdata;
    assign bus_slave_sel[3] = ((m_addr & ~{{`XLEN-tmr_SPAN{1'b0}}, {tmr_SPAN{1'b1}}}) == tmr_BASE);
    assign s_tmr_req = m_req & bus_slave_sel[3];
    assign s_tmr_addr = m_addr[tmr_SPAN-1:0];
    assign s_tmr_w_rb = m_w_rb;
    assign s_tmr_acc = m_acc;
    assign s_tmr_wdata = m_wdata;
    assign bus_slave_sel[4] = ((m_addr & ~{{`XLEN-rst_SPAN{1'b0}}, {rst_SPAN{1'b1}}}) == rst_BASE);
    assign s_rst_req = m_req & bus_slave_sel[4];
    assign s_rst_addr = m_addr[rst_SPAN-1:0];
    assign s_rst_w_rb = m_w_rb;
    assign s_rst_acc = m_acc;
    assign s_rst_wdata = m_wdata;

    assign bus_fault = m_req & ~|bus_slave_sel;

    // resp mux
    always @ (*) begin
        if (s_eic_resp) m_rdata = s_eic_rdata;
        else if (s_uart_resp) m_rdata = s_uart_rdata;
        else if (s_gpio_resp) m_rdata = s_gpio_rdata;
        else if (s_tmr_resp) m_rdata = s_tmr_rdata;
        else m_rdata = s_rst_rdata;
    end

    assign m_resp = |{s_eic_resp, s_uart_resp, s_gpio_resp, s_tmr_resp, s_rst_resp};
    assign m_fault = |{s_eic_fault, s_uart_fault, s_gpio_fault, s_tmr_fault, s_rst_fault};
endmodule
