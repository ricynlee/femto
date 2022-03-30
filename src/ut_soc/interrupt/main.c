#include "femto.h"
#include "interrupt.h"
#include "ut.h"

bool undone = true;

int main(){
    trig_int(0x6);
    ut_putc('f');
    ut_putc('=');
    ut_putc('0'+EIC->ipfr);
    ut_putc('\n');
    EIC->ipfr = 2; // clr bit 1
    enable_interrupt(true);
    while(undone);
    trigger_pass();
    return 0;
}

void main_interrupt(void) {
    ut_print("Interrupt");
    undone = false;
}
