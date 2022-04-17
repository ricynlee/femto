from sys import argv

width = int(eval(argv[1]))

def gen_output(indent=4):
    s=""
    for i in range(width-1):
        s+=f"{' '*indent}output wire o{i},\n"
    s+=f"{' '*indent}output wire o{width-1}"
    return s

def gen_assign(indent=4):
    s=""
    for i in range(width):
        s+=f"{' '*indent}assign o{i} = i[{i}];\n"
    return s

with open("splitter.v","w") as f:
    f.write(f"""
module splitter # (
    parameter WIDTH = {width}
) (
    input wire[WIDTH-1:0] i,
{gen_output()}
);

{gen_assign()}
endmodule
""")

print("output to splitter.v")
