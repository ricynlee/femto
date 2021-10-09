#include "femto.h"
#include "ut.h"

#include <stdint.h>

const unsigned  sram = 0x20000000u;

int main(){
    *((uint8_t*)sram) = 0x5a;
    if (*((uint8_t*)sram) != 0x5a)
        trigger_fail();

    *((uint16_t*)sram) = 0x5a3c;
    if (*((uint16_t*)sram) != 0x5a3c)
        trigger_fail();

    *((uint32_t*)sram) = 0x5a3c692d;
    if (*((uint32_t*)sram) != 0x5a3c692d)
        trigger_fail();

    trigger_pass();
    return 0;
}
