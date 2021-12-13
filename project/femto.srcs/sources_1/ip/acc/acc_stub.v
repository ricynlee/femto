// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Mon Dec 13 20:21:08 2021
// Host        : DESKTOP-95QVU9S running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub D:/Projects/femto/project/femto.srcs/sources_1/ip/acc/acc_stub.v
// Design      : acc
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "c_accum_v12_0_12,Vivado 2018.2" *)
module acc(B, CLK, ADD, SCLR, Q)
/* synthesis syn_black_box black_box_pad_pin="B[15:0],CLK,ADD,SCLR,Q[15:0]" */;
  input [15:0]B;
  input CLK;
  input ADD;
  input SCLR;
  output [15:0]Q;
endmodule
