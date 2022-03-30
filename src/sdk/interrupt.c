#include "femto.h"
#include "interrupt.h"

#define FEMTO_INTERRUPT __attribute__((aligned(2))) __attribute__((interrupt("machine"))) // interrupt handler qualifier

static void ubiq_interrupt_handler(void) FEMTO_INTERRUPT; // actual interrupt handler, do not invoke manually

typedef void (*interrupt_handler_t)(void) FEMTO_INTERRUPT;
static void register_interrupt_handler(interrupt_handler_t interrupt_handler) {
    asm volatile("csrw mtvec, %0"::"r"(interrupt_handler));
}

#define CSR_MSTATUS_MIE_MASK "0x8" // bit 3

void enable_interrupt(bool enable) {
    if (enable) {
        register_interrupt_handler(ubiq_interrupt_handler);
        asm volatile("csrsi mstatus, " CSR_MSTATUS_MIE_MASK);
    } else {
        asm volatile("csrci mstatus, " CSR_MSTATUS_MIE_MASK);
    }
}

// this works with femto only
#define BEGIN_NESTABLE_SEGMENT() \
    asm(                                           \
        "c.addi sp, -4;"                           \
        "csrr   t1, mstatus;"                      \
        "c.swsp t1, 4(sp);"                        \
        "csrr   t1, mepc;"                         \
        "c.swsp t1, 0(sp);"                        \
        "csrsi mstatus, " CSR_MSTATUS_MIE_MASK ";" \
        :::"t1","sp"                               \
    )

// this works with femto only
#define END_NESTABLE_SEGMENT() \
    asm(                                           \
        "csrci mstatus, " CSR_MSTATUS_MIE_MASK ";" \
        "c.lwsp t1, 0(sp);"                        \
        "csrw   mepc, t1;"                         \
        "c.lwsp t1, 4(sp);"                        \
        "csrw   mstatus, t1;"                      \
        "c.addi sp, 4;"                            \
        :::"t1","sp"                               \
    )

// actual interrupt handler
void ubiq_interrupt_handler(void) {
#ifdef NESTABLE_INTERRUPT
    BEGIN_NESTABLE_SEGMENT();
#endif // NESTABLE_INTERRUPT

    main_interrupt();

#ifdef NESTABLE_INTERRUPT
    END_NESTABLE_SEGMENT();
#endif // NESTABLE_INTERRUPT
}
