#include "femto.h"
#include "interrupt.h"
#include "ut.h"

volatile bool undone = true;

void main(void) {
    enable_interrupt(true);
    trigger_extint(0x6);
    while(undone);
    trigger_pass();
}

void main_interrupt(void) {
    ut_print("Interrupt");
    undone = false;
}
