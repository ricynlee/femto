// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Sun Dec 12 14:13:58 2021
// Host        : DESKTOP-95QVU9S running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim d:/Projects/femto/project/femto.srcs/sources_1/ip/mul/mul_sim_netlist.v
// Design      : mul
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "mul,mult_gen_v12_0_14,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "mult_gen_v12_0_14,Vivado 2018.2" *) 
(* NotValidForBitStream *)
module mul
   (CLK,
    A,
    B,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF p_intf:b_intf:a_intf, ASSOCIATED_RESET sclr, ASSOCIATED_CLKEN ce, FREQ_HZ 10000000, PHASE 0.000" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [15:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME b_intf, LAYERED_METADATA undef" *) input [15:0]B;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME p_intf, LAYERED_METADATA undef" *) output [15:0]P;

  wire [15:0]A;
  wire [15:0]B;
  wire CLK;
  wire [15:0]P;
  wire [47:0]NLW_U0_PCASC_UNCONNECTED;
  wire [1:0]NLW_U0_ZERO_DETECT_UNCONNECTED;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "16" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "16" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "3" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "0" *) 
  (* C_OUT_HIGH = "27" *) 
  (* C_OUT_LOW = "12" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  mul_mult_gen_v12_0_14 U0
       (.A(A),
        .B(B),
        .CE(1'b1),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(1'b0),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule

(* C_A_TYPE = "0" *) (* C_A_WIDTH = "16" *) (* C_B_TYPE = "0" *) 
(* C_B_VALUE = "10000001" *) (* C_B_WIDTH = "16" *) (* C_CCM_IMP = "0" *) 
(* C_CE_OVERRIDES_SCLR = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_SCLR = "0" *) 
(* C_HAS_ZERO_DETECT = "0" *) (* C_LATENCY = "3" *) (* C_MODEL_TYPE = "0" *) 
(* C_MULT_TYPE = "1" *) (* C_OPTIMIZE_GOAL = "0" *) (* C_OUT_HIGH = "27" *) 
(* C_OUT_LOW = "12" *) (* C_ROUND_OUTPUT = "0" *) (* C_ROUND_PT = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "artix7" *) (* ORIG_REF_NAME = "mult_gen_v12_0_14" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module mul_mult_gen_v12_0_14
   (CLK,
    A,
    B,
    CE,
    SCLR,
    ZERO_DETECT,
    P,
    PCASC);
  input CLK;
  input [15:0]A;
  input [15:0]B;
  input CE;
  input SCLR;
  output [1:0]ZERO_DETECT;
  output [15:0]P;
  output [47:0]PCASC;

  wire \<const0> ;
  wire [15:0]A;
  wire [15:0]B;
  wire CLK;
  wire [15:0]P;
  wire [47:0]NLW_i_mult_PCASC_UNCONNECTED;
  wire [1:0]NLW_i_mult_ZERO_DETECT_UNCONNECTED;

  assign PCASC[47] = \<const0> ;
  assign PCASC[46] = \<const0> ;
  assign PCASC[45] = \<const0> ;
  assign PCASC[44] = \<const0> ;
  assign PCASC[43] = \<const0> ;
  assign PCASC[42] = \<const0> ;
  assign PCASC[41] = \<const0> ;
  assign PCASC[40] = \<const0> ;
  assign PCASC[39] = \<const0> ;
  assign PCASC[38] = \<const0> ;
  assign PCASC[37] = \<const0> ;
  assign PCASC[36] = \<const0> ;
  assign PCASC[35] = \<const0> ;
  assign PCASC[34] = \<const0> ;
  assign PCASC[33] = \<const0> ;
  assign PCASC[32] = \<const0> ;
  assign PCASC[31] = \<const0> ;
  assign PCASC[30] = \<const0> ;
  assign PCASC[29] = \<const0> ;
  assign PCASC[28] = \<const0> ;
  assign PCASC[27] = \<const0> ;
  assign PCASC[26] = \<const0> ;
  assign PCASC[25] = \<const0> ;
  assign PCASC[24] = \<const0> ;
  assign PCASC[23] = \<const0> ;
  assign PCASC[22] = \<const0> ;
  assign PCASC[21] = \<const0> ;
  assign PCASC[20] = \<const0> ;
  assign PCASC[19] = \<const0> ;
  assign PCASC[18] = \<const0> ;
  assign PCASC[17] = \<const0> ;
  assign PCASC[16] = \<const0> ;
  assign PCASC[15] = \<const0> ;
  assign PCASC[14] = \<const0> ;
  assign PCASC[13] = \<const0> ;
  assign PCASC[12] = \<const0> ;
  assign PCASC[11] = \<const0> ;
  assign PCASC[10] = \<const0> ;
  assign PCASC[9] = \<const0> ;
  assign PCASC[8] = \<const0> ;
  assign PCASC[7] = \<const0> ;
  assign PCASC[6] = \<const0> ;
  assign PCASC[5] = \<const0> ;
  assign PCASC[4] = \<const0> ;
  assign PCASC[3] = \<const0> ;
  assign PCASC[2] = \<const0> ;
  assign PCASC[1] = \<const0> ;
  assign PCASC[0] = \<const0> ;
  assign ZERO_DETECT[1] = \<const0> ;
  assign ZERO_DETECT[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "16" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "16" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "3" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "0" *) 
  (* C_OUT_HIGH = "27" *) 
  (* C_OUT_LOW = "12" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  mul_mult_gen_v12_0_14_viv i_mult
       (.A(A),
        .B(B),
        .CE(1'b0),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_i_mult_PCASC_UNCONNECTED[47:0]),
        .SCLR(1'b0),
        .ZERO_DETECT(NLW_i_mult_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2015"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
Xy0rQtyFjlVkbWfeQXwuqraA3MiYyL0eFNjbY4iEa+s0Iy4tsgQeJeqb8F2nyNFI15QQro+xjbie
m+gt7LRqSA==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
ket885wFwjDLqC97HI68cpTwpD1hGBIJdkMh+rsfw+vPf59MdHJNNbcLh5jkiDAOhjCAn8l7Pljd
OAdA4DPaB1th3EEcK28Uhm8xkCE8u1JeKM+cTawL1ZqM7f5vFJDMTdaQdo2ODraPwf63iOc4O7I1
Jp0iW8w4eq4dmJxUtLQ=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
0sLRbF/nd38eurlUzps5D+y+9REEleMhJud3+B55Wgm1hYo1ntzC4vdMFNHAcAq1l46fEiE/D85o
eYPC/WuBoZraAAbt+2vzvO+6NgUIpKKrii5bWkc7zSRBw4OUgkdgOToRQnup7uEq7pNL5gER2W2q
jpbl57Ks7667W7TbtoCx+55cY2wmHeQ+Fi9eAhxvopt9UQ7JhiAITU32QV0QOUo0C5DuMrCOfUPt
Q4mY/sCujPAsGwpHpQOH6JmVeTJ9/9FBANFdHkzv6F+8T8a1pEE2+YcJXysHrFHMtW27J1ZZCZGA
hChjmCakAGz4Jve6Njfz9RKNiLrrvv0gHwgvEw==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Z45gwqdZGpYP0Kv2lPvhL9t/dewTJD5ANS61F5BSLbdhMd8PVbRummT3J9CrH0Xrbuzjih6sOpQw
kP9SCPfkWk0LECt8HjobCatSEoRRONU79HyCEoDk93VT8CY8JL1BVS13wUngEWn6CIfitTyUUXR/
CxyxtdDZQFDUfHXEX4XQ0Yn12IXvHzgVAVLyG8UmGQWtQl4u7U/ZvMszHbCI4hHi6FW2kYvzBYlf
e14GZYOKCoOlqFp/3u2vs2rSSE9ciWV/SYIJDbOxsQCcBEM+UYYOzWikcZxKJAlJhndq92g1JKTL
sQcp7SBbbJ1O6Xynuz0MZ47Dfl+F87qkHSjwDQ==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2017_05", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
AeZ3V4sxDArImz8Q4W0bdOLintyw5zFj71qsxS4fYZUiRz8fNjC87lJzQ+YnUM13/42C5tAz/W5B
5De7uFmIgyIiHZ7Y1Ljeaa49Hank9rJJwKCFDSSNL8oJL51I1jWnn7YQnA7UX2zo1TTkepqKq7HW
QLVQHxdIfz7XQJ1KYPLfGQXcsGEecPlraNmNXeykJAgtAFm5XnR8iyVOGbjm9W9BUx0070wOpVoK
DNLr58vy3yAgTwtSBr+RexJEsBPZIUDyrA9NgYHy91GC6l4e/tQMTkA5GUgHnQd/YiVINSR358nO
A3j+0MMXq+Hrg0TJtfXsqD7mdjD7gjs4pqa1Vw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
BTz6m4RfoEciTWA22aqSQ7leYhQBT580p+3gUMnEkDKrl8y/O8yBG9prYh9eaBfxpy/1/zsYPTfE
O0sD3klOHeyC81JjLy2AWCWL1sk9/7n5I9vvSHXaQP4PHYRjAzqZC2XENPD0SKyVkobaEQpad+o8
VjB8RI608B9GgMaZvYA=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
D7Hbf96be8hL6h8aH9GXSy4IzBK9xG0ri9cVSVfA+REat+znGl+3rKoWJP3Y8xVsMkc1boG+wuph
DvXt9Y8VIRQAHNgamdZlVmWFc7YNNoioXwxsiPQUGQ033qF9EQryRyyXiVxfPqJOSfqv7PrbvgOT
5UDZUXtmOWGVrgoDlz45TFPs5v+lO6i3RYt0nujylzKTS8VLhLp7chpkjrCdjQc8hZGNDkUI5WPz
T16PgMtr8+aqlEn030MgQ09L5vJki+2qisAmejQVoQ30QbY0N/13XTb4LdaYF1u53Ib59hKf/1nP
//1d/wsq1f4QJoIkaVIa2ngZqWphjv4BhaOjtw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
fhs3X5HMRBETMTfJilh6XePbZc9Hmkf9Dv4kfwMwb/B34tPhzzKYQWlvsctGxt/tCNrhWWz5LCUq
U2AXrckWaNfteIjROCxP3aja/y75xZoOcX0B3I0Rau8kCU9YXrR18KlYkgkeO+C8P+vGAhMpEu5H
p21aOwgluVqWWe+K6mMiYNneR4Bcctm4DpG/67pQAJ4sYdSpkDWO7OG0LRwvqzZFouyAh1pfNAEo
7VkcCDtqD8XA9OWsadJTkahFUIbnGvLDgtEqPlapFOFoR6a6MQnaQJZMJuMcuOXjwkMI0jIFleSt
i58HcgaljObuvjxEJ0JWeR/cvTh1j/7IGqMLLQ==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
T/xcuy/WlV3qhMyFdyO1l8jScCpQhagKcDcdtg59DTizNYpnMn+jvvf32Mf7c/ksIYSBdHS6veuz
A12bUGd2VGWQJYxtOAur9qD5/6lhE4P75xloeV80rcZtYni8TAhFtxssGvWuqEoUJ3noD/Lt1872
gp9s6Xca8us1WdCvRFhF9k9nVH8k3k9qgojgHUcwcVS/zIUJVYOuquDbvLnP04HWBoqCCMpYB2TL
61k0sEUUtmZ8EaH2YgcnI6/2xVra4MpB1W68rTP6rx95oELitbn2q51RXWPCS+2KWm02KTK+HaE4
wLBmLb5kH69oAd+qNOxXkVn6f98KJRQC/psLBg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8576)
`pragma protect data_block
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
vq+Na9Ars08SqNyqEl9gu58v8dbL9xJnq50=
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
