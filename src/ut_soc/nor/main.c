#include "femto.h"
#include "ut.h"

#include <stdint.h>

void test_read();
void test_111read();
void test_112read();
void test_122read();
void test_114read();
void test_144read();
void test_222read();
void test_444read();

int main(){
    select_nor(UT_QSPI);
    test_read();
    test_111read();
    test_112read();
    test_122read();
    test_114read();
    test_144read();

    select_nor(UT_DPI);
    test_222read();

    select_nor(UT_QPI);
    test_444read();

    trigger_pass();
    return 0;
}

/*****************************************************************************************/

enum {
    CMD_READ    = 0x03u,
    CMD_111READ = 0x0bu,    DMY_111READ = 8,
    CMD_112READ = 0x3bu,    DMY_112READ = 8,
    CMD_122READ = 0xbbu,    DMY_122READ = 4,
    CMD_114READ = 0x6bu,    DMY_114READ = 8,
    CMD_144READ = 0xebu,    DMY_144READ = 6,
    CMD_222READ = 0xbbu,    DMY_222READ = 8,
    CMD_444READ = 0xebu,    DMY_444READ = 10,
};

void test_read(){
    QSPINOR->norcsr = QSPINOR_NORCSR_MODE(NOR_MODE_111) | QSPINOR_NORCSR_DMYCNT(0) | QSPINOR_NORCSR_CMD(CMD_READ);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPINOR->txqcsr = QSPINOR_TXQCSR_CLR_MASK;
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        QSPINOR->txd = CMD_READ; // cmd
        QSPINOR->txd = 0x00u; // addr
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);  // send cmd
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK;                         // send addr
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
        QSPINOR->txd = CMD_READ;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x04u;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK;

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
}

void test_111read(){
    QSPINOR->norcsr = QSPINOR_NORCSR_MODE(NOR_MODE_111) | QSPINOR_NORCSR_DMYCNT(DMY_111READ) | QSPINOR_NORCSR_CMD(CMD_111READ);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPINOR->txqcsr = QSPINOR_TXQCSR_CLR_MASK;
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        QSPINOR->txd = CMD_111READ; // cmd
        QSPINOR->txd = 0x00u; // addr
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);    // send cmd
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK;                           // send addr
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(DMY_111READ);  // send dmy
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK;                                                    // receive data
        QSPINOR->ipcsr = 0;                                                                         // finish

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
        QSPINOR->txd = CMD_111READ;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x04u;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK;

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(DMY_111READ);  // send dmy

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
}

void test_112read(){
    QSPINOR->norcsr = QSPINOR_NORCSR_MODE(NOR_MODE_112) | QSPINOR_NORCSR_DMYCNT(DMY_112READ) | QSPINOR_NORCSR_CMD(CMD_112READ);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPINOR->txqcsr = QSPINOR_TXQCSR_CLR_MASK;
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        QSPINOR->txd = CMD_112READ; // cmd
        QSPINOR->txd = 0x00u; // addr
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);            // send cmd
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK;                                   // send addr
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(DMY_112READ);  // send dmy
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X2);                            // receive data
        QSPINOR->ipcsr = 0;                                                                                 // finish

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
        QSPINOR->txd = CMD_112READ;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x04u;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK;

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(DMY_112READ);  // send dmy

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X2);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = 0;

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip)
            trigger_fail();
    }
}

void test_122read(){
    QSPINOR->norcsr = QSPINOR_NORCSR_MODE(NOR_MODE_122) | QSPINOR_NORCSR_DMYCNT(DMY_122READ) | QSPINOR_NORCSR_CMD(CMD_122READ);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPINOR->txqcsr = QSPINOR_TXQCSR_CLR_MASK;
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        QSPINOR->txd = CMD_122READ; // cmd
        QSPINOR->txd = 0x00u; // addr
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);            // send cmd
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X2) | QSPINOR_IPCSR_DIR_MASK;   // send addr
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(DMY_122READ);  // send dmy
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X2);                            // receive data
        QSPINOR->ipcsr = 0;                                                                                 // finish

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
        QSPINOR->txd = CMD_122READ;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x04u;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_WID(QSPINOR_X2);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(DMY_122READ);  // send dmy

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X2);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = 0;

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip)
            trigger_fail();
    }
}

void test_114read(){
    QSPINOR->norcsr = QSPINOR_NORCSR_MODE(NOR_MODE_114) | QSPINOR_NORCSR_DMYCNT(DMY_114READ) | QSPINOR_NORCSR_CMD(CMD_114READ);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPINOR->txqcsr = QSPINOR_TXQCSR_CLR_MASK;
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        QSPINOR->txd = CMD_114READ; // cmd
        QSPINOR->txd = 0x00u; // addr
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);            // send cmd
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X1) | QSPINOR_IPCSR_DIR_MASK;   // send addr
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(DMY_114READ);  // send dmy
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X4);                            // receive data
        QSPINOR->ipcsr = 0;                                                                                 // finish

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
        QSPINOR->txd = CMD_114READ;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x04u;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK;

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(DMY_114READ);  // send dmy

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X4);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = 0;

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip)
            trigger_fail();
    }
}

void test_144read(){
    QSPINOR->norcsr = QSPINOR_NORCSR_MODE(NOR_MODE_144) | QSPINOR_NORCSR_DMYCNT(DMY_144READ) | QSPINOR_NORCSR_CMD(CMD_144READ);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPINOR->txqcsr = QSPINOR_TXQCSR_CLR_MASK;
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        QSPINOR->txd = CMD_144READ; // cmd
        QSPINOR->txd = 0x00u; // addr
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);            // send cmd
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X4) | QSPINOR_IPCSR_DIR_MASK;   // send addr
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(DMY_144READ);  // send dmy
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X4);                            // receive data
        QSPINOR->ipcsr = 0;                                                                         // finish

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
        QSPINOR->txd = CMD_144READ;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x04u;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X4) | QSPINOR_IPCSR_DIR_MASK;

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(DMY_144READ);  // send dmy

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X4);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = 0;

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip)
            trigger_fail();
    }
}

void test_222read(){
    QSPINOR->norcsr = QSPINOR_NORCSR_MODE(NOR_MODE_222) | QSPINOR_NORCSR_DMYCNT(DMY_222READ) | QSPINOR_NORCSR_CMD(CMD_222READ);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPINOR->txqcsr = QSPINOR_TXQCSR_CLR_MASK;
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        QSPINOR->txd = CMD_222READ; // cmd
        QSPINOR->txd = 0x00u; // addr
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X2) | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);    // send cmd
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X2) | QSPINOR_IPCSR_DIR_MASK;                           // send addr
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(DMY_222READ);                          // send dmy
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X2);                                                    // receive data
        QSPINOR->ipcsr = 0;                                                                                                         // finish

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
        QSPINOR->txd = CMD_222READ;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X2) | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x04u;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X2) | QSPINOR_IPCSR_DIR_MASK;

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(DMY_222READ);  // send dmy

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X2);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = 0;

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip)
            trigger_fail();
    }
}

void test_444read(){
    QSPINOR->norcsr = QSPINOR_NORCSR_MODE(NOR_MODE_444) | QSPINOR_NORCSR_DMYCNT(DMY_444READ) | QSPINOR_NORCSR_CMD(CMD_444READ);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPINOR->txqcsr = QSPINOR_TXQCSR_CLR_MASK;
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        QSPINOR->txd = CMD_444READ; // cmd
        QSPINOR->txd = 0x00u; // addr
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X4) | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);    // send cmd
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X4) | QSPINOR_IPCSR_DIR_MASK;                           // send addr
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(DMY_444READ);                          // send dmy
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X4);                                                    // receive data
        QSPINOR->ipcsr = 0;                                                                                                         // finish

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
        QSPINOR->txd = CMD_444READ;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X4) | QSPINOR_IPCSR_DIR_MASK | QSPINOR_IPCSR_CNT(1);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x00u;
        QSPINOR->txd = 0x04u;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X4) | QSPINOR_IPCSR_DIR_MASK;

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_DMY_MASK | QSPINOR_IPCSR_CNT(DMY_444READ);  // send dmy

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;
        QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK | QSPINOR_IPCSR_WID(QSPINOR_X4);

        while(QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK); // wait while busy

        QSPINOR->ipcsr = 0;

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPINOR->rxd<<8) | (val_from_ip>>8);
        QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip)
            trigger_fail();
    }
}
