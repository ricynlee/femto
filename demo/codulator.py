# this script encodes and modulates strings into audio signals
# and send them via PC speakers

from wave import open as wopen
from winsound import PlaySound as wplay
from winsound import SND_FILENAME
from math import cos, pi
from os import system as exec
from time import sleep

################################################################################
## Parameters
################################################################################
Fc = 1147.752 # Hz
Fs = 8.2 # kHz
BIT_DUR = 100.0 # ms

PREAMBLE = 1 # start symbol (bit in this case)
POSTAMBLE = 0 # stop symbol (bit in this case)

TMP_WAVFILE_NAME = r"tmp.wav"

ENABLE_FILTER = True

################################################################################
## Filter
################################################################################

## Low-pass
B = [0.00413388302354640, -0.000315205583562589, -0.0463388714439060, -0.0870668750739292, 0.0296208754356374, 0.307425565610882, 0.465463223157628, 0.307425565610882, 0.0296208754356374, -0.0870668750739292, -0.0463388714439060, -0.000315205583562589, 0.00413388302354640]

Z = [0 for i in range(len(B))]
def filter(op=0):
    if not ENABLE_FILTER:
        return op

    global B, Z
    if op == "reset":
        Z = [0 for i in range(len(B))]
        return

    Z[0] = op
    S = sum([Z[i]*B[i] for i in range(len(B))])
    Z.pop(len(B)-1)
    Z.insert(0,0)
    return S

################################################################################
## Encoding, Modulation, Filtering and Transmission
################################################################################
def codulate(string):
    wavfile = wopen(TMP_WAVFILE_NAME, "wb")
    wavfile.setnchannels(1)
    wavfile.setsampwidth(2)
    wavfile.setframerate(Fs*1000)

    # text to symbols (bits in this case)
    sym = []
    for i in range(len(string)):
        sym.append(1)
        for shift in range(8):
            sym.append((0x80 & (ord(string[i])<<shift)) >> 7)
        sym.append(0)
    sym.append(0)

    # time axis
    t = [i/(Fs*1000) for i in range(int((len(string)*10+1)*BIT_DUR*Fs))]

    # base-band
    bb = [0 for i in range(len(t))]
    for i in range(len(t)):
        bb[i] = sym[int(1000*t[i]/BIT_DUR)]

    # modulation
    filter("reset")
    aud = [filter(bb[i]*0.25*cos(2*pi*Fc*t[i])) for i in range(len(t))]

    # quantization
    AUD = [int(round(aud[i]*32768)) for i in range(len(t))]

    # generate wav file
    W = [0 for i in range(2*len(t))]
    for i in range(len(t)):
        W[2*i+0] = (AUD[i]>>0) & 0xff
        W[2*i+1] = (AUD[i]>>8) & 0xff
    wavfile.writeframes(bytes(W))
    wavfile.close()

    # trasmission (play wav file)
    wplay(TMP_WAVFILE_NAME, SND_FILENAME)
    # exec(" ".join(["del",TMP_WAVFILE_NAME]))

################################################################################
## User interaction
################################################################################
print("Input text to transmit")
while True:
    s = input("> ")

    if not s:
        break
    else:
        sleep(0.5)
        codulate(s+'\n')
