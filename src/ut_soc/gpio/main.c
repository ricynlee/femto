#include "femto.h"
#include "ut.h"

#include <stdint.h>

void main(void) {
    GPIO->dir=0xeu;
    GPIO->io =0x4u;
    GPIO->io =0xau;
    GPIO->io =0x4u;
    GPIO->dir=0x0u;
    trigger_pass();
}
