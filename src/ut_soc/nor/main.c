#include "femto.h"
#include "ut.h"

#include <stdint.h>

int main(){
    QSPINOR->norcsr = QSPINOR_NORCSR_MODE(NOR_MODE_111) | QSPINOR_NORCSR_DMYCNT(15) | QSPINOR_NORCSR_CMD(0x0bu);

    {
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPINOR->txqcsr = QSPINOR_TXQCSR_CLR_MASK;
        QSPINOR->txd = 0x0bu;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);

        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK;

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(15);

        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK;
        QSPINOR->ipcsr = 0;
        uint32_t val_from_ip = 0;
        val_from_ip = (QSPINOR->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPINOR->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPINOR->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPINOR->rxd<<24) | (val_from_ip>>8);
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip)
            trigger_fail();
    }

    {
        uint16_t val_from_bus = *((const uint16_t*)(NOR+4));

        QSPINOR->txqcsr = QSPINOR_TXQCSR_CLR_MASK;
        QSPINOR->txd = 0x0bu;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);

        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x04u;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK;

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(15);

        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK;
        QSPINOR->ipcsr = 0;
        uint16_t val_from_ip = 0;
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        TIMER->tr = (uint32_t)val_from_bus;
        TIMER->tr = (uint32_t)val_from_ip;

        if (val_from_bus!=val_from_ip)
            trigger_fail();
    }

    trigger_pass();

    return 0;
}
