-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
-- Date        : Sun Dec 12 14:09:28 2021
-- Host        : DESKTOP-95QVU9S running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub d:/Projects/femto/project/femto.srcs/sources_1/ip/acc/acc_stub.vhdl
-- Design      : acc
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity acc is
  Port ( 
    B : in STD_LOGIC_VECTOR ( 15 downto 0 );
    CLK : in STD_LOGIC;
    ADD : in STD_LOGIC;
    BYPASS : in STD_LOGIC;
    SCLR : in STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );

end acc;

architecture stub of acc is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "B[15:0],CLK,ADD,BYPASS,SCLR,Q[15:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "c_accum_v12_0_12,Vivado 2018.2";
begin
end;
