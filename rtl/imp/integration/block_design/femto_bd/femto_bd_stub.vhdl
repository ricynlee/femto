-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
-- Date        : Sun Apr 24 10:06:35 2022
-- Host        : DESKTOP-95QVU9S running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               D:/Projects/femto/rtl/imp/integration/block_design/femto_bd/femto_bd_stub.vhdl
-- Design      : femto_bd
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity femto_bd is
  Port ( 
    pad_clk_0 : in STD_LOGIC;
    pad_gpio_0 : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    pad_qspi_csb_0 : out STD_LOGIC;
    pad_qspi_sck_0 : out STD_LOGIC;
    pad_qspi_sio_0 : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    pad_rstn_0 : in STD_LOGIC;
    pad_sram_addr_0 : out STD_LOGIC_VECTOR ( 18 downto 0 );
    pad_sram_ce_bar_0 : out STD_LOGIC;
    pad_sram_data_0 : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    pad_sram_oe_bar_0 : out STD_LOGIC;
    pad_sram_we_bar_0 : out STD_LOGIC;
    pad_uart_rx_0 : in STD_LOGIC;
    pad_uart_tx_0 : out STD_LOGIC
  );

end femto_bd;

architecture stub of femto_bd is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "pad_clk_0,pad_gpio_0[3:0],pad_qspi_csb_0,pad_qspi_sck_0,pad_qspi_sio_0[3:0],pad_rstn_0,pad_sram_addr_0[18:0],pad_sram_ce_bar_0,pad_sram_data_0[7:0],pad_sram_oe_bar_0,pad_sram_we_bar_0,pad_uart_rx_0,pad_uart_tx_0";
begin
end;
