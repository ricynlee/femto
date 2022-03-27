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

#define ENABLE_NESTED_INTERRUPT() \
    asm(                          \
        "c.addi sp, -4;"          \
        "csrr   t1, mstatus;"     \
        "c.swsp t1, 4(sp);"       \
        "csrr   t1, mepc;"        \
        "c.swsp t1, 0(sp);"       \
        "csrsi mstatus, " MIE ";" \
        :::"t1","sp"              \
    )

#define FORBID_NESTED_INTERRUPT() \
    asm(                          \
        "csrci mstatus, " MIE ";" \
        "c.lwsp t1, 0(sp);"       \
        "csrw   mepc, t1;"        \
        "c.lwsp t1, 4(sp);"       \
        "csrw   mstatus, t1;"     \
        "c.addi sp, 4;"           \
        :::"t1","sp"              \
    )

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
    ENABLE_NESTED_INTERRUPT();
    ut_print("Interrupt");
    undone = false;
    FORBID_NESTED_INTERRUPT();
}
