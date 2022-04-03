#include "femto.h"
#include "ut.h"

#include <stdint.h>

const uint32_t itv = 64;

void main(void){
    TIMER->tr = itv;

    for (int i=0; i<24; i++);

    uint32_t tv1 = TIMER->tr;
    if (tv1>=itv)
        trigger_fail();

    for (int i=0; i<24; i++);

    uint32_t tv2 = TIMER->tr;
    if (tv2>=tv1)
        trigger_fail();

    while (TIMER->tr);

    trigger_pass();
}
