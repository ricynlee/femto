from sys import argv
from struct import unpack

inf = argv[1]
fmt = argv[2]

print("@0")
with open(inf, "rb") as f:
    while True:
        try:
            if fmt=='32':
                print("%08x" % unpack("<L", f.read(4)))
            elif fmt=='8':
                print("%02x" % unpack("B", f.read(1)))
        except:
            break
