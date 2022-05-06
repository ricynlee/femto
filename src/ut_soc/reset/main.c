#include "femto.h"
#include "ut.h"

#include <stdint.h>

void trigger_software_reset(void) {
    RESET->info = 0xbabeface; // leave a message for software flow after reset
    RESET->rst = 1;
}

void trigger_dbus_fault_reset(void) {
    *((int*)0xcccc0000) = 0; // write non-existing location
}

void trigger_ibus_fault_reset(void) {
    void (*fp)(void) = (void (*)(void))0xcccc0000; // exec control flow jump to non-existing location
    fp();
}

void trigger_core_fault_reset(void) {
    asm volatile(".long 0x00000000"); // illegal instruction
}

void trigger_dper_fault_reset(void) {
    *((int*)ROM) = 0; // write read-only periph
}

void trigger_iper_fault_reset(void) {
    // femto (or RISCV) does not jump to an unaligned address
    // so do not bother to try this case
}

void main(void) {
    ut_putc(RESET->cause+'0');
    ut_putc(':');
    switch (RESET->cause) {
        case RST_CAUSE_HW  : ut_print("Hardware reset");                 break;
        case RST_CAUSE_SW  : ut_print("Software reset");                 break;
        case RST_FAULT_CORE: ut_print("Core fault reset");               break;
        case RST_FAULT_IBUS: ut_print("Instruction bus fault reset");    break;
        case RST_FAULT_DBUS: ut_print("Data bus fault reset");           break;
        case RST_FAULT_IPER: ut_print("Instruction periph fault reset"); break;
        case RST_FAULT_DPER: ut_print("Data periph fault reset");        break;
        default:
            ut_print("Power-on reset");
            trigger_dbus_fault_reset();
            trigger_fail();
    }

    RESET->info = 0xdeadbeef;

    trigger_pass();
    while(1);
}
