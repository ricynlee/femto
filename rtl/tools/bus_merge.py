from sys import argv

width = int(eval(argv[1]))

def gen_input(indent=4):
    s=""
    for i in range(width-1):
        s+=f"{' '*indent}input wire i{i},\n"
    s+=f"{' '*indent}input wire i{width-1},"
    return s

def gen_assign(indent=4):
    s=""
    for i in range(width):
        s+=f"{' '*indent}assign o[{i}] = i{i};\n"
    return s

with open("merger.v","w") as f:
    f.write(f"""
module merger # (
    parameter WIDTH = {width}
) (
{gen_input()}
    output wire[WIDTH-1:0] o
);

{gen_assign()}
endmodule
""")

print("output to merger.v")
