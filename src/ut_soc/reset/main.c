#include "femto.h"
#include "ut.h"

#include <stdint.h>

void main(void){
    ut_putc(RESET->cause+'0');
    switch (RESET->cause) {
       case RST_CAUSE_HW  : ut_print("Hardware reset");              trigger_pass();
       case RST_CAUSE_SW  : ut_print("Software reset");              trigger_pass();
       case RST_FAULT_CORE: ut_print("Core fault reset");            trigger_pass();
       case RST_FAULT_IBUS: ut_print("Instruction bus fault reset"); trigger_pass();
       case RST_FAULT_DBUS: ut_print("Data bus fault reset");        trigger_pass();
       default            : ut_print("Power-on reset");
    }

    RESET->rst = 1;

    trigger_fail();
}
