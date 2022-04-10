#!python3
XLEN = 32

###############################################################################################################################
# bus slave spec
###############################################################################################################################
from sys import argv
import re

module_name = ''.join(re.findall(r'\w', argv[1]))+'_conn'

with open(argv[1], 'r') as f:
    slave = f.read()

###############################################################################################################################
# parse bus slave spec
###############################################################################################################################
def parse(slave):
    slave=re.findall(r"\w+", slave)

    names = set()
    spans = []

    result = []
    for i in range(0, len(slave), 3):
        name = slave[i+0]
        addr = int(eval(slave[i+1]))
        size = int(eval(slave[i+2].lower().replace('g', '*1024m').replace('m', '*1024k').replace('k', '*1024')))

        # validity check
        if addr<0 or addr>0xffffffff:
            print('\033[91m' + f"addr of {name} out of range" + '\033[m')
            return None
        if size & (size-1):
            print('\033[91m' + f"size of {name} should be 2's power" + '\033[m')
            return None
        if addr & (size-1):
            print('\033[91m' + f"addr of {name} conflicts with size" + '\033[m')
            return None
        if name in names:
            print('\033[91m' + f"bus slave {name} is not unique" + '\033[m')
            return None
        else:
            names.add(name)
        for span in spans:
            if (span[0]==addr) or (span[0]<addr and span[0]+span[1]-1>=addr) or (addr<span[0] and addr+size-1>=span[0]):
                print('\033[91m' + f"addr span of {name} overlaps another's" + '\033[m')
                return None
        spans.append([addr, size])

        result.append([name, addr, size])
    return result

slave = parse(slave)
slaves = slave # alias

###############################################################################################################################
# generate hdl
###############################################################################################################################
from math import log2

f=open(f'{module_name}.v', 'w')

f.write(r'''`include "timescale.vh"
`include "femto.vh"
''')

f.write(f"""
module {module_name} # (
    parameter SLAVE_CNT = {len(slaves)},
""")

for i in range(len(slaves)):
    s = slave[i]
    f.write(f"""    parameter {s[0]}_BASE = {XLEN}'h{s[1]:08x},
    parameter {s[0]}_SPAN = {int(log2(s[2]))}{'' if i+1==len(slaves) else ','}
""")

f.write(""") (""")

f.write("""
    input wire clk,
    input wire rstn,

    input wire m_req,
    input wire[`XLEN-1:0] m_addr,
    input wire m_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] m_acc,
    input wire[`BUS_WIDTH-1:0] m_wdata,
    output wire m_resp,
    output reg[`BUS_WIDTH-1:0] m_rdata,
    output wire m_fault, // fault indicator from submodule
""")

for s in slaves:
    f.write(f"""
    output wire s_{s[0]}_req,
    output wire[{s[0]}_SPAN-1:0] s_{s[0]}_addr,
    output wire s_{s[0]}_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_{s[0]}_acc,
    output wire[`BUS_WIDTH-1:0] s_{s[0]}_wdata,
    input wire s_{s[0]}_resp,
    input wire[`BUS_WIDTH-1:0] s_{s[0]}_rdata,
    input wire s_{s[0]}_fault,
""")

f.write("""
    output wire bus_fault // no bus slave is selected
);""")

f.write("""
    // req demux
    wire[SLAVE_CNT-1:0] bus_slave_sel;
""")

for i in range(len(slaves)):
    s = slave[i]
    f.write(f"""    assign bus_slave_sel[{i}] = ((m_addr & ~{{{{`XLEN-{s[0]}_SPAN{{1'b0}}}}, {{{s[0]}_SPAN{{1'b1}}}}}}) == {s[0]}_BASE);
    assign s_{s[0]}_req = m_req & bus_slave_sel[{i}];
    assign s_{s[0]}_addr = m_addr[{s[0]}_SPAN-1:0];
    assign s_{s[0]}_w_rb = m_w_rb;
    assign s_{s[0]}_acc = m_acc;
    assign s_{s[0]}_wdata = m_wdata;
""")

f.write("""
    assign bus_fault = m_req & ~|bus_slave_sel;
""")

f.write('''
    // resp mux
    always @ (*) begin
''')

for i in range(len(slaves)):
    s = slave[i]
    f.write(f"""        {'if' if i==0 else 'else' if i+1==len(slaves) else 'else if'}{'' if i+1==len(slaves) else (' (s_'+s[0]+'_resp)')} m_rdata = s_{s[0]}_rdata;
""")

f.write('''    end

''')

f.write('    assign m_resp = |{' + ', '.join([f's_{s[0]}_resp' for s in slaves]) + '''};
''')
f.write('    assign m_fault = |{' + ', '.join([f's_{s[0]}_fault' for s in slaves]) + '''};
''')

f.write("""endmodule
""")

f.close()

print(f'output to {module_name}.v')
