#include "femto.h"
#include "interrupt.h"
#include "ut.h"

bool undone = true;

int main(){
    enable_interrupt(true);
    trig_int(0x6);
    while(undone);
    trigger_pass();
    return 0;
}

void main_interrupt(void) {
    ut_print("Interrupt");
    undone = false;
}
