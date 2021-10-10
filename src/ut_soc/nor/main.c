#include "femto.h"
#include "ut.h"

#include <stdint.h>

int main(){
    QSPINOR->norcsr = QSPINOR_NORCSR_MODE(NOR_MODE_111) | QSPINOR_NORCSR_CMD(0x03u);
    uint32_t val_from_bus = *((const uint32_t*)NOR);

    QSPINOR->txqcsr = QSPINOR_TXQCSR_CLR_MASK;
    QSPINOR->txd = 0x03u;
    QSPINOR->req = QSPINOR_REQ_SEL_MASK | QSPINOR_REQ_DIR_MASK | QSPINOR_REQ_CNT(1);
    QSPINOR->txd = 0x00u;
    QSPINOR->txd = 0x00u;
    QSPINOR->txd = 0x00u;
    QSPINOR->req = QSPINOR_REQ_SEL_MASK | QSPINOR_REQ_DIR_MASK;
    QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;
    QSPINOR->req = QSPINOR_REQ_SEL_MASK;
    QSPINOR->req = 0;
    uint32_t val_from_ip = 0;
    val_from_ip = (QSPINOR->rxd<<24) | (val_from_ip>>8);
    val_from_ip = (QSPINOR->rxd<<24) | (val_from_ip>>8);
    val_from_ip = (QSPINOR->rxd<<24) | (val_from_ip>>8);
    val_from_ip = (QSPINOR->rxd<<24) | (val_from_ip>>8);
    QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

    TIMER->tr = val_from_bus;
    TIMER->tr = val_from_ip;

    if (val_from_bus==val_from_ip)
        trigger_pass();
    else
        trigger_fail();

    return 0;
}
