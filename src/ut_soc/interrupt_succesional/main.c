#include "femto.h"
#include "ut.h"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define MIE  "0x8" // bit 3

#define INTERRUPT __attribute__((aligned(2))) __attribute__((interrupt("machine"))) // interrupt/exception handler

typedef void (*interrupt_handler)(void) INTERRUPT;

void f(void) INTERRUPT;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void set_interrupt_handler(interrupt_handler handler) {
    asm volatile("csrw mtvec, %0"::"r"(handler));
}

void enable_interrupt(bool enable) {
    if (enable) {
        asm volatile("csrsi mstatus, " MIE);
    } else {
        asm volatile("csrci mstatus, " MIE);
    }
}

bool undone = true;

int main(){
    set_interrupt_handler(f);
    enable_interrupt(true);
    trig_int(0x6);
    while(undone);
    trigger_pass();
    return 0;
}

void f(void) {
    ut_print("Interrupt");
    undone = false;
}
