# encoding:utf8

########################################################
# This Python3 script is used to generate EIC of femto #
########################################################

XLEN = 32 # RISCV XLEN
EISN = 4  # External Input Source Number of EIC

from sys import argv, stderr
from math import log, ceil

if len(argv)==2:
    EISN = int(argv[1])
elif len(argv)==3:
    XLEN = int(argv[1])
    EISN = int(argv[2])

if XLEN<=0 or EISN<=0 or XLEN<EISN:
    print("\033[91m"+"[ERROR] Values do not meet (XLEN>0 and EISN>0 and XLEN>=EISN)"+"\033[m", file=stderr)
    exit()

print(f"// This file is generated with {argv[0]}")
print(f"// XLEN = {XLEN}, EISN = {EISN}")
print(f"""
module extint_controller # (
    parameter INFO_TYPE = \"number\" // \"number\", \"flag\"
)(
    input wire clk,
    input wire rstn,
    // core interface
    output wire       ext_int_trigger,
    output wire[{XLEN-1}:0] ext_int_info,
    input wire        ext_int_handled,
    // ip interface
    input wire[{EISN-1}:0] ext_int_from // int from ip, posedge active
);
    // interrupt posedge detection
    wire[{EISN-1}:0] ext_int_pulse;
    begin:PEDGE_DETECT
        reg[{EISN-1}:0] prev_ext_int_from;
        always @ (posedge clk) begin
            if (~rstn) begin
                prev_ext_int_from <= {EISN}\'d0;
            end else begin
                prev_ext_int_from <= ext_int_from;
            end
        end
        assign ext_int_pulse = ~prev_ext_int_from & ext_int_from;
    end // PEDGE_DETECT

    // interrupt flag: one-hot interrupt number
    wire[{XLEN-1}:0] ext_int_flag;
    wire       ext_int_flag_vld;
    begin: IFLAG_HANDLER
        reg[{EISN-1}:0]  ext_int;
        wire[{EISN-1}:0] ext_int_minus_one = ext_int-1'b1;
        wire[{EISN-1}:0] ext_int_after_handled = ext_int_minus_one & ext_int;
        wire[{EISN-1}:0] ext_int_to_be_handled = ~ext_int_minus_one & ext_int;
        always @ (posedge clk) begin
            if (~rstn) begin
                ext_int <= {EISN}\'d0;
            end else begin
                ext_int <= (ext_int_handled ? ext_int_after_handled : ext_int) | ext_int_pulse;
            end
        end

        assign ext_int_flag = """ + ("ext_int_to_be_handled" if EISN==XLEN else f"{{{XLEN-EISN}\'d0, ext_int_to_be_handled}}") + ";" + f"""
        assign ext_int_flag_vld = |ext_int;
    end // IFLAG_HANDLER""")

INUM_WIDTH = ceil(log(EISN,2))

print(f"""
    generate
        if (INFO_TYPE=="number") begin""")

if INUM_WIDTH>0:
    print(f"""            // interrupt number: binary interrupt flag
            wire[{XLEN-1}:0] ext_int_num;
            wire       ext_int_num_vld;
            begin: INUM_HANDLER
                reg[{EISN-1}:0] ext_int;
                reg""" + (" " if (EISN-1)>9 else "") + f"""      ext_int_vld;
                always @ (posedge clk) begin
                    if (~rstn) begin
                        ext_int_vld <= 1\'b0;
                    end else begin
                        ext_int <= ext_int_flag[{EISN-1}:0];
                        ext_int_vld <= ext_int_handled ? 1\'b0 : ext_int_flag_vld;
                    end
                end""")
    print("")

    for i in range(INUM_WIDTH):
        print(f"                assign ext_int_num[{i}] = |{{", end='')
        ext_int_num_i = ""
        for j in range(EISN):
            if j & 2**i:
                ext_int_num_i += f"ext_int[{j}], "
        ext_int_num_i=ext_int_num_i[:-2]
        print(f"{ext_int_num_i}}};")
    print(f"""                assign ext_int_num[{XLEN-1}:{INUM_WIDTH}] = {XLEN-INUM_WIDTH}\'d0;
                assign ext_int_num_vld = ext_int_vld;
            end // INUM_HANDLER""")
else:
    print(f"""            // interrupt number: binary interrupt flag
            wire[{XLEN-1}:0] ext_int_num = {XLEN-INUM_WIDTH}\'d0;
            wire ext_int_num_vld;
            begin: INUM_HANDLER
                reg ext_int_vld;
                always @ (posedge clk) begin
                    if (~rstn) begin
                        ext_int_vld <= 1\'b0;
                    end else begin
                        ext_int_vld <= ext_int_handled ? 1\'b0 : ext_int_flag_vld;
                    end
                end

                assign ext_int_num_vld = ext_int_vld;
            end // INUM_HANDLER""")

print(f"""
            assign ext_int_info = ext_int_num;
            assign ext_int_trigger = ext_int_num_vld;
        end else begin // INFO_TYPE==\"flag\"
            assign ext_int_info = ext_int_flag;
            assign ext_int_trigger = ext_int_flag_vld;
        end
    endgenerate
""")

print("endmodule")
