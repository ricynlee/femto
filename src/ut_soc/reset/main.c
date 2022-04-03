#include "femto.h"
#include "ut.h"

#include <stdint.h>

void trigger_software_reset(void) {
    RESET->rst = 1;
}

void trigger_dbus_fault_reset(void) {
    *((int*)ROM) = 0; // write read-only memory
}

void trigger_ibus_fault_reset(void) {
    void (*fp)(void) = (void (*)(void))0xcccc0000; // exec control flow jump to illegal location
    fp();
}

void trigger_core_fault_reset(void) {
    asm volatile(".long 0x00000000"); // illegal instruction
}

void main(void) {
    ut_putc(RESET->cause+'0');
    switch (RESET->cause) {
       case RST_CAUSE_HW  : ut_print("Hardware reset");              trigger_pass();
       case RST_CAUSE_SW  : ut_print("Software reset");              trigger_pass();
       case RST_FAULT_CORE: ut_print("Core fault reset");            trigger_pass();
       case RST_FAULT_IBUS: ut_print("Instruction bus fault reset"); trigger_pass();
       case RST_FAULT_DBUS: ut_print("Data bus fault reset");        trigger_pass();
       default            : ut_print("Power-on reset");
    }

    trigger_core_fault_reset();

    trigger_fail();
}
