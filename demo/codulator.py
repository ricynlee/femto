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
Fs = 8.2 # kHz
BIT_DUR = 100.0 # ms

PREAMBLE = 1 # start symbol (bit in this case)
POSTAMBLE = 0 # stop symbol (bit in this case)

TMP_WAVFILE_NAME = r"tmp.wav"

ENABLE_FILTER = False

################################################################################
## Filter
################################################################################

## Band-pass
B = [-0.0205037556810013, 0.0250754093892770, 0.0689831330047264, 0.0370893942662163, -0.0199304160356812, -0.0405403995881639, -0.0965125595244665, -0.150931250571262, -0.0138989704890338, 0.226374290324164, 0.226374290324164, -0.0138989704890338, -0.150931250571262, -0.0965125595244665, -0.0405403995881639, -0.0199304160356812, 0.0370893942662163, 0.0689831330047264, 0.0250754093892770, -0.0205037556810013]

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
    s = input("> ").upper()

    if not s:
        break
    else:
        codulate(s)
