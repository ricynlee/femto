#include "femto.h"
#include "ut.h"

#include <stdint.h>

const unsigned  tcm = 0x10000000u;

int main(){
    *((uint8_t*)tcm) = 0x5a;
    if (*((uint8_t*)tcm) != 0x5a)
        trigger_fail();

    *((uint16_t*)tcm) = 0x5a3c;
    if (*((uint16_t*)tcm) != 0x5a3c)
        trigger_fail();

    *((uint32_t*)tcm) = 0x5a3c692d;
    if (*((uint32_t*)tcm) != 0x5a3c692d)
        trigger_fail();

    trigger_pass();
    return 0;
}
