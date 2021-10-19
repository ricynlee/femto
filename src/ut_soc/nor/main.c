#include "femto.h"
#include "ut.h"

#include <stdint.h>

int main(){
    QSPINOR->norcsr = QSPINOR_NORCSR_MODE(NOR_MODE_111) | QSPINOR_NORCSR_DMYCNT(15) | QSPINOR_NORCSR_CMD(0x0bu);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPINOR->txqcsr = QSPINOR_TXQCSR_CLR_MASK;
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        QSPINOR->txd = 0x0bu; // cmd
        QSPINOR->txd = 0x00u; // addr
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);  // send cmd
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK;                         // send addr
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(1);  // send dmy part 1
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(14); // send dmy part 2
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK;                                                  // receive data
        QSPINOR->ipcsr = 0;                                                                       // finish

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPINOR->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPINOR->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPINOR->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPINOR->rxd<<24) | (val_from_ip>>8);
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip)
            trigger_fail();
    }

    { // non-blocking data interaction (w/ busy check)
        uint32_t val_from_bus = *((const uint16_t*)(NOR+4));

        QSPINOR->txqcsr = QSPINOR_TXQCSR_CLR_MASK;
        QSPINOR->txd = 0x0bu;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x04u;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK;

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(8);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(7);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK;

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = 0;

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip)
            trigger_fail();
    }

    trigger_pass();

    return 0;
}
