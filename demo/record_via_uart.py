from serial import Serial as sopen

## Cmdline arg parser
PORT = "com4"
BAUD = 256000

## Port operations
ser = sopen(PORT, BAUD)
f = open("record.snd", "wb")

while True:
    resp = ser.read(2)
    f.write(resp)

f.close()
ser.close()
