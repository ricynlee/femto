from sys import argv
from serial import Serial as sopen
from wave import open as wopen
from threading import Thread as thread
from time import sleep
from winsound import PlaySound as wplay
from winsound import SND_FILENAME

################################################################################
## Parameters
################################################################################
PORT = "com4"
BAUD = 256000
APP = r"dev-application.bin"
REC_RAW = r"record.snd"
REC_WAV = r"record.wav"

CHANNEL = 1 # mono
FS = 7211.54 # sampling rate
WIDTH = 2 # sample byte width

################################################################################
## Run-time flags
################################################################################
state = 0 # 0: idle, 1: busy, -1: end

################################################################################
## Open objects
################################################################################
ser = sopen(PORT, BAUD, timeout=0)
f = open(REC_RAW, "wb")

################################################################################
## Boot dev-application
################################################################################
if "--boot" in argv:
    print("Loading app...",end='',flush=True)
    with open(APP, "rb") as b:
        ser.write(b.read())
    print("Done")

################################################################################
## Auxiliary thread: recorder
################################################################################
def record():
    global state
    try:
        while True:
            resp = ser.read(2)
            if state==1 and len(resp)>0:
                f.write(resp)
            elif state==-1:
                break
    except:
        pass

################################################################################
## Main thread: controller
################################################################################
aux = thread(target=record)
aux.start()

sleep(1.5)

got_start = lambda c: c in ("START", "BEGIN", "RECORD")
got_stop = lambda c: c in ("STOP", "PAUSE")
got_end = lambda c: c in ("END", "QUIT", "EXIT")

while True:
    cmd = input("> ").upper()
    if state==0:
        if got_start(cmd):
            state = 1
            ser.write(b"s")
        elif got_end(cmd):
            state = -1
            break
        else:
            print("Command not supported")
    elif state==1:
        if got_stop(cmd):
            state = 0
            ser.write(b"s")
        elif got_end(cmd):
            state = -1
            ser.write(b"s")
            break
        else:
            print("Unknown command")

aux.join()

################################################################################
## Close objects
################################################################################
f.close()
ser.close()

################################################################################
## Conversion
################################################################################
if "--convert" in argv:
    with open(REC_RAW, "rb") as f:
        data = f.read()
    print("Converting...",end='',flush=True)
    with wopen(REC_WAV, "wb") as f:
        f.setnchannels(CHANNEL)
        f.setsampwidth(WIDTH)
        f.setframerate(FS)
        f.writeframes(data)
    print("Done")

################################################################################
## Conversion
################################################################################
if "--play" in argv:
    print("Playing recording...",end='',flush=True)
    wplay(REC_WAV, SND_FILENAME)
    print("Done")
