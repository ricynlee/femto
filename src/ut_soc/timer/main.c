#include "femto.h"
#include "ut.h"

#include <stdint.h>

const uint32_t itv = 256;

int main(){
    TIMER->tr = itv;

    uint32_t tv1 = TIMER->tr;
    if (tv1>=itv)
        trigger_fail();

    uint32_t tv2 = TIMER->tr;
    if (tv2>=tv1)
        trigger_fail();

    while (TIMER->tr);

    trigger_pass();
    return 0;
}
