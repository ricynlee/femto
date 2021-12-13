// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Mon Dec 13 20:21:08 2021
// Host        : DESKTOP-95QVU9S running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim D:/Projects/femto/project/femto.srcs/sources_1/ip/acc/acc_sim_netlist.v
// Design      : acc
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "acc,c_accum_v12_0_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_accum_v12_0_12,Vivado 2018.2" *) 
(* NotValidForBitStream *)
module acc
   (B,
    CLK,
    ADD,
    SCLR,
    Q);
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME b_intf, LAYERED_METADATA undef" *) input [15:0]B;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF q_intf:sinit_intf:sset_intf:bypass_intf:c_in_intf:add_intf:b_intf, ASSOCIATED_RESET SCLR, ASSOCIATED_CLKEN CE, FREQ_HZ 100000000, PHASE 0.000" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 add_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME add_intf, LAYERED_METADATA undef" *) input ADD;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) (* x_interface_parameter = "XIL_INTERFACENAME sclr_intf, POLARITY ACTIVE_HIGH" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 q_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME q_intf, LAYERED_METADATA undef" *) output [15:0]Q;

  wire ADD;
  wire [15:0]B;
  wire CLK;
  wire [15:0]Q;
  wire SCLR;

  (* C_ADD_MODE = "2" *) 
  (* C_AINIT_VAL = "0" *) 
  (* C_BYPASS_LOW = "0" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_WIDTH = "16" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_BYPASS = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_C_IN = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_IMPLEMENTATION = "1" *) 
  (* C_LATENCY = "2" *) 
  (* C_OUT_WIDTH = "16" *) 
  (* C_SCALE = "0" *) 
  (* C_SCLR_OVERRIDES_SSET = "1" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  acc_c_accum_v12_0_12 U0
       (.ADD(ADD),
        .B(B),
        .BYPASS(1'b0),
        .CE(1'b1),
        .CLK(CLK),
        .C_IN(1'b0),
        .Q(Q),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule

(* C_ADD_MODE = "2" *) (* C_AINIT_VAL = "0" *) (* C_BYPASS_LOW = "0" *) 
(* C_B_TYPE = "0" *) (* C_B_WIDTH = "16" *) (* C_CE_OVERRIDES_SCLR = "0" *) 
(* C_HAS_BYPASS = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_C_IN = "0" *) 
(* C_HAS_SCLR = "1" *) (* C_HAS_SINIT = "0" *) (* C_HAS_SSET = "0" *) 
(* C_IMPLEMENTATION = "1" *) (* C_LATENCY = "2" *) (* C_OUT_WIDTH = "16" *) 
(* C_SCALE = "0" *) (* C_SCLR_OVERRIDES_SSET = "1" *) (* C_SINIT_VAL = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "artix7" *) (* ORIG_REF_NAME = "c_accum_v12_0_12" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module acc_c_accum_v12_0_12
   (B,
    CLK,
    ADD,
    C_IN,
    CE,
    BYPASS,
    SCLR,
    SSET,
    SINIT,
    Q);
  input [15:0]B;
  input CLK;
  input ADD;
  input C_IN;
  input CE;
  input BYPASS;
  input SCLR;
  input SSET;
  input SINIT;
  output [15:0]Q;

  wire ADD;
  wire [15:0]B;
  wire CLK;
  wire [15:0]Q;
  wire SCLR;

  (* C_ADD_MODE = "2" *) 
  (* C_AINIT_VAL = "0" *) 
  (* C_BYPASS_LOW = "0" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_WIDTH = "16" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_BYPASS = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_C_IN = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_IMPLEMENTATION = "1" *) 
  (* C_LATENCY = "2" *) 
  (* C_OUT_WIDTH = "16" *) 
  (* C_SCALE = "0" *) 
  (* C_SCLR_OVERRIDES_SSET = "1" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  acc_c_accum_v12_0_12_viv i_synth
       (.ADD(ADD),
        .B(B),
        .BYPASS(1'b0),
        .CE(1'b0),
        .CLK(CLK),
        .C_IN(1'b0),
        .Q(Q),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2015"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
XEl4RGRmXr454l47c3QqGf0VXqdY7RpRQvT23l8+HNHsx7bUfIwCiowVDefjF43KR3GTlh0fCuD4
P4iUHvGY1Q==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
aRmFx+Z0JxGHcSHl7if4dJe8Trlk0l75f9SXXl49d59jxtO3roSVumb3b/Y020ze4m+RC4Kvm7na
yvn9B+i8wpYDSxjYSvzO5H3YE15N87LQ3i4MTVvkVnqWZIsrGsNkUplIMUL/rMFxzEudJOIm0eyr
9RqIvQaCA5jrUgwFYFs=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
bc8IMYq32AWHQRie8XOvS6yaEd6rN3FWQyTDoUHmw5W9JwWNiBTD+E1tX5wOu6fHqS75s/7wJtY8
tlLjKYb0szr7LlCppgRCvFADs4govu+W/3olKKxk1uJSgJPHy/ltWCmP0ubFEn/SZFHCe8K6V1Tj
wP2d2prUlL1d5+LWRp319nFJAR3lAD4ft2EMNeCHHrjX7lo976vFRjduaRrP5aFNN1cI1Fiphkci
XTCHJX/9odvA2+/EXH8H4c2bxAdbsP+UMKGxII2QU03Tlew/T2K/zh8pcw/3piFlIrqHXV3TExtH
59SictN0m7ZWtXb0IPeyRXfPzW0OFNZA8UU8dA==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
vcAxd3yxngOXKjwNmlV32VnnCHSx9syezffYLUYK2JzyyLeV2vAAxi6wB9Hte00/S4GLu1IjsG1v
DbqRt9aGDeBkwpE/VukTOIFsfFz89zN8Voyd56uWXSzWV9tMKny1B5lnxW7MbF1efCvxv1v6zamD
mmi0O1ksugYnXgYw4C9TakiLJ7x5SHHmBzW4zJje7PrEGz/mUiuTAKCCchWNvNtpyI23jtleq0lB
a5a0Y0Qk2T5709S+Fl9QGFnfuxztf1iXctsBTudyGDRcyXg8vaH+gJq0/QuXp/bCZ7pOYvkmAkIJ
yQqCEKkLPWIiGhi8uzeNZ+95jRV+zSJw0rLpmw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2017_05", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
sm+qrX+gtlIPYpkxrk+YmPC5ghqWfhBSIDe5EHjt7sTPfukw9AZwDQnud6PmzjqX4PpwIQnh7hkN
TcsWJYU7ubEZFDxkjFbdRZbPS0qnxcJutJT4CWo5BUDSxtwh9mVNUlBkF9NmSk+AffoZch8bftx1
rDtXYSpFqrpsM7OpuyvW4YRoIrX822ZFql6gniL1B0nWcE3B30ci8eHl6EI5GR/3Ikb0CU4dANSe
GjxwXWqqyk+T3erWS1d2yOtLzQ/QtYnbvoJQgTWN3LbTVcnyv/Rw7fdtXUY/1mfygrzkZuej9SDp
KVQTqSMJ6AZZ/7R31TIj6bBHeiTYkjSObjCnSA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
fiLLgodKzAFAWD9ZGasRAOSqnpajR2q5K1rqZkWksu4QsnsYwf8C5nwz36/mPGyiZt/cABH41jWC
Khpoa1J/pmIuT1m8JJlBSiXq7JwFihIeCBNhbxkSnUnSpfFot+6YKRTCBV0JKmiyFV3zeDoNrQSg
xSku+X8ag1JlDyYrkBY=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
LvRRSYIGTiOnSUK6q8TMmL9GyWl4L9AD6lrv/EYeUMENPhnso5c7L9UYVwB4kS6xa0z0ebN3SdlR
QHSOvEe+VWcD2ErwxnXYP5/KGyObIqKoVMl1ctJpVSnsclQNOQalKRie6Togsy+FzakHjlYxQmGa
ejOGDQpnCpz5d6/UrJNHnliLH26hYiZiLZru5H6GEIM1E0rDwTMVPpc4L/oesN7TbvOzsafiMbwd
phCMyz2wNwgB3cCWpT/dbY89/2+mhCODAxQGFAaLNn6JOn/SBzbwTdvmOaX0V10IIlzFQvvDZNCF
8XyOSkDKF4W5a14vg5uZh2ZORRJq3nGWvg6rMw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
NY6UoJOGw0t78VgwBtzk/wkLAdf6o0LnxTD6BQ6OG0nSz2nozrOTwIZ9Fq57C3TMObjfWf8hISmm
68Zmj3BTg94I4JwwmjLsFkFKPwxYcaAT+JdWxcZ86Su0sxuVzopeUQ6pwIE2r4ixhLg0nDy9Ffbc
8tSWsu8mb1x5q7OFt3q0YthnHJ53vOQP5Lj8o4L/w0yGIBfpqc1J92vGJotSac/v2rGE/0E+MILv
VqURBCuf28WkajjVidSDRwhxjE2erwrPVT7T+duXRYht6nsUjslYvg2W/FakxM6g86UJJbxAFmt1
V3uMaYk1uwyMoR6KlmqkNmtCU55m04zj8u1ndg==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
6GgGzLz+pzFQ0gcQEWbZkMbczxKKWCAWsiwD4EfprwpLAtVl1Ks5h5QKKPjwcnGTcScLYfVoYPNO
VhVnxDc95gp5312PLD7xnJrbtY4DRfcKZy7UjUyIICMI/6WpEgEKAs04uTccwwkdpVDWBjoG/7lJ
XmfdW4tP7cBd7XGwqfTT97Rmbex8eTUn0LqISiLpFzQH6G/pc7cboJ40bMTt8eCoj9gGsDeECAIL
sh7PSqnKuG2KEG4gIb+f1+KytVcDL1E6LlDuabIgc+9E8GnF13TPUzRi1pAdyd2+3TRJtYa8bLun
6fiZ7i/CPgd7ebypIdvr+QzyDcJVI80dEnW/hw==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 11760)
`pragma protect data_block
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
CIEys8e/BBPOjrV1fqVZnOGT
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
