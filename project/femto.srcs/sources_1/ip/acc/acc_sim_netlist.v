// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Sun Dec 12 14:09:28 2021
// Host        : DESKTOP-95QVU9S running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim d:/Projects/femto/project/femto.srcs/sources_1/ip/acc/acc_sim_netlist.v
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
    BYPASS,
    SCLR,
    Q);
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME b_intf, LAYERED_METADATA undef" *) input [15:0]B;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF q_intf:sinit_intf:sset_intf:bypass_intf:c_in_intf:add_intf:b_intf, ASSOCIATED_RESET SCLR, ASSOCIATED_CLKEN CE, FREQ_HZ 100000000, PHASE 0.000" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 add_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME add_intf, LAYERED_METADATA undef" *) input ADD;
  (* x_interface_info = "xilinx.com:signal:data:1.0 bypass_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME bypass_intf, LAYERED_METADATA undef" *) input BYPASS;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) (* x_interface_parameter = "XIL_INTERFACENAME sclr_intf, POLARITY ACTIVE_HIGH" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 q_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME q_intf, LAYERED_METADATA undef" *) output [15:0]Q;

  wire ADD;
  wire [15:0]B;
  wire BYPASS;
  wire CLK;
  wire [15:0]Q;
  wire SCLR;

  (* C_ADD_MODE = "2" *) 
  (* C_AINIT_VAL = "0" *) 
  (* C_BYPASS_LOW = "1" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_WIDTH = "16" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_BYPASS = "1" *) 
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
        .BYPASS(BYPASS),
        .CE(1'b1),
        .CLK(CLK),
        .C_IN(1'b0),
        .Q(Q),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule

(* C_ADD_MODE = "2" *) (* C_AINIT_VAL = "0" *) (* C_BYPASS_LOW = "1" *) 
(* C_B_TYPE = "0" *) (* C_B_WIDTH = "16" *) (* C_CE_OVERRIDES_SCLR = "0" *) 
(* C_HAS_BYPASS = "1" *) (* C_HAS_CE = "0" *) (* C_HAS_C_IN = "0" *) 
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
  wire BYPASS;
  wire CLK;
  wire [15:0]Q;
  wire SCLR;

  (* C_ADD_MODE = "2" *) 
  (* C_AINIT_VAL = "0" *) 
  (* C_BYPASS_LOW = "1" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_WIDTH = "16" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_BYPASS = "1" *) 
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
        .BYPASS(BYPASS),
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
pl78l1L0+r4UZbbryOSVQekcyC70hNgxjTfsIHTUUaLzRMX5hYbQ8QCA061f1ClqzUCCyUhRdFca
LgD04vOoN8a7NDTj0EXPOusTgcDLaVms1FoQwvOMrKre3c0ilvnFnaV1aectScKuJ5mrC0aygkGd
Ka2rLq+jCFbIeMGo/1HrrD8Y7LdJKNTbnlYgiIby2w69ffYA++BwCGbNrPx0nTCbfYOyBaNFxROp
mJjc1wfPG/rfZ45Ue4LalMCo8cWyk14VX5tPLoWHmlmgfCRLHQLSybjtisNHfiVWTqoB6HW8kUzq
7RX00hF+rrMEM12q86SsSP5o7XGocVVJbS4XsA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
rUyYwYMKWviModowFRWcSJTkmYbxwEnIEIkynzOG3BlRtC/F5LQmdpH3LudPdV7Pqwl+l0pC7KFK
9qhtThSZte51LVftAqYBcUYDGkIRHD7/jEd9wQEQ7U/K3E2Gn8er/FjDHBFpTYzuTFSpdO6PS49i
RI13bu8w1CVRrrwWPawNPcTZWIxpG+eZ42rNafo1pkXfY9UMRDEj7xic/0byx4tJHq0VfdEutos1
RgZjgZVnMDXu7HKXcsfLnUAGeUqWmmhrCwdech3oich/GMkEegeUEcQ9ukvAaBfhMWKSd7jl84ev
n+Qgi7900gfLFBR6f04Pqcdvz1X6R9r4bV4kYw==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 12128)
`pragma protect data_block
HolQ631XnURM9hFR02crLZmiPRssC9R/HAZqX/sIkfs82EqGMzVaJwwFc0kpKGA9oZ/YeVSORYLZ
c+NR9Ps86FXLnT2luOtllFEtSnt3pb0ajEq8okN9Ida71C5a0FA5yvOPnIyOl97878SuBOmdz6sJ
xVjKTjYlKRJNQq0NSuqWsNebmyi4QD9f4apIWrA2M0YU/NkkUEp1KXd1NQ1IjBy6PWzkYsBVmRHo
/p2m9zMIiLZXb/1jHZ4BYKMWiwRcTKLOBSKhLl/ZC+Sm+a9bHFbsvyDAnYoPGUNbHRe3G2iQO6Q1
5FF/aVZePviW+G4pzyNsfc/DbzDUbiUrIHn0Ann2DWMnVnMbNc5HT8rT3zjgxOkPgeFuWdrAs6Tq
VtYfvCbFwGQ7xgJjtsMbmxHXblMQ4imer0E0iC4EXTyH7Io7Ks4VY6mXERgQ1m4jc1EEXgKBYOxI
GeDodNggIO8L+c3Sh+7CkyEb1u+bviayQZXhj1qQPUZJOPj3QaL+Rs5ZiHuFOyiw/SoYTUDaIZmV
tDgYr4bsH23fSOAiuXu6+62ylfB+yOqSavrfjanr3QW+XG1AcDbaQFbaeRYbLU1ZRFJhFgDvc8gc
6BzDMNwKAwgp50xWPEMxR71UMoGND5P7gEDaQjUfFRAODWTfgaqhjngRTHmyJw3NCCIXUiZLtfW+
VkqZuBKdzEhB0iAQ5fwWGD7QLS/+0Ee7VnOaXUNDS261Z3g3IdREsNVYrzeoepQGfYNugSyaznE5
6gBnb7z4FkCd7gtFjuDIHxRGXN22vtwTxWny/KNCxcvDfQu9W+CE2smheWp11lc8ND7TrHey8KpM
PjHPuytN3aP6125/iovp6LElL8wEOUpaMONCliUcSAGCwWhehpuCFdeHr1we0jNENB1zhfat3Xo+
eHtyBsSwSUjwCFixpzmV05hxgOnP3cVgd3cZFJeNFlSkFDwtWYL5INbEMOhLJBwrs2UJG5uNdkk+
CN9j8WgoE1fLacESbLLGZdebJ2kgavZM14T9KVMQ59v+WC5KITiu6tNBIrhdR9Y5eLE6P+QHFY2A
cYE/t7lscbx8skyHUr0Ea1f3WI13xoaamQzHSJahMu8tj++4o8A+AeZ1bEkD8GizE6IxaTTJQciT
56+7y2Aw9Vis85MT5b0OXddtfI1cmpcZFrMPnnULQHlw2xO0SLGbhP5pkQ5euGfCg3+QKlGAt5dG
1mLUjUytt7GSg5cNqaSEf+L+AarMKnU1hHd0bqCiO7Yhl0lZiihr7feASOroWyUmMjqSEbfJRvZw
gndEYQKXGs1qhBCbLE6YjDEJPnHlJ/OsHfdR6c/h8nPgSdokubKWuSV0mewaW61TSJLHWY1fT4yQ
1rMkMIqvYfQI706+hUN4AvSBPTxwX6MS70s8WvwA+FBtmEDchCtp+1OzKyFR5GBXE3kXlM3FNbpU
zGn4deZBtY5u0KRSQW0itFCXyQmEeZmBrYMHYIIkobY20OMKQrD2Gys3B24s+g0O0IEYGtWMfF7K
IuaFMIEchyiNBCuxGgG+1RBON6ErSc8Ab+lujKiKyjadOqnEyEEFl0rtvGP96WP5YyTJukGbAtxe
AemSn7504WetdU/jm6Qqw6oeo7uQM/veFHOiPIU7njJAsoEx8JKCD/a2TEEcwICuXuy/ivFF2kMt
QTbZCfsZo63Dx/C7WlfnU5iEDuo1BNnXmhm+l3qojQZXV24CUg0HEEgX0NtYxaWuD7Aqv8mmpHm/
NBmmamUfCCWzQtqT0zKl2CyItreXp/qfAEyx5Y0uLpa9/5atfbZ0UgUBkoEQdvHnvZoxikuegsc7
HLyLGB15MIENE36sOmX1GAr2vnyqofsx24PpubdwctpSAYL8dv+okPp7GfDxPBt5v7cTGT5gW8xy
hcMPTGCebEYeU3rKTHHvseXh4yZnHKgyBljLwJ2f7QM5pqDkh/vHGdlDw3b1NUzropexD2y49ys5
BIzBnD9nE9hLEggUNvYmd5VZL7wlMOK8IfAJ04gFrYVr9SGpjYvmBE1docSadl+uKMTfXOKszQbK
nFXPFJQ2M8yfJL6l2WR0WbQyjIUOvujXcWhOckyrq0Q2OIvp/NQMuVonTuQzQ6yn+pPNrdNHSVEf
bPYZfuKaATUz/ggKLUl4DJVJD/KQ4bxI3kNTTNiqyXtGsiWtpTgalBjrm4KvTdq22jJ0LtuHzjK6
BRWyGPHpvhMih+OnRytTI0Fv/ILDD+Ak5t2dHyrxj5zqw++NrgSsI7d+MVnaBTuRYOXVzCgFz5ZP
rzxm47mwHEg7O0+bT4KoMuuavHzVHycxGMYfbDpc6yUktC5yl3Zx61gZzWqwc16e11ki3Memmlyn
jT7MGVvrExZbvhnFOO0eWLuTcQVioG8ckfz8WXPfNotWEf6a+9NcBhTytcMfxS02Aspb+Z4HCuaV
pdB10XZ/sC1fPjlvgewiEEHgAvQ0hPQlyft1VxylcV5w1/JyYD1ONSZBJE3FED/DJWD14ioELvMW
ki7v9E9KOlUwcw8q1kXr6TjWqXDBTVuc5i2yXGU6Bw7Ebw5YWKhQcPituBCjweUgLPRuuionSI8f
SIHvgx0dTSpMgW1XILsTEj9EEG+yrMowXeIQ0+XILTA/sDCF2p5N7GmXnDQbjCIe2JKXk5wkTOnw
qGHFu60CrcfEwmRN4IPsMLi6DBpTFpO9Do+nd1iCdCf7XewkgYsNOIIvLUarcrcnL/Apx/EkHe3O
eTmWP7nN0dGYfphSkEu+bmaxpqiqvLv4kkXTbgVCklJnY/IQbv5rKVgd1XQGoemCuPsMeIBurvol
DebEk1ZpNc55Qa0NzG4gIlRqFoXtZmWms3BpvH95H/LZk7RLUU0+NszMc8Ccfu9x91zyhsacxY1Z
cKU2LAauGzTz2tWlnOme/D5uG94AnoURGdYvYHO+khahS2g+fvQo8vGQD8KjZcRAP7XLnTuxhPw0
2+pmSpKtPI88LLSMtyIDPj9F2o0gBITAdoAuFw3lzpEIIh9kj4vu53tPZFV/56bPggC0Y2rJSgrh
yvaMnBemdxdgp+uqZjMSlR0J0E08BpRv3LQOICUmi5tI7v+3pUviesLulvCSfeV6aAIwpkwZ430d
RR1/5TBb0XatHWIH8Kjx0vwlqUbZkq0T8xHC6MsipUf2ikDXpEwZBUVLA/NgiWfYZXvoMAwrQCr9
zAp5Rod3Agz1wly0mFkxscKxEMZ6D7FVGHhsgkXZYWNktXqwxywoLDUM5Nj9Ww4zk3AM5Kkx0yre
71ETho9xLJyht7uAUWD6J2nuQI9m++PXvIZMYyh8RvZ+bf5SDTdJADVc6VRusuRIYUF1KdEOJaCL
j3NcH0aFLhg2CglX9xu9p6aHD54F1hnnnDmZfdc7VBjUVi1XzuzEVILOBkS9A2RRM/TQXeqDXL8X
xVXA3uVRp0ISyYjGDrJr+gGs+simOC6hFUUKQYE+uohhtwOFcbRKV+i4sWweq3fbLDmlobGKeiK9
kh5kRMA8nK16fsXEzL0rCRQl9R5v+fEVaPjsppF+tlIz1HItz7KeHqGdVUInHH5LxjDRWSK2BH2b
n5ehXo/VHYMqYrGwENlSul4NSNyPzO7mm9N6cmwjBjuD3s4o5gj7GdieVMy5iQDbdzGtK9L/yZ5d
XtX3pcG7JcXDjbA3OtzzOpfqjWQ0CqHdJ7ePuQ6kxODWbTD/QygG1TW13x4BKBcGXyB0p0w24xDp
wLrSdC3Ga8eVmz4ZJwZe1Pj4kFJiqsDQHUCrUUYoRXvlAVb0uWG5hESicAeDDAhBzoTjKV4A0AY9
DJPhBXiu3zb9dqB6CMcmP8TdROWRDX0U6u0mOsqEyEeDpFTf1mODkxCFNTXa4gdusBli5pwcNDQ5
j3ANgYXlSd0KbK1zxeOL1LaioQZDqyOEun6CkB4izzueTwZ6HO1AQLMUkYY9AMOLxyeyU7Q8HXrD
86iGEO+sAF7afVhdZeCnhEHKLyOX+PVbkPm/QO5Yq+nL5Dahv7/Yl43ocjs64Z5WUuJyGDqjFQ2c
UmKujLDGh6vSTK0t5ez/qaExiAfbnRLbaYnjfGe+IYOBr5I4FIIeN3YPcW40DPRXXoX4jHDB71wF
2j5/utxvtG8bKoH5RBD5mGKEsVYitvClKNSKwXHH//gtDDj18Q6Shj7O3PIG+mpDcw3e6HdWwDn0
K66SbzDxD92tcum6UPvCVVDidZv9eUtyLxeBaqizFJlZ0cfdQ8nQk1JaG/B0v/jXQaNtXm7PwR8T
6umKACkEUmaBVjLKqgq+ZuG96ifHQHZussbUKivm4Ls/Kz5D41LY8kWEpWH3eUdJPqOlPhTHKlKA
shyk8KfLeQR1PSB9ZEytpLDd6z6sGPYpfn9KScfALFlOckT+XNMsUgo/L/L+3gg2ZchCF+rjcGIe
aMhe40a0z1QkF8wMkF6Ek3onvzU37ckFuQXA6T1MZz4e7SMST2P5Pq84KvtGctTxZ0EmzZehbS5L
ld8DEkF9WOgttKg4jdpEFba/n+7vpyz3mkstL3DGqGN8TEKnOn6LwUjM+f6uhiImSzxmCf3euNYy
GOyKJej1F1dlNRZ7DS+EAh3Osby2E8pws0TihWlVnQIhiacURwuoa6D6PvRB+ExliZ45aNO+ptdo
BIDWOhr4Ym3z67KzvMd1GdxcHEqLF9GiS7ITVBHsjR5ygiZmAqcHuGs3J4AuBa6+irgyo1jdPf86
H/FmuM4pnOQqIMy8E6hmJd2Fu/THm/F4KJ/H1tB5Hpvmw6t8mCH6ns+A0Zkzqqf3uXPP64/dU6IV
Z+MHsCpsva7HDM2KQNDHOlMl8czvigLsrVIDGzoSmEop9OldKSfVbVAt9sCG48lWUb7+E1FmzxA1
jyHGm3EDQMy+kLZmkmTwDUlBCASmlapIe0YmkM2QbtXsBkEGE2MdO0Cayw/Q7p24iwDtwOht1xld
MNz20aDGnS+f6VGXRKpwOL/JjgYls5Up3xMniG6bzJcaIwn44bihBYbNGSA37V35tVULYauAzRBe
Kvl7oIWmK77KCNISWcQWxWxWyZQ7V9SZBvbWOcyrtQh6hz5yyEheR/pAfEXYVmH77Rog94aRGddh
P2JK0p43/54OXlc8Hju+BrmiZ9fB7FxCdeTPHmMjH4J0I3sfIzTbw9URRRJQdx4z97UWPEIsCVB+
4NglF3dS4V+GfLTz1qWyCQZpaop5c2oCYd0ACFsVO+Ys6IFkxMJ5/54lxaAT5Kiia7kQChcDtAfR
lzqO4D74ZousFURc76V4v4u4J0I7fECMN9yNLQCuXsqt2k5RVljJr1nmEbDb5k3zUSNEY3biS9f0
K/c1dTCmzkrILnyKtgPDcev5d+Ay4vsPvkKawPU/fPTdOyfVaZqM+pHO7euTQ5bliDsBkSiAj0Vr
SKNVpokiuH6YxJ1kjGP3kz3w8c1qn8QYYVlvdT1h/S0f1ESJJv4H3Z8pa/p3VlHlDg0qq6INIyRf
eIc1b+W1S5SuWE1CPbeMsyyPMjDaCgdAnxo+Q88GuaXLA26cpnKjM/C1miuxLuMWqDCUjiAGDYSV
44EmCdS2fIOqhG7NKzJZX5e5QEQioyB14cs5laNGejIklAnqxaNuYF523SpvioV3h9Ln3ng5Mj2H
jpBkOQ3AdpRrPfQP7vFL4BSP3EvBNt+NGb+d33KJhGb+3ZU0vHqjO8xLGD2V07w1qdUPLOAnLIeq
tL7auEgEzLb1a7dNE95gACKNv4W/yVNqvexfvA8la7O+bsFP0kpI6uYYhiJkiTLBxhNqKLl2kaNP
dXbN+qvddnDzNBI17CfgP+a9oE1PzeK5wMyL0qpVMWRdV6B3P4vIIzyBda6C2A3MhHe7K1naGwaA
fYHhXIx7a1uzk+aDDD6itk6pkwuMc0UK0KO1vUl6XlC0Ivt90DrvhrqDkhZBJvYTw0vBjxGeS98V
S69BVzvtPuvrWhV3c0bY20YvRDCfFp1eFM+iJzWq2dFUtbtvcPhGdevacG83ITLU9YogcRW9OVSp
kZiUg/2RhrhWNAiMI5FmvSCjVg0UEm+IWHOvYu2LOTqEBOhs2zmOW4sWG9zrFiP1SD9O9zBS4COY
cbDV2DZ9pYPBNWNvD1GFdcWTiGZw2FPTXH809reSVoxz1r6/lduLCxZOjitz8clXkfv9GLHBcNXb
M4OcnxzWIuHSBmorOclWVhtXlDaXrgUV6d0RY8aypEzeWm0Nuxv6t9AMpBROrIyN5S0bdkUmQk0p
n2dmPnhL4JP2Jgc9I17zBUIBJ45R5ECzxyb0PLHE9chAWP5pLvFhepIZ0PHGpdHsFNxkG2gLcmY0
Aw/aUASxHVOuZpiLfjhBP7uKCYpDuKfYmLBGwk4uF1qBvHggrshPhUSJSqsGeMOY/kBGQv6Ie/8V
q1ezHNCGD/7LR3BRuZ0CY98ZIe1CixSNs0doV37TDleJhjHrM+Y1b5NNXSd4kugV+ut5+GlbtlAC
AU/Ep/4VQBUGht8h1SP6H4L+QYDKGkZXo/pzrmMuihv1XXd+5TTts0rc9ve/HBXPBNvIEHiBHH4b
TeNSDw9kKg0rlpREjTIuCHzaDz2JVWXVVaGIjMwM3RCDqS4VWtSu+b3xvVfyAxvIxR0O2Gnc9ERt
+ouMrtflzUUu8KeXP7zJ7CAw+lhcf8FUu5Sg7mGMTJgaBkRKZaoQ77aUIHh+mTiSjf8HrV7+xFT8
MGLGOJ+RhYZ6frJN1ai4hosQN+sZWZgwRhzqhS6ez82tLfH3JUMWv8Vzdf/8VqAZK7lID/q53+BV
XNoClYg9vSk9PvHDMdHVwVVJKvyYoHJeBr89IUAkUjVCbn69XdsRfWSxHvjCyYq2g3HLHUd32vHa
KqqPG52O70n9AXn59uoAtZ+OzJaZ70iELb+qX0YdylpeY/v4QX1GQ8J8Dpf56jCYTnB84RVZUbBA
3+zfq05PRfUKLtCfy4O0i2BrtJG2B6MV52oo4Uq0g16SEddGrwPCy4pZxxzsJ2fwqDwX7JK5VC+m
jUX46IKmuEj4zwY+FwCGUltOkceaIwG0QBOwwYRRyhOPuRvt6CtFak6j6wbfo6Hv6d59hQdSoC7p
Uysys18HL6oI4HawkUkF8KWFlZoTalMt/x92yu8BTI0kA5PFYym/u57s3IniXCH5kGXVsWZJTfeI
OY97PM0FJs0OjW8iNjMPjBC+LEUdW1SGKKCkQGYGlffMfWKTNTzM3qgdFSHcjdZtW8Ix/BinVhM1
z7G4/n/uGURUtX5PLuqdxTIxtBbtkSqcDPQKNkfZsuvIRG6eVx/838E9AQiP5d/j8Pacms4TEHeq
QpTyUSV3qe2CS1Ug/1tK9X1cPkvzLsKq3kmCbxkBRp/tYZI9MPmNGryt26mWjXdS3jKVVr2HWb8T
89+meNfJG/SEym8KMvBDDn4nsk3iaF1bCnvUrwyMSEQDTmBfhpXbJ+q90nNgmO/Of3S0u6W/0+dl
lfeurR2+Bnfz9a0+gCHKT0kFbMD7heQCFwC5Cy5NMbFq6lZh3o5CXhWocopQ99XhNywYLbjmuHif
0fHOnAZiHrz85+1CEk0GYXG0SE2o7yjobA1GdY3zHL0/MtKtlOWsva3WwwrFd9VJqL8ahYdnAeam
mSkPI/ay3eYcSwAzV7epcoezz/zrVzUWmLUB2Z4p+8c73Er2KInE4Y9YNCeeNVUx2e53D+SBmhyI
+vGmWprioYQtghod8YpVZdovhZcEOBrPqtQGCANmh39lBkuoFWV2ySXOEtBXEuOYy68lVT7SCsLS
TKsA/CwBYLUKm8+SprDpmWemuTkN72pOurA9bGi8Czssl62a0wsseiicc3Dbw8P9CVbt5yw8yPaJ
MFeCMe3vhzIOQqZOppxdZ04/PkhCdnFgJGsKQBgQmHiQ38FbGya9dhf9JHpPRoQZSplY48wV2NOe
JmSqZwewK1CkP8y3m8suxMz8RSPUPKs094bUoQ/7qGu60if6ELq2EG/2deIG7pvE6uZQZrPiIZOW
r+LX//u3EotaUs+8VXGBcQgm1RjnkyYzz0ivEp7HlsOsJ7IiVnZZi7RlBY7OcQnaoPwVJKaYsvpJ
rTjoop7ApQIIyie+XZ3E0RHO84QjNpO3bT84Fv0RpFgkZj6g9sef0Tfg5AXETQhXoRmz4hLsCa1j
fJ0kE0NrKT+hd/xlJqEJmNQsL888ioLzt2QhnlE+bQEEBg/DAOEksMxtkXDXLfH/B/QvLM+8wXE9
I4XqIzouXWcbtX4q2XYlqLdXNtBLTk+w4d7GIL6elIlE7/d5jd+LE3TB2HB5l90ScATwBX/8+6MU
CHcw/PVDC+RmlSp6tl6/nevC9kDPkTKKaPuYkb6bZqe/hXzxI8DtlWGGuKrCRUVRNppcHs3vYsYt
ilVYHXirb0HI+1hkETtQwJrdiv5zgS2MxTMyoYIwv/5KjHgSK7fekIJUzVgZKSnqtlpAiv8iy/fi
W4HHd0GDwtWezx+GZUBAPlyH09DvK7n7zutMN9YBjdVZ1xUuwXZkJ3YQKbCuDMr/sFHVllj4rEuQ
CYfau4ZTbi/t+7TXTpRz18btcoqBtfquhZJ/hKe1M+lpKNB0KrkQKnOfUOIcvNXrD6OJzeAV1yj+
qlA09jWli5I9RE8ajzd/llcjo4C273sfYIZkf0pUI3TFaPBczu9Ayq95dcezx6tnknXTJCYRZMiD
FSBBcVuFMySuIHRQoZ316B/fZUkIZw+CyxmEzULIVqfnawTO0hs3f90FZHgLDPdx+n+w+Cua/DWx
mm4C6CqFfwP04x6JNH63VoMyCnzJya2WKfj13lHWhLD34WX9SHJq0sZwap0DtDhxjOu7xmCJrVCZ
EGNbqbUtfyJOoGoaSpHqOxhjBrlgNq6eEMBEUmJS8EpDqZFtzwkNIEBtjD7vIqZtfnXErUKf+Uhw
RPrgVUyEIHjRfGsXeOtFMB0A2qFFjNTLHz4fggPDDCjWxiQ/uIfZ8ZmJDE+wTLDGxwbz644s3B95
zECD4dTc+JT5VRBSiGwv9KUwWMOMihi8ys2NNO5qSOU9wWigQFMc1j0aqTsfxuUXHVPVrPIQ7h0X
1n7Zc+6sNnvLfdcCg25HtNUy6O9AugcCIBXD+AespVcaH0nhKbLHDQVvTW3sorC74dnHpWEBGnuU
GmWGD7+zWYJJpPQWdqKhgaNpepL8Bt6tgDJQL99km73yjt77VYpVmlw9TlUPqVjVFmdVnldVn9A5
0lAzUI73yT+1WnKLyOwsk27V8P5V1Qqtlq9SM32vu8qtZ9qcj6JYjfU/m4FmMEzbMSAJjnHKja2a
pqKZ38dtBOMLlDrXhSGdDQDtz4wqKApL+LKHTdnEGMGsedXOg9qBHzUIdlSU/oDIvDloZZLOEFb+
VFMvUgi3EiwvN2sIJRPb3tfqE3V/dFoC7sBO2Nr0/g4kXaLajhV0iw+WSh0BA0er5dZYKo62Ag05
gv2CcSo2824aaAkyoUXt244yiaO5SniV7Dh1l0neJ3Y64HK1FBUPNcbSlXylUZDh7baNIIQPf2Qi
+Ia/mA4xMl6kkpsiNpn0wIHCl08WmeuvbrtzvwjVB6mwsnZgakslePzrMJ35hORq1Ty+aesNdKJ/
KvJAjNZGNF4DnWWVkrOqaN6R6NC8RUtemevWr6QrK8+X0HgFcNhjxQLXOWe8Rck19/x9Mjat99bD
x/eyNFPwUWt6iNJ+wf9PT+GAZ1eVlhEV6k6C0pndy2Lizm6GZOzohdZm+hCn0tm6jKlkxj+DxTaF
LO392pWLv6geG7O2ExjsV/82wDKNwPuSk+A683eS8RDhJE/MOJo1l1TDG9eQzTAbaoSiVB6L/wjq
Tf0gocGLxlakBZzusbKc7rIjTafISpgjOW9N2yADS9hXkYAO80VoNju3NlnSJaSdXx3Wrh0ng7lQ
BtdQlUC2pZhHIJag/zjp1KrDxylIMq70n3E6YhYBsVAkE/wIV1JY9orC2cuU5OPHnmWODJ6UCpdZ
ocgEBbW5zcL/+qJn6qWEwkCn51uCHT+/olytsCz3//xNJbzEmMcCeBvpN5uzGJAg3hCTuPb2JF97
M92+JylDAANRb0qJUnJHIehD4wOOHcKIhQILX3UFF0E92/pOO3Pi5J8jCkz3t38DZhQczfHZsR1r
76BGwtEIXEQYfGSk86zdlAZrsOfvz8l7NK3OZ5JBnmd5LnS5wSyf+QzdeVqIwXsv+4g/TFpMaedE
TAEAMQc2AJ89K5VNRIJOoBc9HmIwkOJF4xkn+TElO75OS0QUNGw0hyrK1x5uW+3zKiQSg7xGme6T
1Y1ixHdzK1/Y7Xfcfg/y/y+qBUJlV3955KGG/PxdWOMenU096ZVJI3zPzQ3QG44cYVmOxAhoAZqV
R+BiulGgx+nNmSidsmGKteFqFwmpY8mt7HTEi8POAuWOcFcuSLfQM10YWCV1giPAPDLBub2r+whq
uY6AH6acnYOAdlFap4c0e6PCpqkQxi1c8R2iq65VPK59AE8W0VSESEO8GJJOoMipXGZ7hsR0+dwR
FvSmUSDImHoZBOAgUO/fQ5rUhKx/U2nsZ9EhOLaEz5M9M9iDN+V8UrI+nKw7wDli7lp4AUoxvDv8
G/Z4JCdwefhXf0teLvb9UyrqNBvRJ28EgTM6sTD1ld326thUXhGJMwe4YaUsFEVJGkXz/S6kiRG3
yKsanF+Alo/2xkrhARgOXzCmQeGih9KUMpOVDayyB8Mvup6b9PVcMkm44Vj/iMEcPiVSiGnPN8tF
pxFfAr5zpJr7pY2fCs6aSHCjCxrmNiXFwU2VkSJ3YBQ6lwuuSUwhRceH+a6ifvAMVKXbynLHUfeT
ErkDYv6mH1GJbZV8zpnjNn6sVmaR3cdTAzx6D2yhzkndGGUg1TQtqPUtF55MNkheoHdEhApFAKt+
ro8WTodxpI3S/LyTfM12lh+1Ng08cvnB4JrHziI59h4k7dWYdDQ7Js8GfyLuSwg09Krf2PBhxHpH
O0CRnG/2/OaXEGpPyrBoDqUQevotwIuVZSUdxxKBISpHglaHFiaXJnxQIhEHtEJCIJyQQkqXnRbb
zvuW4GnOEw2aeZOL/mboY7P1i0pkxdbLHA/4iXGEFvUooRDGDadVvYLgZzRrAj0+l7uwGZ3QpPXn
CGeGp0wB3DrE+cTpqRLTuixKXp1+u5aEj4PNFw9RhWSS224jNJhPcD6EACs0i+kzuuINI3vyswCj
yKK6F6KcZ97OQONcgm2j1EpRACVu+q3z636dQIcuqVoMWYfpEcNP2YORo1G7ZdqcRDaqFdUekL7p
y7UfsDjw9ZlpTOpktjKAwgVxaASrYBDtmLfxIYVnlV5rBczqVUw3GWi4NfsuA3cY5N8Vq4XxT4L0
/Jrzlza7nCipmd4c5lXSADM7eduF9S5fy0u8436ocbJwjw1xBbdbp5dniveT0uXfWNSAL2Tp6A1P
Ahg1sU7pmQTShLviQpRtcdijUha2R/EN+A058sTITHkpABMVnOZmqymACGq9Syt8jbU7EnRj/KGF
Q1a7qjlxif4P6MZDrWsRFvSFvM4vm+Hggea9Foo/W9fBkK4VF5zq31RD5myiG+z2Nmd5hXgeGxLQ
QXpHwYqqtICMMVok8lR5/Ky/cO9OaqMcz/EZAs/WA9pNwgqGgH7W8zP7jl0fgZu5JE0EJrsv12nu
HYIC2SibDj4B1OiIfSvwhfHK3h/zc+/TD+6a+hbSYOCN/EvBpNLzOsIFkM+dJvyHtrhNKzWTmWAH
0A9GIaWvHDVnCARkuSs+hYAUhfao1kgk7KY1Md1cz1bkZ2GImqCV6Fi0wxfoyM6RvTYByu1iLXnO
+SRtYjH31toiWmm4aoKHMRtZDLRBTP9OdkV/LUbDJMzbDhZjVgJaa/qBYPqGE/5x3jEl2VIPHt03
rA6eOySXofBKrgvHhPhOdp619mLuuAEwFaiZU+q+N3P5v3xQoaf001ySzVFWvw8b3iqxDb5qILAw
wnEOnKINHYy+WIODDIHkbRMYH58cKGQ33MoTcaEKgmV42LD0jvmyo1njW0CKLZOBevDJueF9WtG8
dUMAkZHxeJg50BnmZxQT60on33gGXO83kCoicPPnXlXyBCinidI8Grdj3RjiFfsmtKYWOVQJ0BnM
dZ/3EEJmkKHUirbIs8N4SMI8LWfqWdI944ZVomecGifQYXWgJYewcpc4ewOqmBsLsD2I+Vy9TONn
AdMJjmCeyWidsY5hTpjn1qudzOpExKohj42VlDIXL2Vo7haFsoQG5U6f7Oru23UShuvKqN8Pte6M
t+0GymI7apGOBs72PlpYs8HoCjUVRXYeKfD/9lfkgD0icZyLw1qZ1bEaRMekJvBuN/94obXyATKJ
FzZahZNVsIYly7+5YkzTBfjPXprnymNpCEviu/QEa9Rzsqgd+UF1drkjUyyZWswMwyF4CjVbqkZi
4UgfKVhG6oWPK6eoZAXwDicZcxBwDuvDL0wlQy020K+bhLEfxRWTO4yPi1OTry+UQJJkmygYypIB
7FX2t9cC5IO73BEjEYFcJo72QE3ekOdr7wy8f+nAY1sRutmlqKpLQEu2SIVpvDfjKrgvaYAQDZyo
MIgepvm9kWlPcicrICt6HhLEozq0Li33wlZ7O3xSrX8krW/Gy/qANddEsjTMzkFjf8OOybquZ9d4
g+caKrYF8qOVMNLdv2uinQipj6OBRd2zXERuXKf1wHR+8PlQNrZQn6ODy26rD3pTIgegU3oRynMh
XzQwHgZ16Foa5+10t3efhugUs+L2dgl3T+o7aBn8KR7nnGsJSSHyBUP4WTPKVPJzWw0sYTxrPQnP
sI0H62qO0zv7khLO58t9HFFcF4ALgmAwRMrtibyUufJss/uq4ACQ+Rh+DpXpaPv5y6Gh8A8AxFmD
Gp8Gfs/+jLVluxOLGpISKfna86TYe0P+3rEH/s7HaFT53YEVWlUH2iECfGW/ht7Movd2abhZ5tnV
JxDLZoNSBJXU3l98U1pp9dex8ViMt/8JMLAR/squD3B7q91HzSMjIMtZIDqnPV4JXiEXww3lKdmW
lCrILxmops7kaK+QZbGbTnvfsW1RhXcSiAqwuaKqtrCj4xHQpDsBvlGGLJ1pWsyOIXhYEEDKFDrt
Ce5Ze880/WESoggRg9NY4adCq68EsTZQft46/2SRbX9GJD9i0yWL07D/k6bTM5pjqHPrvdfAdNq6
snOkRNkMAUgX8pmE+UCGrAtboB7bmibqaY9ucIp/XnB2uyg+pIufMcEUTLRhvNtNfhB4V6OryLSh
iv7GwU+S3bqnJTssnKtgcUchReQbIQuYbS0pAyg9vUYYIvJmojNfH4/FJEhlcrtE6cuo/Eqos/+y
4eEQUUBCZLWvQrUyGOdk1WHXomFXN30p7WuvgCbJBhdBsh5xc5K7zr7hBHcXR3RN+pTf1gL3TFhJ
3igLDuzk+B6Ew1ng+K3IA2zzXI7NCP7ZC1ziEPHLJzXeKyjbVIkMEqXcsVIcl+Z8ZNZo1uIKWAND
xcDzdY67LsC2MiesBhK86gNbBpxnPx7NnKCbP4nW4rwD12YqHsqdRHnYn34xPv8XBzLk2uuuomm3
XwbmUxDDLV49AxEy/T8y7/Q76FIglbYWtqXyCt9V0DGBYYTZPyvJEkpp1QKHDEJhaBZrdh0+4t8h
8TXgoGT4w1Le3VHyftn0myiZ69Hy/3pYGb1uyhZApLVCaQyC3b3tnIXv6UIffjjX/tUWFjOvON+m
cJDCltg5Sy+lsJswsi2aotw9Fm4gy1BV+kqmUCODY8wvn398rmR75BuC930NjToqytvVLsBK7WbU
pXDjUWZyRBTiRKHZWpqj+nAsOj7hbFFwUu1+ZPjswYOctpjIRjlGdIU5C4nhdTCPK0Yh0Mta45yE
ZsSM+ucJjhO/hZNAmnHC/y4TdVQ3qsPnRAZIS23WTwwO6OLR8ykBUQBLCbtYNa7pHoUZOck2Z/Pj
Xc6krqZgTpAM3h8/NG9DUUOMnTIvZrho2i8gUqZ1CDj5rpaHybcSXxWWStnyzj0qjoAcmK0ldZfi
c8sHJhh6FI/nrY7I+PEChG+xBpMJxp8LAd1C3XezzDtl6eOE7mpMGkS0Fp7hCXRf87CbQEbI86y5
vtCAiHP6DeWTUcoB64erHHQSLDAzHhcO7F2ml3of4CTXEmu2mQTTm11nyGEUAU63hwDN0mPqlpSm
1J3F4XoWW6SJ1VSg5/zvA9238Y1hvxE3K/q++/p7ft2S3ryANhwdgLaTOhI8vxgcTu0ILkDItIaw
aNm7BEWBApxc6Lz47tjqjZdDA/AztUnzCRsPiCazmUp6yqwUN3aOQB2orDcdg54H8sgFTLh0ztlo
cAjE2r7z0yRJB9eWrIIQ/ziF1EB+UagekgD7zKFvzjRflfSF2lz0EkjGy1PTmAx3hYhYd7U/jdmm
acupx18idRdmkRUl1citrsbscB/zSuSfZkTzR9xouvPfyB0jVeorWiFYh/uVOWKbToIMtUGlVfRI
hH/4tG+neW7aDpuPLtpxHuUKRXCLoHx78E4mdsy6MnRGQ4rPSHzBh0Y+aGRuLgMF7zDutfLCXZa6
jBPVzAWvZrB1FAewLEE/ShrGvxnYwLeeQJ1p9arbPYXAunzbS/vnYhNYx9Vjqiv1XcDI4UMff1gE
efN144oSwqoxbD9zRFDdf9qPr0CnyFRTBre8oCqHVYZJJOFU52ZUQB2O59crDmGPsei12Jw67Q7R
xpsyCDatEJbb0xl+PhCPTTI+ZGnQxcowZ09KFm4Z7sgTGwkKnXM5LUTaLL4HL9aoo+BcFE2eKWBg
CfXZCIMzGFh29/HcoTz8vxmptl4Ne5yrr2pIT8uR3+62nE2H6ty6QjF75aLTTfBnLyMvz2JyeCel
S8T5SbSJj0wUYWgopCFBJGT5Ke2yTNych0U157E5j0Yo5sJIFNhHfCvMqUG2ciGPCjntoaiZKlde
lgkqr6iU/AVG8hvurawIv4nfdCJrirMhW8wbqAMn4EGoouwGFlX1U8CBy6s5jtgyJgF7i/RGYvEQ
IeVzDq3NymGuu23miWvH/q3NKFH4VAzX0pclxYQFGT9F80L/bbIkUrJDVjF7Uvbi8x4WlXaWFkub
NrPzmyUMsCfRMDV9fg7ZoQMRqtvOXOluyB7saNT11bjKLocCZ8osUXFm3CCpnpMPhNmTljM9TR0R
Y8bU9YnAvwAkTn55edgIQHnEuejv46e2OwNLFHqy9/Nvq4iqzyvDTMmijIHyPlNeFUdeDACx03s+
LadMJBmiMdHcveaqpvYPf4Urnsad+xhHkm1JUIjWfoK1jOt3mDstqkSMy6hedHdRUI5Jo7gZ0GiD
E0F0zHdSyBw3pHr5GFmUw/npQP5qtOlr4qlObMSaGvbSh/6YnE3VyElMCPbKiO3HDvRt/bBf2Oqk
rqkKhkLhLZR4RP66o/f5dPMnxWN9kO6RxSgwrRDbGTSAAWvPm8US7nvihncB2DASIdiEqAPA0rSM
S05WNLvx9pQGORN0lhlnV+//VK1REtmU10Pac2pB/W/cih2S8FP6pjRusI4coFwEKC8z6qjLunCb
kHm4yrK2NTpq4YWNgpu8WNj5T9s11xhpsN8YyEy6qKZL6ti3HFshY+CYCK6oyEmicKs81d3D6es+
KhRSQLPx8VmO23VF4hiOBzARA9q7cP1Vx5j2PcP09wnna0w8BgB9E+jm1+BCnf0+lnXy6z5iCdjk
hchR7+SGwcADK9u3m8ctabeFeDjzqSVOtIBvjAhjh/O/2YKC/bubnDI4gYwyAXleR2tXhlaQe92M
RpT5vg7SRpcf2A7PeE6pFluVzAHmJUkmR+CcyVlg2uOM7mzHrFb1KDwCEnfKzZAI1/lipiTX/cX8
9VxqDUxPLY4mBELJsp1LVEVIMFylRp2vqAiIqc06wl3pK8Bgvaihon3aKaIw0jELjQoOoRQP4FeG
5FSEPfNPxfOnZ09nWFRRxmXGJUMhPUTu48z754eOLYPHR1fr5BAx1QFNPh+GppETCiYHnYew31JC
kkALA060uYERxa+PylS9qwWU8L2bxEQETMsa4fnCVUG7MSD+jSFJrjfk4gD3D/dq8WqextLmKQyx
nnrOzY4YmOQVju7bthQTD5nmiv2bTK4D+qWQC38INHnX+krc0P47thAW3jU1WqXW/9wYgJvIe/M7
yCoDpS12b6F2Ixw8XFqfJfURjl+JV1kkprar4pVebM1+hYNcf7VeN5H5Pd4=
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
