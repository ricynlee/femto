# this script encodes and modulates strings into audio signals
# and send them via PC speakers

from wave import open as wopen
from winsound import PlaySound as wplay
from winsound import SND_FILENAME
from math import cos, pi
from os import system as exec

################################################################################
## Parameters
################################################################################
Fc = 1147.752 # Hz
Fs = 10.0 # kHz
BIT_DUR = 100.0 # ms

PREAMBLE = 1 # start symbol (bit in this case)
POSTAMBLE = 0 # stop symbol (bit in this case)

TMP_WAVFILE_NAME = r"tmp.wav"

ENABLE_FILTER = False

################################################################################
## Global object
################################################################################
wavfile = None

################################################################################
## Band-pass filter
################################################################################
B = [-0.190837427318414, 0.0443717943399390, 0.272237333849104, 0.365927912163370, 0.272237333849104, 0.0443717943399390, -0.190837427318414]
Z = [0 for i in range(7)]
def filter(sig, reset=False):
    if ENABLE_FILTER == False:
        return sig

    global B, Z

    if reset:
        Z = [0 for i in range(7)]

    Z[0] = sig
    S = sum([Z[i]*B[i] for i in range(7)])
    Z.pop(6)
    Z.insert(0,0)
    return S

################################################################################
## Modulator
################################################################################
t = 0
def modulate(sym):
    global wavfile, t
    if wavfile==None:
        return

    te = t+BIT_DUR/1000
    if sym==0:
        while t < te:
            osc = filter(0*0.25*cos(2*pi*Fc*t))
            q = int(round(osc*32768)) # quantized
            wavfile.writeframes(bytes([(q>>0) & 0xff, (q>>8) & 0xff])) # little endian
            t += 1.0/(Fs*1000)
    elif sym==1:
        while t < te:
            osc = filter(0.25*cos(2*pi*Fc*t))
            q = int(round(osc*32768)) # quantized
            wavfile.writeframes(bytes([(q>>0) & 0xff, (q>>8) & 0xff])) # little endian
            t += 1.0/(Fs*1000)

################################################################################
## Encoder
################################################################################
def encode(string):
    global wavfile, t
    wavfile = wopen(TMP_WAVFILE_NAME, "wb")
    wavfile.setnchannels(1)
    wavfile.setsampwidth(2)
    wavfile.setframerate(Fs*1000)

    t = 0
    filter(0, True)
    for c in string:
        modulate(PREAMBLE)
        c = ord(c)
        for shift in range(8):
            modulate(1 if ((c<<shift) & 0x80) else 0)
        modulate(POSTAMBLE)
    modulate(0) # trailing 0

    wavfile.close()

################################################################################
## Transmitter
################################################################################
def transmit(string):
    encode(string)
    wplay(TMP_WAVFILE_NAME, SND_FILENAME)
    # exec(" ".join(["del",TMP_WAVFILE_NAME]))

################################################################################
## User interaction
################################################################################
print("Input text to transmit")
while True:
    s = input("> ").upper()

    if not s:
        break
    else:
        transmit(s)
