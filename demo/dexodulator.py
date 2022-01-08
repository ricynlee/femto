# -*- encoding:utf8 -*-
from sys import argv
from serial import Serial as sopen
from time import sleep
from os import system

################################################################################
## Parameters
################################################################################
PORT = "com4"
BAUD = 256000
APP = r"dev-application.bin"

################################################################################
## Open objects
################################################################################
ser = sopen(PORT, BAUD, timeout=5) # blocking mode, timeout=5s

################################################################################
## Boot dev-application
################################################################################
if "--boot" in argv:
    print("Loading app...",end='',flush=True)
    with open(APP, "rb") as b:
        ser.write(b.read())
    sleep(3)
    print("Done")

################################################################################
## Main loop
################################################################################
while True:
    try:
        B=ser.read(1)
        if len(B)<1: continue
        B=B.decode("ascii")
        if B.isprintable():
            system(' '.join(["start", "disp", B]))
        else:
            system(' '.join(["start", "disp", "啥"]))
    except:
        pass

################################################################################
## Close objects
################################################################################
ser.close()
