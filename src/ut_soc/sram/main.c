#include "femto.h"
#include "ut.h"

#include <stdint.h>

void main(void){
    *((uint8_t*)SRAM) = 0x5a;
    if (*((uint8_t*)SRAM) != 0x5a)
        trigger_fail();

    *((uint16_t*)SRAM) = 0x5a3c;
    if (*((uint16_t*)SRAM) != 0x5a3c)
        trigger_fail();

    *((uint32_t*)SRAM) = 0x5a3c692d;
    if (*((uint32_t*)SRAM) != 0x5a3c692d)
        trigger_fail();

    trigger_pass();
}
