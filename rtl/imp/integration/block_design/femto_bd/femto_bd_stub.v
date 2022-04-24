// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Sun Apr 24 10:06:35 2022
// Host        : DESKTOP-95QVU9S running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               D:/Projects/femto/rtl/imp/integration/block_design/femto_bd/femto_bd_stub.v
// Design      : femto_bd
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module femto_bd(pad_clk_0, pad_gpio_0, pad_qspi_csb_0, 
  pad_qspi_sck_0, pad_qspi_sio_0, pad_rstn_0, pad_sram_addr_0, pad_sram_ce_bar_0, 
  pad_sram_data_0, pad_sram_oe_bar_0, pad_sram_we_bar_0, pad_uart_rx_0, pad_uart_tx_0)
/* synthesis syn_black_box black_box_pad_pin="pad_clk_0,pad_gpio_0[3:0],pad_qspi_csb_0,pad_qspi_sck_0,pad_qspi_sio_0[3:0],pad_rstn_0,pad_sram_addr_0[18:0],pad_sram_ce_bar_0,pad_sram_data_0[7:0],pad_sram_oe_bar_0,pad_sram_we_bar_0,pad_uart_rx_0,pad_uart_tx_0" */;
  input pad_clk_0;
  inout [3:0]pad_gpio_0;
  output pad_qspi_csb_0;
  output pad_qspi_sck_0;
  inout [3:0]pad_qspi_sio_0;
  input pad_rstn_0;
  output [18:0]pad_sram_addr_0;
  output pad_sram_ce_bar_0;
  inout [7:0]pad_sram_data_0;
  output pad_sram_oe_bar_0;
  output pad_sram_we_bar_0;
  input pad_uart_rx_0;
  output pad_uart_tx_0;
endmodule
