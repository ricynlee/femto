#include "femto.h"
#include "ut.h"

#include <stdint.h>

int main(){
    TIMER->tr = 0x1000u;
    RESET->rst = RESET_TIMER;
    if (TIMER->tr)
        trigger_fail();

    RESET->rst = RESET_QSPINOR;
    RESET->rst = RESET_UART;
    RESET->rst = RESET_GPIO;
    RESET->rst = RESET_NOR;
    RESET->rst = RESET_SRAM;
    RESET->rst = RESET_TCM;
    // RESET->rst = RESET_ROM; // this might block ut
    RESET->rst = RESET_CORE;
    RESET->rst = RESET_ALL;

    trigger_fail();
    return 0;
}
