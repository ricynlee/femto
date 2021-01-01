from sys import argv
from struct import unpack

inf = argv[1]
# fmt = argv[2]

print("const unsigned char image[]={")
with open(inf, "rb") as f:
    while True:
        try:
            print("0x%02x," % unpack("B", f.read(1)))
        except:
            break
print("};")
