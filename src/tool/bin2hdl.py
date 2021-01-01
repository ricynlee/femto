from sys import argv
from struct import unpack

inf = argv[1]
fmt = argv[2]

i=0
with open(inf, "rb") as f:
    while True:
        try:
            if fmt=="32":
                print("    assign array[%d] = 32\'h%08x;" % (i, unpack("<L", f.read(4))[0]) )
            elif fmt=="8":
                print("    assign array[%d] = 8\'h%02x;" % (i, unpack("B", f.read(1))[0]) )

            i+=1
        except:
            break
