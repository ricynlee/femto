// Ported from rtl\imp\integration\block_design\femto_bd\synth\femto_bd.v

`include "timescale.vh"

module femto
   (clk,
    gpio,
    qspi_csb,
    qspi_sck,
    qspi_sio,
    rstn,
    sram_addr,
    sram_ce_bar,
    sram_data,
    sram_oe_bar,
    sram_we_bar,
    uart_rx,
    uart_tx);
  input clk;
  inout [3:0]gpio;
  output qspi_csb;
  output qspi_sck;
  inout [3:0]qspi_sio;
  input rstn;
  output [18:0]sram_addr;
  output sram_ce_bar;
  inout [7:0]sram_data;
  output sram_oe_bar;
  output sram_we_bar;
  input uart_rx;
  output uart_tx;

  wire [3:0]Net;
  wire [7:0]Net1;
  wire [3:0]Net2;
  wire Net3;
  wire [1:0]bus_bridge_0_p_ACC;
  wire [31:0]bus_bridge_0_p_ADDR;
  wire [31:0]bus_bridge_0_p_RDATA;
  wire bus_bridge_0_p_REQ;
  wire bus_bridge_0_p_RESP;
  wire [31:0]bus_bridge_0_p_WDATA;
  wire bus_bridge_0_p_W_RB;
  wire core_0_core_fault;
  wire [31:0]core_0_core_fault_pc;
  wire [1:0]core_0_d_ACC;
  wire [31:0]core_0_d_ADDR;
  wire [31:0]core_0_d_RDATA;
  wire core_0_d_REQ;
  wire core_0_d_RESP;
  wire [31:0]core_0_d_WDATA;
  wire core_0_d_W_RB;
  wire core_0_ext_int_handled;
  wire [1:0]core_0_i_ACC;
  wire [31:0]core_0_i_ADDR;
  wire [31:0]core_0_i_RDATA;
  wire core_0_i_REQ;
  wire core_0_i_RESP;
  wire [31:0]core_0_i_WDATA;
  wire core_0_i_W_RB;
  wire dbus_conn_0_bus_fault;
  wire [31:0]dbus_conn_0_bus_fault_addr;
  wire [1:0]dbus_conn_0_d_bridge_ACC;
  wire [31:0]dbus_conn_0_d_bridge_ADDR;
  wire [31:0]dbus_conn_0_d_bridge_RDATA;
  wire dbus_conn_0_d_bridge_REQ;
  wire dbus_conn_0_d_bridge_RESP;
  wire [31:0]dbus_conn_0_d_bridge_WDATA;
  wire dbus_conn_0_d_bridge_W_RB;
  wire [1:0]dbus_conn_0_d_nor_ACC;
  wire [31:0]dbus_conn_0_d_nor_ADDR;
  wire [31:0]dbus_conn_0_d_nor_RDATA;
  wire dbus_conn_0_d_nor_REQ;
  wire dbus_conn_0_d_nor_RESP;
  wire [31:0]dbus_conn_0_d_nor_WDATA;
  wire dbus_conn_0_d_nor_W_RB;
  wire [1:0]dbus_conn_0_d_qspi_ACC;
  wire [31:0]dbus_conn_0_d_qspi_ADDR;
  wire [31:0]dbus_conn_0_d_qspi_RDATA;
  wire dbus_conn_0_d_qspi_REQ;
  wire dbus_conn_0_d_qspi_RESP;
  wire [31:0]dbus_conn_0_d_qspi_WDATA;
  wire dbus_conn_0_d_qspi_W_RB;
  wire [1:0]dbus_conn_0_d_rom_ACC;
  wire [31:0]dbus_conn_0_d_rom_ADDR;
  wire [31:0]dbus_conn_0_d_rom_RDATA;
  wire dbus_conn_0_d_rom_REQ;
  wire dbus_conn_0_d_rom_RESP;
  wire [31:0]dbus_conn_0_d_rom_WDATA;
  wire dbus_conn_0_d_rom_W_RB;
  wire [1:0]dbus_conn_0_d_sram_ACC;
  wire [31:0]dbus_conn_0_d_sram_ADDR;
  wire [31:0]dbus_conn_0_d_sram_RDATA;
  wire dbus_conn_0_d_sram_REQ;
  wire dbus_conn_0_d_sram_RESP;
  wire [31:0]dbus_conn_0_d_sram_WDATA;
  wire dbus_conn_0_d_sram_W_RB;
  wire [1:0]dbus_conn_0_d_tcm_ACC;
  wire [31:0]dbus_conn_0_d_tcm_ADDR;
  wire [31:0]dbus_conn_0_d_tcm_RDATA;
  wire dbus_conn_0_d_tcm_REQ;
  wire dbus_conn_0_d_tcm_RESP;
  wire [31:0]dbus_conn_0_d_tcm_WDATA;
  wire dbus_conn_0_d_tcm_W_RB;
  wire eic_wrapper_0_eic_fault;
  wire eic_wrapper_0_ext_int_trigger;
  wire [31:0]fault_encoder_0_fault1_ADDR;
  wire [7:0]fault_encoder_0_fault1_CAUSE;
  wire fault_encoder_0_fault1_FAULT;
  wire [3:0]gpio_wrapper_0_gpio_GPIO_DIN;
  wire [3:0]gpio_wrapper_0_gpio_GPIO_DIR;
  wire [3:0]gpio_wrapper_0_gpio_GPIO_DOUT;
  wire gpio_wrapper_0_gpio_fault;
  wire ibus_conn_0_bus_fault;
  wire [31:0]ibus_conn_0_bus_fault_addr;
  wire [1:0]ibus_conn_0_i_nor_ACC;
  wire [31:0]ibus_conn_0_i_nor_ADDR;
  wire [31:0]ibus_conn_0_i_nor_RDATA;
  wire ibus_conn_0_i_nor_REQ;
  wire ibus_conn_0_i_nor_RESP;
  wire [31:0]ibus_conn_0_i_nor_WDATA;
  wire ibus_conn_0_i_nor_W_RB;
  wire [1:0]ibus_conn_0_i_rom_ACC;
  wire [31:0]ibus_conn_0_i_rom_ADDR;
  wire [31:0]ibus_conn_0_i_rom_RDATA;
  wire ibus_conn_0_i_rom_REQ;
  wire ibus_conn_0_i_rom_RESP;
  wire [31:0]ibus_conn_0_i_rom_WDATA;
  wire ibus_conn_0_i_rom_W_RB;
  wire [1:0]ibus_conn_0_i_sram_ACC;
  wire [31:0]ibus_conn_0_i_sram_ADDR;
  wire [31:0]ibus_conn_0_i_sram_RDATA;
  wire ibus_conn_0_i_sram_REQ;
  wire ibus_conn_0_i_sram_RESP;
  wire [31:0]ibus_conn_0_i_sram_WDATA;
  wire ibus_conn_0_i_sram_W_RB;
  wire [1:0]ibus_conn_0_i_tcm_ACC;
  wire [31:0]ibus_conn_0_i_tcm_ADDR;
  wire [31:0]ibus_conn_0_i_tcm_RDATA;
  wire ibus_conn_0_i_tcm_REQ;
  wire ibus_conn_0_i_tcm_RESP;
  wire [31:0]ibus_conn_0_i_tcm_WDATA;
  wire ibus_conn_0_i_tcm_W_RB;
  wire ioring_0_clk;
  wire ioring_0_pad_qspi_csb;
  wire ioring_0_pad_qspi_sck;
  wire [18:0]ioring_0_pad_sram_addr;
  wire ioring_0_pad_sram_ce_bar;
  wire ioring_0_pad_sram_oe_bar;
  wire ioring_0_pad_sram_we_bar;
  wire ioring_0_pad_uart_tx;
  wire ioring_0_rstn;
  wire [1:0]merger_0_o;
  wire pad_clk_0_1;
  wire pad_rstn_0_1;
  wire pad_uart_rx_0_1;
  wire pbus_conn_0_bus_fault;
  wire [31:0]pbus_conn_0_bus_fault_addr;
  wire [1:0]pbus_conn_0_p_eic_ACC;
  wire [31:0]pbus_conn_0_p_eic_ADDR;
  wire [31:0]pbus_conn_0_p_eic_RDATA;
  wire pbus_conn_0_p_eic_REQ;
  wire pbus_conn_0_p_eic_RESP;
  wire [31:0]pbus_conn_0_p_eic_WDATA;
  wire pbus_conn_0_p_eic_W_RB;
  wire [1:0]pbus_conn_0_p_gpio_ACC;
  wire [31:0]pbus_conn_0_p_gpio_ADDR;
  wire [31:0]pbus_conn_0_p_gpio_RDATA;
  wire pbus_conn_0_p_gpio_REQ;
  wire pbus_conn_0_p_gpio_RESP;
  wire [31:0]pbus_conn_0_p_gpio_WDATA;
  wire pbus_conn_0_p_gpio_W_RB;
  wire [1:0]pbus_conn_0_p_rst_ACC;
  wire [31:0]pbus_conn_0_p_rst_ADDR;
  wire [31:0]pbus_conn_0_p_rst_RDATA;
  wire pbus_conn_0_p_rst_REQ;
  wire pbus_conn_0_p_rst_RESP;
  wire [31:0]pbus_conn_0_p_rst_WDATA;
  wire pbus_conn_0_p_rst_W_RB;
  wire [1:0]pbus_conn_0_p_tmr_ACC;
  wire [31:0]pbus_conn_0_p_tmr_ADDR;
  wire [31:0]pbus_conn_0_p_tmr_RDATA;
  wire pbus_conn_0_p_tmr_REQ;
  wire pbus_conn_0_p_tmr_RESP;
  wire [31:0]pbus_conn_0_p_tmr_WDATA;
  wire pbus_conn_0_p_tmr_W_RB;
  wire [1:0]pbus_conn_0_p_uart_ACC;
  wire [31:0]pbus_conn_0_p_uart_ADDR;
  wire [31:0]pbus_conn_0_p_uart_RDATA;
  wire pbus_conn_0_p_uart_REQ;
  wire pbus_conn_0_p_uart_RESP;
  wire [31:0]pbus_conn_0_p_uart_WDATA;
  wire pbus_conn_0_p_uart_W_RB;
  wire qspi_wrapper_0_nor_d_fault;
  wire qspi_wrapper_0_nor_i_fault;
  wire qspi_wrapper_0_qspi_CSb;
  wire [3:0]qspi_wrapper_0_qspi_DIR;
  wire qspi_wrapper_0_qspi_SCLK;
  wire [3:0]qspi_wrapper_0_qspi_SIN;
  wire [3:0]qspi_wrapper_0_qspi_SOUT;
  wire qspi_wrapper_0_qspi_fault;
  wire rom_wrapper_0_rom_d_fault;
  wire rom_wrapper_0_rom_i_fault;
  wire rst_wrapper_0_rst_fault;
  wire [9:0]rst_wrapper_0_rst_ob;
  wire splitter_0_o0;
  wire splitter_0_o1;
  wire splitter_0_o2;
  wire splitter_0_o3;
  wire splitter_0_o4;
  wire splitter_0_o5;
  wire splitter_0_o6;
  wire splitter_0_o7;
  wire splitter_0_o8;
  wire splitter_0_o9;
  wire [18:0]sram_wrapper_0_sram_ADDR;
  wire sram_wrapper_0_sram_CEb;
  wire [7:0]sram_wrapper_0_sram_DIN;
  wire [7:0]sram_wrapper_0_sram_DOUT;
  wire sram_wrapper_0_sram_OEb;
  wire sram_wrapper_0_sram_WEb;
  wire sram_wrapper_0_sram_W_RB;
  wire sram_wrapper_0_sram_d_fault;
  wire sram_wrapper_0_sram_i_fault;
  wire tcm_wrapper_0_tcm_d_fault;
  wire tcm_wrapper_0_tcm_i_fault;
  wire tmr_wrapper_0_interrupt;
  wire tmr_wrapper_0_tmr_fault;
  wire uart_wrapper_0_interrupt;
  wire uart_wrapper_0_uart_RX;
  wire uart_wrapper_0_uart_TX;
  wire uart_wrapper_0_uart_fault;

  assign pad_clk_0_1 = clk;
  assign pad_rstn_0_1 = rstn;
  assign pad_uart_rx_0_1 = uart_rx;
  assign qspi_csb = ioring_0_pad_qspi_csb;
  assign qspi_sck = ioring_0_pad_qspi_sck;
  assign sram_addr[18:0] = ioring_0_pad_sram_addr;
  assign sram_ce_bar = ioring_0_pad_sram_ce_bar;
  assign sram_oe_bar = ioring_0_pad_sram_oe_bar;
  assign sram_we_bar = ioring_0_pad_sram_we_bar;
  assign uart_tx = ioring_0_pad_uart_tx;
  bus_bridge bus_bridge
       (.clk(ioring_0_clk),
        .d_acc(dbus_conn_0_d_bridge_ACC),
        .d_addr(dbus_conn_0_d_bridge_ADDR),
        .d_rdata(dbus_conn_0_d_bridge_RDATA),
        .d_req(dbus_conn_0_d_bridge_REQ),
        .d_resp(dbus_conn_0_d_bridge_RESP),
        .d_w_rb(dbus_conn_0_d_bridge_W_RB),
        .d_wdata(dbus_conn_0_d_bridge_WDATA),
        .p_acc(bus_bridge_0_p_ACC),
        .p_addr(bus_bridge_0_p_ADDR),
        .p_rdata(bus_bridge_0_p_RDATA),
        .p_req(bus_bridge_0_p_REQ),
        .p_resp(bus_bridge_0_p_RESP),
        .p_w_rb(bus_bridge_0_p_W_RB),
        .p_wdata(bus_bridge_0_p_WDATA),
        .rstn(splitter_0_o9));
  core core
       (.clk(ioring_0_clk),
        .core_fault(core_0_core_fault),
        .core_fault_pc(core_0_core_fault_pc),
        .dbus_acc(core_0_d_ACC),
        .dbus_addr(core_0_d_ADDR),
        .dbus_rdata(core_0_d_RDATA),
        .dbus_req(core_0_d_REQ),
        .dbus_resp(core_0_d_RESP),
        .dbus_w_rb(core_0_d_W_RB),
        .dbus_wdata(core_0_d_WDATA),
        .ext_int_handled(core_0_ext_int_handled),
        .ext_int_trigger(eic_wrapper_0_ext_int_trigger),
        .ibus_acc(core_0_i_ACC),
        .ibus_addr(core_0_i_ADDR),
        .ibus_rdata(core_0_i_RDATA),
        .ibus_req(core_0_i_REQ),
        .ibus_resp(core_0_i_RESP),
        .ibus_w_rb(core_0_i_W_RB),
        .ibus_wdata(core_0_i_WDATA),
        .rstn(splitter_0_o0));
  dbus_conn dbus_conn
       (.bus_fault(dbus_conn_0_bus_fault),
        .bus_fault_addr(dbus_conn_0_bus_fault_addr),
        .bus_halt(Net3),
        .m_acc(core_0_d_ACC),
        .m_addr(core_0_d_ADDR),
        .m_rdata(core_0_d_RDATA),
        .m_req(core_0_d_REQ),
        .m_resp(core_0_d_RESP),
        .m_w_rb(core_0_d_W_RB),
        .m_wdata(core_0_d_WDATA),
        .s_bridge_acc(dbus_conn_0_d_bridge_ACC),
        .s_bridge_addr(dbus_conn_0_d_bridge_ADDR),
        .s_bridge_rdata(dbus_conn_0_d_bridge_RDATA),
        .s_bridge_req(dbus_conn_0_d_bridge_REQ),
        .s_bridge_resp(dbus_conn_0_d_bridge_RESP),
        .s_bridge_w_rb(dbus_conn_0_d_bridge_W_RB),
        .s_bridge_wdata(dbus_conn_0_d_bridge_WDATA),
        .s_nor_acc(dbus_conn_0_d_nor_ACC),
        .s_nor_addr(dbus_conn_0_d_nor_ADDR),
        .s_nor_rdata(dbus_conn_0_d_nor_RDATA),
        .s_nor_req(dbus_conn_0_d_nor_REQ),
        .s_nor_resp(dbus_conn_0_d_nor_RESP),
        .s_nor_w_rb(dbus_conn_0_d_nor_W_RB),
        .s_nor_wdata(dbus_conn_0_d_nor_WDATA),
        .s_qspi_acc(dbus_conn_0_d_qspi_ACC),
        .s_qspi_addr(dbus_conn_0_d_qspi_ADDR),
        .s_qspi_rdata(dbus_conn_0_d_qspi_RDATA),
        .s_qspi_req(dbus_conn_0_d_qspi_REQ),
        .s_qspi_resp(dbus_conn_0_d_qspi_RESP),
        .s_qspi_w_rb(dbus_conn_0_d_qspi_W_RB),
        .s_qspi_wdata(dbus_conn_0_d_qspi_WDATA),
        .s_rom_acc(dbus_conn_0_d_rom_ACC),
        .s_rom_addr(dbus_conn_0_d_rom_ADDR),
        .s_rom_rdata(dbus_conn_0_d_rom_RDATA),
        .s_rom_req(dbus_conn_0_d_rom_REQ),
        .s_rom_resp(dbus_conn_0_d_rom_RESP),
        .s_rom_w_rb(dbus_conn_0_d_rom_W_RB),
        .s_rom_wdata(dbus_conn_0_d_rom_WDATA),
        .s_sram_acc(dbus_conn_0_d_sram_ACC),
        .s_sram_addr(dbus_conn_0_d_sram_ADDR),
        .s_sram_rdata(dbus_conn_0_d_sram_RDATA),
        .s_sram_req(dbus_conn_0_d_sram_REQ),
        .s_sram_resp(dbus_conn_0_d_sram_RESP),
        .s_sram_w_rb(dbus_conn_0_d_sram_W_RB),
        .s_sram_wdata(dbus_conn_0_d_sram_WDATA),
        .s_tcm_acc(dbus_conn_0_d_tcm_ACC),
        .s_tcm_addr(dbus_conn_0_d_tcm_ADDR),
        .s_tcm_rdata(dbus_conn_0_d_tcm_RDATA),
        .s_tcm_req(dbus_conn_0_d_tcm_REQ),
        .s_tcm_resp(dbus_conn_0_d_tcm_RESP),
        .s_tcm_w_rb(dbus_conn_0_d_tcm_W_RB),
        .s_tcm_wdata(dbus_conn_0_d_tcm_WDATA));
  eic_wrapper eic_wrapper
       (.clk(ioring_0_clk),
        .eic_fault(eic_wrapper_0_eic_fault),
        .ext_int_handled(core_0_ext_int_handled),
        .ext_int_src(merger_0_o),
        .ext_int_trigger(eic_wrapper_0_ext_int_trigger),
        .p_acc(pbus_conn_0_p_eic_ACC),
        .p_addr(pbus_conn_0_p_eic_ADDR),
        .p_rdata(pbus_conn_0_p_eic_RDATA),
        .p_req(pbus_conn_0_p_eic_REQ),
        .p_resp(pbus_conn_0_p_eic_RESP),
        .p_w_rb(pbus_conn_0_p_eic_W_RB),
        .p_wdata(pbus_conn_0_p_eic_WDATA),
        .rstn(splitter_0_o5));
  fault_encoder fault_encoder
       (.clk(ioring_0_clk),
        .core_fault(core_0_core_fault),
        .core_fault_pc(core_0_core_fault_pc),
        .dbus_addr(dbus_conn_0_bus_fault_addr),
        .dbus_fault(dbus_conn_0_bus_fault),
        .eic_fault(eic_wrapper_0_eic_fault),
        .fault(fault_encoder_0_fault1_FAULT),
        .fault_addr(fault_encoder_0_fault1_ADDR),
        .fault_cause(fault_encoder_0_fault1_CAUSE),
        .gpio_fault(gpio_wrapper_0_gpio_fault),
        .halt(Net3),
        .ibus_addr(ibus_conn_0_bus_fault_addr),
        .ibus_fault(ibus_conn_0_bus_fault),
        .nor_d_fault(qspi_wrapper_0_nor_d_fault),
        .nor_i_fault(qspi_wrapper_0_nor_i_fault),
        .pbus_addr(pbus_conn_0_bus_fault_addr),
        .pbus_fault(pbus_conn_0_bus_fault),
        .qspi_fault(qspi_wrapper_0_qspi_fault),
        .rom_d_fault(rom_wrapper_0_rom_d_fault),
        .rom_i_fault(rom_wrapper_0_rom_i_fault),
        .rst_fault(rst_wrapper_0_rst_fault),
        .rstn(splitter_0_o9),
        .sram_d_fault(sram_wrapper_0_sram_d_fault),
        .sram_i_fault(sram_wrapper_0_sram_i_fault),
        .tcm_d_fault(tcm_wrapper_0_tcm_d_fault),
        .tcm_i_fault(tcm_wrapper_0_tcm_i_fault),
        .tmr_fault(tmr_wrapper_0_tmr_fault),
        .uart_fault(uart_wrapper_0_uart_fault));
  gpio_wrapper gpio_wrapper
       (.clk(ioring_0_clk),
        .dir(gpio_wrapper_0_gpio_GPIO_DIR),
        .gpio_fault(gpio_wrapper_0_gpio_fault),
        .i(gpio_wrapper_0_gpio_GPIO_DIN),
        .o(gpio_wrapper_0_gpio_GPIO_DOUT),
        .p_acc(pbus_conn_0_p_gpio_ACC),
        .p_addr(pbus_conn_0_p_gpio_ADDR),
        .p_rdata(pbus_conn_0_p_gpio_RDATA),
        .p_req(pbus_conn_0_p_gpio_REQ),
        .p_resp(pbus_conn_0_p_gpio_RESP),
        .p_w_rb(pbus_conn_0_p_gpio_W_RB),
        .p_wdata(pbus_conn_0_p_gpio_WDATA),
        .rstn(splitter_0_o7));
  ibus_conn ibus_conn
       (.bus_fault(ibus_conn_0_bus_fault),
        .bus_fault_addr(ibus_conn_0_bus_fault_addr),
        .bus_halt(Net3),
        .m_acc(core_0_i_ACC),
        .m_addr(core_0_i_ADDR),
        .m_rdata(core_0_i_RDATA),
        .m_req(core_0_i_REQ),
        .m_resp(core_0_i_RESP),
        .m_w_rb(core_0_i_W_RB),
        .m_wdata(core_0_i_WDATA),
        .s_nor_acc(ibus_conn_0_i_nor_ACC),
        .s_nor_addr(ibus_conn_0_i_nor_ADDR),
        .s_nor_rdata(ibus_conn_0_i_nor_RDATA),
        .s_nor_req(ibus_conn_0_i_nor_REQ),
        .s_nor_resp(ibus_conn_0_i_nor_RESP),
        .s_nor_w_rb(ibus_conn_0_i_nor_W_RB),
        .s_nor_wdata(ibus_conn_0_i_nor_WDATA),
        .s_rom_acc(ibus_conn_0_i_rom_ACC),
        .s_rom_addr(ibus_conn_0_i_rom_ADDR),
        .s_rom_rdata(ibus_conn_0_i_rom_RDATA),
        .s_rom_req(ibus_conn_0_i_rom_REQ),
        .s_rom_resp(ibus_conn_0_i_rom_RESP),
        .s_rom_w_rb(ibus_conn_0_i_rom_W_RB),
        .s_rom_wdata(ibus_conn_0_i_rom_WDATA),
        .s_sram_acc(ibus_conn_0_i_sram_ACC),
        .s_sram_addr(ibus_conn_0_i_sram_ADDR),
        .s_sram_rdata(ibus_conn_0_i_sram_RDATA),
        .s_sram_req(ibus_conn_0_i_sram_REQ),
        .s_sram_resp(ibus_conn_0_i_sram_RESP),
        .s_sram_w_rb(ibus_conn_0_i_sram_W_RB),
        .s_sram_wdata(ibus_conn_0_i_sram_WDATA),
        .s_tcm_acc(ibus_conn_0_i_tcm_ACC),
        .s_tcm_addr(ibus_conn_0_i_tcm_ADDR),
        .s_tcm_rdata(ibus_conn_0_i_tcm_RDATA),
        .s_tcm_req(ibus_conn_0_i_tcm_REQ),
        .s_tcm_resp(ibus_conn_0_i_tcm_RESP),
        .s_tcm_w_rb(ibus_conn_0_i_tcm_W_RB),
        .s_tcm_wdata(ibus_conn_0_i_tcm_WDATA));
  ioring ioring
       (.clk(ioring_0_clk),
        .gpio_dir(gpio_wrapper_0_gpio_GPIO_DIR),
        .gpio_i(gpio_wrapper_0_gpio_GPIO_DIN),
        .gpio_o(gpio_wrapper_0_gpio_GPIO_DOUT),
        .pad_clk(pad_clk_0_1),
        .pad_gpio(gpio[3:0]),
        .pad_qspi_csb(ioring_0_pad_qspi_csb),
        .pad_qspi_sck(ioring_0_pad_qspi_sck),
        .pad_qspi_sio(qspi_sio[3:0]),
        .pad_rstn(pad_rstn_0_1),
        .pad_sram_addr(ioring_0_pad_sram_addr),
        .pad_sram_ce_bar(ioring_0_pad_sram_ce_bar),
        .pad_sram_data(sram_data[7:0]),
        .pad_sram_oe_bar(ioring_0_pad_sram_oe_bar),
        .pad_sram_we_bar(ioring_0_pad_sram_we_bar),
        .pad_uart_rx(pad_uart_rx_0_1),
        .pad_uart_tx(ioring_0_pad_uart_tx),
        .qspi_csb(qspi_wrapper_0_qspi_CSb),
        .qspi_dir(qspi_wrapper_0_qspi_DIR),
        .qspi_miso(qspi_wrapper_0_qspi_SIN),
        .qspi_mosi(qspi_wrapper_0_qspi_SOUT),
        .qspi_sclk(qspi_wrapper_0_qspi_SCLK),
        .rstn(ioring_0_rstn),
        .sram_addr(sram_wrapper_0_sram_ADDR),
        .sram_ce_bar(sram_wrapper_0_sram_CEb),
        .sram_data_dir(sram_wrapper_0_sram_W_RB),
        .sram_data_in(sram_wrapper_0_sram_DIN),
        .sram_data_out(sram_wrapper_0_sram_DOUT),
        .sram_oe_bar(sram_wrapper_0_sram_OEb),
        .sram_we_bar(sram_wrapper_0_sram_WEb),
        .uart_rx(uart_wrapper_0_uart_RX),
        .uart_tx(uart_wrapper_0_uart_TX));
  merger merger
       (.i0(tmr_wrapper_0_interrupt),
        .i1(uart_wrapper_0_interrupt),
        .o(merger_0_o));
  pbus_conn pbus_conn
       (.bus_fault(pbus_conn_0_bus_fault),
        .bus_fault_addr(pbus_conn_0_bus_fault_addr),
        .bus_halt(Net3),
        .m_acc(bus_bridge_0_p_ACC),
        .m_addr(bus_bridge_0_p_ADDR),
        .m_rdata(bus_bridge_0_p_RDATA),
        .m_req(bus_bridge_0_p_REQ),
        .m_resp(bus_bridge_0_p_RESP),
        .m_w_rb(bus_bridge_0_p_W_RB),
        .m_wdata(bus_bridge_0_p_WDATA),
        .s_eic_acc(pbus_conn_0_p_eic_ACC),
        .s_eic_addr(pbus_conn_0_p_eic_ADDR),
        .s_eic_rdata(pbus_conn_0_p_eic_RDATA),
        .s_eic_req(pbus_conn_0_p_eic_REQ),
        .s_eic_resp(pbus_conn_0_p_eic_RESP),
        .s_eic_w_rb(pbus_conn_0_p_eic_W_RB),
        .s_eic_wdata(pbus_conn_0_p_eic_WDATA),
        .s_gpio_acc(pbus_conn_0_p_gpio_ACC),
        .s_gpio_addr(pbus_conn_0_p_gpio_ADDR),
        .s_gpio_rdata(pbus_conn_0_p_gpio_RDATA),
        .s_gpio_req(pbus_conn_0_p_gpio_REQ),
        .s_gpio_resp(pbus_conn_0_p_gpio_RESP),
        .s_gpio_w_rb(pbus_conn_0_p_gpio_W_RB),
        .s_gpio_wdata(pbus_conn_0_p_gpio_WDATA),
        .s_rst_acc(pbus_conn_0_p_rst_ACC),
        .s_rst_addr(pbus_conn_0_p_rst_ADDR),
        .s_rst_rdata(pbus_conn_0_p_rst_RDATA),
        .s_rst_req(pbus_conn_0_p_rst_REQ),
        .s_rst_resp(pbus_conn_0_p_rst_RESP),
        .s_rst_w_rb(pbus_conn_0_p_rst_W_RB),
        .s_rst_wdata(pbus_conn_0_p_rst_WDATA),
        .s_tmr_acc(pbus_conn_0_p_tmr_ACC),
        .s_tmr_addr(pbus_conn_0_p_tmr_ADDR),
        .s_tmr_rdata(pbus_conn_0_p_tmr_RDATA),
        .s_tmr_req(pbus_conn_0_p_tmr_REQ),
        .s_tmr_resp(pbus_conn_0_p_tmr_RESP),
        .s_tmr_w_rb(pbus_conn_0_p_tmr_W_RB),
        .s_tmr_wdata(pbus_conn_0_p_tmr_WDATA),
        .s_uart_acc(pbus_conn_0_p_uart_ACC),
        .s_uart_addr(pbus_conn_0_p_uart_ADDR),
        .s_uart_rdata(pbus_conn_0_p_uart_RDATA),
        .s_uart_req(pbus_conn_0_p_uart_REQ),
        .s_uart_resp(pbus_conn_0_p_uart_RESP),
        .s_uart_w_rb(pbus_conn_0_p_uart_W_RB),
        .s_uart_wdata(pbus_conn_0_p_uart_WDATA));
  qspi_wrapper qspi_wrapper
       (.clk(ioring_0_clk),
        .nor_d_acc(dbus_conn_0_d_nor_ACC),
        .nor_d_addr(dbus_conn_0_d_nor_ADDR),
        .nor_d_fault(qspi_wrapper_0_nor_d_fault),
        .nor_d_rdata(dbus_conn_0_d_nor_RDATA),
        .nor_d_req(dbus_conn_0_d_nor_REQ),
        .nor_d_resp(dbus_conn_0_d_nor_RESP),
        .nor_d_w_rb(dbus_conn_0_d_nor_W_RB),
        .nor_d_wdata(dbus_conn_0_d_nor_WDATA),
        .nor_i_acc(ibus_conn_0_i_nor_ACC),
        .nor_i_addr(ibus_conn_0_i_nor_ADDR),
        .nor_i_fault(qspi_wrapper_0_nor_i_fault),
        .nor_i_rdata(ibus_conn_0_i_nor_RDATA),
        .nor_i_req(ibus_conn_0_i_nor_REQ),
        .nor_i_resp(ibus_conn_0_i_nor_RESP),
        .nor_i_w_rb(ibus_conn_0_i_nor_W_RB),
        .nor_i_wdata(ibus_conn_0_i_nor_WDATA),
        .qspi_d_acc(dbus_conn_0_d_qspi_ACC),
        .qspi_d_addr(dbus_conn_0_d_qspi_ADDR),
        .qspi_d_rdata(dbus_conn_0_d_qspi_RDATA),
        .qspi_d_req(dbus_conn_0_d_qspi_REQ),
        .qspi_d_resp(dbus_conn_0_d_qspi_RESP),
        .qspi_d_w_rb(dbus_conn_0_d_qspi_W_RB),
        .qspi_d_wdata(dbus_conn_0_d_qspi_WDATA),
        .qspi_fault(qspi_wrapper_0_qspi_fault),
        .rstn(splitter_0_o4),
        .spi_csb(qspi_wrapper_0_qspi_CSb),
        .spi_dir(qspi_wrapper_0_qspi_DIR),
        .spi_miso(qspi_wrapper_0_qspi_SIN),
        .spi_mosi(qspi_wrapper_0_qspi_SOUT),
        .spi_sclk(qspi_wrapper_0_qspi_SCLK));
  rom_wrapper rom_wrapper
       (.clk(ioring_0_clk),
        .d_acc(dbus_conn_0_d_rom_ACC),
        .d_addr(dbus_conn_0_d_rom_ADDR),
        .d_rdata(dbus_conn_0_d_rom_RDATA),
        .d_req(dbus_conn_0_d_rom_REQ),
        .d_resp(dbus_conn_0_d_rom_RESP),
        .d_w_rb(dbus_conn_0_d_rom_W_RB),
        .d_wdata(dbus_conn_0_d_rom_WDATA),
        .i_acc(ibus_conn_0_i_rom_ACC),
        .i_addr(ibus_conn_0_i_rom_ADDR),
        .i_rdata(ibus_conn_0_i_rom_RDATA),
        .i_req(ibus_conn_0_i_rom_REQ),
        .i_resp(ibus_conn_0_i_rom_RESP),
        .i_w_rb(ibus_conn_0_i_rom_W_RB),
        .i_wdata(ibus_conn_0_i_rom_WDATA),
        .rom_d_fault(rom_wrapper_0_rom_d_fault),
        .rom_i_fault(rom_wrapper_0_rom_i_fault),
        .rstn(splitter_0_o1));
  rst_wrapper rst_wrapper
       (.clk(ioring_0_clk),
        .p_acc(pbus_conn_0_p_rst_ACC),
        .p_addr(pbus_conn_0_p_rst_ADDR),
        .p_rdata(pbus_conn_0_p_rst_RDATA),
        .p_req(pbus_conn_0_p_rst_REQ),
        .p_resp(pbus_conn_0_p_rst_RESP),
        .p_w_rb(pbus_conn_0_p_rst_W_RB),
        .p_wdata(pbus_conn_0_p_rst_WDATA),
        .rst_fault(rst_wrapper_0_rst_fault),
        .rst_ib(ioring_0_rstn),
        .rst_ob(rst_wrapper_0_rst_ob),
        .soc_fault(fault_encoder_0_fault1_FAULT),
        .soc_fault_addr(fault_encoder_0_fault1_ADDR),
        .soc_fault_cause(fault_encoder_0_fault1_CAUSE));
  splitter splitter
       (.i(rst_wrapper_0_rst_ob),
        .o0(splitter_0_o0),
        .o1(splitter_0_o1),
        .o2(splitter_0_o2),
        .o3(splitter_0_o3),
        .o4(splitter_0_o4),
        .o5(splitter_0_o5),
        .o6(splitter_0_o6),
        .o7(splitter_0_o7),
        .o8(splitter_0_o8),
        .o9(splitter_0_o9));
  sram_wrapper sram_wrapper
       (.clk(ioring_0_clk),
        .d_acc(dbus_conn_0_d_sram_ACC),
        .d_addr(dbus_conn_0_d_sram_ADDR),
        .d_rdata(dbus_conn_0_d_sram_RDATA),
        .d_req(dbus_conn_0_d_sram_REQ),
        .d_resp(dbus_conn_0_d_sram_RESP),
        .d_w_rb(dbus_conn_0_d_sram_W_RB),
        .d_wdata(dbus_conn_0_d_sram_WDATA),
        .i_acc(ibus_conn_0_i_sram_ACC),
        .i_addr(ibus_conn_0_i_sram_ADDR),
        .i_rdata(ibus_conn_0_i_sram_RDATA),
        .i_req(ibus_conn_0_i_sram_REQ),
        .i_resp(ibus_conn_0_i_sram_RESP),
        .i_w_rb(ibus_conn_0_i_sram_W_RB),
        .i_wdata(ibus_conn_0_i_sram_WDATA),
        .rstn(splitter_0_o3),
        .sram_addr(sram_wrapper_0_sram_ADDR),
        .sram_ce_bar(sram_wrapper_0_sram_CEb),
        .sram_d_fault(sram_wrapper_0_sram_d_fault),
        .sram_data_dir(sram_wrapper_0_sram_W_RB),
        .sram_data_in(sram_wrapper_0_sram_DIN),
        .sram_data_out(sram_wrapper_0_sram_DOUT),
        .sram_i_fault(sram_wrapper_0_sram_i_fault),
        .sram_oe_bar(sram_wrapper_0_sram_OEb),
        .sram_we_bar(sram_wrapper_0_sram_WEb));
  tcm_wrapper tcm_wrapper
       (.clk(ioring_0_clk),
        .d_acc(dbus_conn_0_d_tcm_ACC),
        .d_addr(dbus_conn_0_d_tcm_ADDR),
        .d_rdata(dbus_conn_0_d_tcm_RDATA),
        .d_req(dbus_conn_0_d_tcm_REQ),
        .d_resp(dbus_conn_0_d_tcm_RESP),
        .d_w_rb(dbus_conn_0_d_tcm_W_RB),
        .d_wdata(dbus_conn_0_d_tcm_WDATA),
        .i_acc(ibus_conn_0_i_tcm_ACC),
        .i_addr(ibus_conn_0_i_tcm_ADDR),
        .i_rdata(ibus_conn_0_i_tcm_RDATA),
        .i_req(ibus_conn_0_i_tcm_REQ),
        .i_resp(ibus_conn_0_i_tcm_RESP),
        .i_w_rb(ibus_conn_0_i_tcm_W_RB),
        .i_wdata(ibus_conn_0_i_tcm_WDATA),
        .rstn(splitter_0_o2),
        .tcm_d_fault(tcm_wrapper_0_tcm_d_fault),
        .tcm_i_fault(tcm_wrapper_0_tcm_i_fault));
  tmr_wrapper tmr_wrapper
       (.clk(ioring_0_clk),
        .interrupt(tmr_wrapper_0_interrupt),
        .p_acc(pbus_conn_0_p_tmr_ACC),
        .p_addr(pbus_conn_0_p_tmr_ADDR),
        .p_rdata(pbus_conn_0_p_tmr_RDATA),
        .p_req(pbus_conn_0_p_tmr_REQ),
        .p_resp(pbus_conn_0_p_tmr_RESP),
        .p_w_rb(pbus_conn_0_p_tmr_W_RB),
        .p_wdata(pbus_conn_0_p_tmr_WDATA),
        .rstn(splitter_0_o8),
        .tmr_fault(tmr_wrapper_0_tmr_fault));
  uart_wrapper uart_wrapper
       (.clk(ioring_0_clk),
        .interrupt(uart_wrapper_0_interrupt),
        .p_acc(pbus_conn_0_p_uart_ACC),
        .p_addr(pbus_conn_0_p_uart_ADDR),
        .p_rdata(pbus_conn_0_p_uart_RDATA),
        .p_req(pbus_conn_0_p_uart_REQ),
        .p_resp(pbus_conn_0_p_uart_RESP),
        .p_w_rb(pbus_conn_0_p_uart_W_RB),
        .p_wdata(pbus_conn_0_p_uart_WDATA),
        .rstn(splitter_0_o6),
        .rx(uart_wrapper_0_uart_RX),
        .tx(uart_wrapper_0_uart_TX),
        .uart_fault(uart_wrapper_0_uart_fault));
endmodule
