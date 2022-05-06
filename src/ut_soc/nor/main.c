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

void main(void) {
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
    QSPI->norcmd = CMD_READ;
    QSPI->norcsr = QSPI_NORCSR_MODE(NOR_MODE_111) | QSPI_NORCSR_DMYCNT(0);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        QSPI->txd = CMD_READ; // cmd
        QSPI->txd = 0x00u; // addr
        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;

        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);  // send cmd
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK;                         // send addr
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK;                                                  // receive data
        QSPI->ipcsr = 0;                                                                       // finish

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }

    { // non-blocking data interaction (w/ busy check)
        uint32_t val_from_bus = *((const uint16_t*)(NOR+4));

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->txd = CMD_READ;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;
        QSPI->txd = 0x04u;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK;

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK;

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->ipcsr = 0;

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }
}

void test_111read(){
    QSPI->norcmd = CMD_111READ;
    QSPI->norcsr = QSPI_NORCSR_MODE(NOR_MODE_111) | QSPI_NORCSR_DMYCNT(DMY_111READ);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        QSPI->txd = CMD_111READ; // cmd
        QSPI->txd = 0x00u; // addr
        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;

        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);            // send cmd
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK;                                // send addr
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DMY_MASK | QSPI_IPCSR_CNT(DMY_111READ);  // send dmy
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK;                                                      // receive data
        QSPI->ipcsr = 0;                                                                        // finish

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }

    { // non-blocking data interaction (w/ busy check)
        uint32_t val_from_bus = *((const uint16_t*)(NOR+4));

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->txd = CMD_111READ;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;
        QSPI->txd = 0x04u;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK;

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DMY_MASK | QSPI_IPCSR_CNT(DMY_111READ);  // send dmy

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK;

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->ipcsr = 0;

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }
}

void test_112read(){
    QSPI->norcmd = CMD_112READ;
    QSPI->norcsr = QSPI_NORCSR_MODE(NOR_MODE_112) | QSPI_NORCSR_DMYCNT(DMY_112READ);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        QSPI->txd = CMD_112READ; // cmd
        QSPI->txd = 0x00u; // addr
        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;

        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);            // send cmd
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK;                                // send addr
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DMY_MASK | QSPI_IPCSR_CNT(DMY_112READ);  // send dmy
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X2);                            // receive data
        QSPI->ipcsr = 0;                                                                        // finish

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }

    { // non-blocking data interaction (w/ busy check)
        uint32_t val_from_bus = *((const uint16_t*)(NOR+4));

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->txd = CMD_112READ;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;
        QSPI->txd = 0x04u;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK;

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DMY_MASK | QSPI_IPCSR_CNT(DMY_112READ);  // send dmy

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X2);

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->ipcsr = 0;

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }
}

void test_122read(){
    QSPI->norcmd = CMD_122READ;
    QSPI->norcsr = QSPI_NORCSR_MODE(NOR_MODE_122) | QSPI_NORCSR_DMYCNT(DMY_122READ);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        QSPI->txd = CMD_122READ; // cmd
        QSPI->txd = 0x00u; // addr
        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;

        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);            // send cmd
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X2) | QSPI_IPCSR_DIR_MASK;      // send addr
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DMY_MASK | QSPI_IPCSR_CNT(DMY_122READ);  // send dmy
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X2);                            // receive data
        QSPI->ipcsr = 0;                                                                        // finish

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }

    { // non-blocking data interaction (w/ busy check)
        uint32_t val_from_bus = *((const uint16_t*)(NOR+4));

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->txd = CMD_122READ;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;
        QSPI->txd = 0x04u;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_WID(QSPI_X2);

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DMY_MASK | QSPI_IPCSR_CNT(DMY_122READ);  // send dmy

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X2);

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->ipcsr = 0;

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }
}

void test_114read(){
    QSPI->norcmd = CMD_114READ;
    QSPI->norcsr = QSPI_NORCSR_MODE(NOR_MODE_114) | QSPI_NORCSR_DMYCNT(DMY_114READ);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        QSPI->txd = CMD_114READ; // cmd
        QSPI->txd = 0x00u; // addr
        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;

        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);            // send cmd
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X1) | QSPI_IPCSR_DIR_MASK;      // send addr
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DMY_MASK | QSPI_IPCSR_CNT(DMY_114READ);  // send dmy
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X4);                            // receive data
        QSPI->ipcsr = 0;                                                                        // finish

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }

    { // non-blocking data interaction (w/ busy check)
        uint32_t val_from_bus = *((const uint16_t*)(NOR+4));

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->txd = CMD_114READ;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;
        QSPI->txd = 0x04u;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK;

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DMY_MASK | QSPI_IPCSR_CNT(DMY_114READ);  // send dmy

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X4);

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->ipcsr = 0;

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }
}

void test_144read(){
    QSPI->norcmd = CMD_144READ;
    QSPI->norcsr = QSPI_NORCSR_MODE(NOR_MODE_144) | QSPI_NORCSR_DMYCNT(DMY_144READ);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        QSPI->txd = CMD_144READ; // cmd
        QSPI->txd = 0x00u; // addr
        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;

        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);            // send cmd
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X4) | QSPI_IPCSR_DIR_MASK;      // send addr
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DMY_MASK | QSPI_IPCSR_CNT(DMY_144READ);  // send dmy
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X4);                            // receive data
        QSPI->ipcsr = 0;                                                                        // finish

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }

    { // non-blocking data interaction (w/ busy check)
        uint32_t val_from_bus = *((const uint16_t*)(NOR+4));

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->txd = CMD_144READ;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;
        QSPI->txd = 0x04u;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X4) | QSPI_IPCSR_DIR_MASK;

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DMY_MASK | QSPI_IPCSR_CNT(DMY_144READ);  // send dmy

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X4);

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->ipcsr = 0;

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }
}

void test_222read(){
    QSPI->norcmd = CMD_222READ;
    QSPI->norcsr = QSPI_NORCSR_MODE(NOR_MODE_222) | QSPI_NORCSR_DMYCNT(DMY_222READ);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        QSPI->txd = CMD_222READ; // cmd
        QSPI->txd = 0x00u; // addr
        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;

        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X2) | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);  // send cmd
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X2) | QSPI_IPCSR_DIR_MASK;                      // send addr
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DMY_MASK | QSPI_IPCSR_CNT(DMY_222READ);                  // send dmy
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X2);                                            // receive data
        QSPI->ipcsr = 0;                                                                                                         // finish

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }

    { // non-blocking data interaction (w/ busy check)
        uint32_t val_from_bus = *((const uint16_t*)(NOR+4));

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->txd = CMD_222READ;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X2) | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;
        QSPI->txd = 0x04u;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X2) | QSPI_IPCSR_DIR_MASK;

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DMY_MASK | QSPI_IPCSR_CNT(DMY_222READ);  // send dmy

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X2);

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->ipcsr = 0;

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }
}

void test_444read(){
    QSPI->norcmd = CMD_444READ;
    QSPI->norcsr = QSPI_NORCSR_MODE(NOR_MODE_444) | QSPI_NORCSR_DMYCNT(DMY_444READ);

    { // blocking data interaction (no busy check)
        uint32_t val_from_bus = *((const uint32_t*)NOR);

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        QSPI->txd = CMD_444READ; // cmd
        QSPI->txd = 0x00u; // addr
        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;

        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X4) | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);  // send cmd
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X4) | QSPI_IPCSR_DIR_MASK;                      // send addr
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DMY_MASK | QSPI_IPCSR_CNT(DMY_444READ);                  // send dmy
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X4);                                            // receive data
        QSPI->ipcsr = 0;                                                                                                         // finish

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<24) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }

    { // non-blocking data interaction (w/ busy check)
        uint32_t val_from_bus = *((const uint16_t*)(NOR+4));

        QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
        QSPI->txd = CMD_444READ;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X4) | QSPI_IPCSR_DIR_MASK | QSPI_IPCSR_CNT(1);

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->txd = 0x00u;
        QSPI->txd = 0x00u;
        QSPI->txd = 0x04u;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X4) | QSPI_IPCSR_DIR_MASK;

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_DMY_MASK | QSPI_IPCSR_CNT(DMY_444READ);  // send dmy

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;
        QSPI->ipcsr = QSPI_IPCSR_SEL_MASK | QSPI_IPCSR_WID(QSPI_X4);

        while(QSPI->ipcsr & QSPI_IPCSR_BSY_MASK); // wait while busy

        QSPI->ipcsr = 0;

        uint32_t val_from_ip = 0;
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        val_from_ip = (QSPI->rxd<<8) | (val_from_ip>>8);
        QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;

        if (val_from_bus!=val_from_ip) {
            ut_print(__func__);
            trigger_fail();
        }
    }
}
