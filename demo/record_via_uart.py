from serial import Serial as sopen

## Cmdline arg parser
PORT = "com4"
BAUD = 256000

## Port operations
ser = sopen(PORT, BAUD)
f = open("record.snd", "wb")

try:
    while True:
        resp = ser.read(2)
        f.write(resp)
except:
    pass

f.close()
ser.close()
