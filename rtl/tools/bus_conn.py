#!python3
XLEN = 32

###############################################################################################################################
# bus spec
###############################################################################################################################
from sys import argv

module_name = argv[1]
slaves = argv[2:]

###############################################################################################################################
# generate hdl
###############################################################################################################################
f=open(f'{module_name}.v', 'w')

f.write(r'''`include "timescale.vh"
`include "femto.vh"
''')

f.write(f"""
module {module_name} # (
""")

slave = slaves
for i in range(len(slaves)):
    s = slave[i]
    f.write(f"""    parameter {s.upper()}_BASE = `{s.upper()}_BASE,
    parameter {s.upper()}_SPAN = $clog2(`{s.upper()}_SIZE){'' if i+1==len(slaves) else ','}
""")

f.write(""") (""")

f.write("""
    input wire m_req,
    input wire[`XLEN-1:0] m_addr,
    input wire m_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0] m_acc,
    input wire[`BUS_WIDTH-1:0] m_wdata,
    output wire m_resp,
    output reg[`BUS_WIDTH-1:0] m_rdata,
""")

for s in slaves:
    f.write(f"""
    output wire s_{s.lower()}_req,
    output wire[`XLEN-1:0] s_{s.lower()}_addr,
    output wire s_{s.lower()}_w_rb,
    output wire[$clog2(`BUS_ACC_CNT)-1:0] s_{s.lower()}_acc,
    output wire[`BUS_WIDTH-1:0] s_{s.lower()}_wdata,
    input wire s_{s.lower()}_resp,
    input wire[`BUS_WIDTH-1:0] s_{s.lower()}_rdata,
""")

f.write("""
    output wire bus_fault, // no bus slave is selected
    input wire bus_halt // force halt bus
);""")

f.write(f"""
    localparam SLAVE_CNT = {len(slaves)};
""")

f.write("""
    // req demux
    wire[SLAVE_CNT-1:0] bus_slave_sel;
""")

for i in range(len(slaves)):
    s = slave[i]
    f.write(f"""    assign bus_slave_sel[{i}] = ((m_addr & ~{{{{(`XLEN-{s.upper()}_SPAN){{1'b0}}}}, {{{s.upper()}_SPAN{{1'b1}}}}}}) == {s.upper()}_BASE);
    assign s_{s.lower()}_req = m_req & bus_slave_sel[{i}];
    assign s_{s.lower()}_addr = m_addr;
    assign s_{s.lower()}_w_rb = m_w_rb;
    assign s_{s.lower()}_acc = m_acc;
    assign s_{s.lower()}_wdata = m_wdata;
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
    f.write(f"""        {'' if i==0 else 'else '}if ({'s_'+s.lower()+'_resp'}) m_rdata = s_{s.lower()}_rdata;
""")
f.write('''        else m_rdata = m_rdata;
    end

''')

f.write('    assign m_resp = ~bus_halt & |{' + ', '.join([f's_{s.lower()}_resp' for s in slaves]) + '''};
''')

f.write("""endmodule
""")

f.close()

print(f'output to {module_name}.v')
