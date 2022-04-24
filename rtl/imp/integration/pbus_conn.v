`include "timescale.vh"
`include "femto.vh"

module pbus_conn # (
    parameter EIC_BASE = `EIC_BASE,
    parameter EIC_SPAN = $clog2(`EIC_SIZE),
    parameter UART_BASE = `UART_BASE,
    parameter UART_SPAN = $clog2(`UART_SIZE),
    parameter GPIO_BASE = `GPIO_BASE,
    parameter GPIO_SPAN = $clog2(`GPIO_SIZE),
    parameter TMR_BASE = `TMR_BASE,
    parameter TMR_SPAN = $clog2(`TMR_SIZE),
    parameter RST_BASE = `RST_BASE,
    parameter RST_SPAN = $clog2(`RST_SIZE)
) (
    input wire m_req,
    input wire[`XLEN-1:0] m_addr,
    input wire m_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] m_acc,
    input wire[`BUS_WIDTH-1:0] m_wdata,
    output wire m_resp,
    output reg[`BUS_WIDTH-1:0] m_rdata,

    output wire s_eic_req,
    output wire[`XLEN-1:0] s_eic_addr,
    output wire s_eic_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_eic_acc,
    output wire[`BUS_WIDTH-1:0] s_eic_wdata,
    input wire s_eic_resp,
    input wire[`BUS_WIDTH-1:0] s_eic_rdata,

    output wire s_uart_req,
    output wire[`XLEN-1:0] s_uart_addr,
    output wire s_uart_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_uart_acc,
    output wire[`BUS_WIDTH-1:0] s_uart_wdata,
    input wire s_uart_resp,
    input wire[`BUS_WIDTH-1:0] s_uart_rdata,

    output wire s_gpio_req,
    output wire[`XLEN-1:0] s_gpio_addr,
    output wire s_gpio_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_gpio_acc,
    output wire[`BUS_WIDTH-1:0] s_gpio_wdata,
    input wire s_gpio_resp,
    input wire[`BUS_WIDTH-1:0] s_gpio_rdata,

    output wire s_tmr_req,
    output wire[`XLEN-1:0] s_tmr_addr,
    output wire s_tmr_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_tmr_acc,
    output wire[`BUS_WIDTH-1:0] s_tmr_wdata,
    input wire s_tmr_resp,
    input wire[`BUS_WIDTH-1:0] s_tmr_rdata,

    output wire s_rst_req,
    output wire[`XLEN-1:0] s_rst_addr,
    output wire s_rst_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_rst_acc,
    output wire[`BUS_WIDTH-1:0] s_rst_wdata,
    input wire s_rst_resp,
    input wire[`BUS_WIDTH-1:0] s_rst_rdata,

    output wire bus_fault, // no bus slave is selected
    output wire[`XLEN-1:0] bus_fault_addr,
    input wire bus_halt // force halt bus
);
    localparam SLAVE_CNT = 5;

    // req demux
    wire[SLAVE_CNT-1:0] bus_slave_sel;
    assign bus_slave_sel[0] = ((m_addr & ~{{(`XLEN-EIC_SPAN){1'b0}}, {EIC_SPAN{1'b1}}}) == EIC_BASE);
    assign s_eic_req = m_req & bus_slave_sel[0];
    assign s_eic_addr = m_addr;
    assign s_eic_w_rb = m_w_rb;
    assign s_eic_acc = m_acc;
    assign s_eic_wdata = m_wdata;
    assign bus_slave_sel[1] = ((m_addr & ~{{(`XLEN-UART_SPAN){1'b0}}, {UART_SPAN{1'b1}}}) == UART_BASE);
    assign s_uart_req = m_req & bus_slave_sel[1];
    assign s_uart_addr = m_addr;
    assign s_uart_w_rb = m_w_rb;
    assign s_uart_acc = m_acc;
    assign s_uart_wdata = m_wdata;
    assign bus_slave_sel[2] = ((m_addr & ~{{(`XLEN-GPIO_SPAN){1'b0}}, {GPIO_SPAN{1'b1}}}) == GPIO_BASE);
    assign s_gpio_req = m_req & bus_slave_sel[2];
    assign s_gpio_addr = m_addr;
    assign s_gpio_w_rb = m_w_rb;
    assign s_gpio_acc = m_acc;
    assign s_gpio_wdata = m_wdata;
    assign bus_slave_sel[3] = ((m_addr & ~{{(`XLEN-TMR_SPAN){1'b0}}, {TMR_SPAN{1'b1}}}) == TMR_BASE);
    assign s_tmr_req = m_req & bus_slave_sel[3];
    assign s_tmr_addr = m_addr;
    assign s_tmr_w_rb = m_w_rb;
    assign s_tmr_acc = m_acc;
    assign s_tmr_wdata = m_wdata;
    assign bus_slave_sel[4] = ((m_addr & ~{{(`XLEN-RST_SPAN){1'b0}}, {RST_SPAN{1'b1}}}) == RST_BASE);
    assign s_rst_req = m_req & bus_slave_sel[4];
    assign s_rst_addr = m_addr;
    assign s_rst_w_rb = m_w_rb;
    assign s_rst_acc = m_acc;
    assign s_rst_wdata = m_wdata;

    assign bus_fault = m_req & ~|bus_slave_sel;
    assign bus_fault_addr = m_addr;

    // resp mux
    always @ (*) begin
        if (s_eic_resp) m_rdata = s_eic_rdata;
        else if (s_uart_resp) m_rdata = s_uart_rdata;
        else if (s_gpio_resp) m_rdata = s_gpio_rdata;
        else if (s_tmr_resp) m_rdata = s_tmr_rdata;
        else if (s_rst_resp) m_rdata = s_rst_rdata;
        else m_rdata = m_rdata;
    end

    assign m_resp = ~bus_halt & |{s_eic_resp, s_uart_resp, s_gpio_resp, s_tmr_resp, s_rst_resp};
endmodule
