#include "femto.h"
#include "interrupt.h"
#include "ut.h"

volatile bool undone = true;

void main(void) {
    trigger_extint(0x6);
    ut_putc('f');
    ut_putc('=');
    ut_putc('0'+EIC->ipfr);
    ut_putc('\n');
    EIC->ipfr = 2; // clr bit 1
    enable_interrupt(true);
    while(undone);
    trigger_pass();
}

void main_interrupt(void) {
    ut_print("Interrupt");
    undone = false;
}
