#include "femto.h"
#include "interrupt.h"
#include "ut.h"

#define undone (*((bool*)0x20000000))

void main(void) {
    undone = true;
    TIMER->tr = 6;
    TIMER->intcsr = TIMER_INTCSR_INTEN_MASK;
    // EIC->ipfr = EIC_IPFR_TMRF; // clr ipf
    enable_interrupt(true); // enable interrupt (core)
    while(undone);
    trigger_pass();
}

void main_interrupt(void) {
    undone = false;
}
