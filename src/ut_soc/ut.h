#ifndef _FEMTO_UT_H
#define _FEMTO_UT_H

    #define UT (*(volatile unsigned*)0x70000000)

// PASS/FAIL
    enum {
        UT_PASS = 0x50415353u, // "PASS"
        UT_FAIL = 0x4641494cu, // "FAIL"
    };

    static void trigger_pass(void) { UT = UT_PASS; while(1); }
    static void trigger_fail(void) { UT = UT_FAIL; while(1); }

// NOR type shift
    enum {
        UT_QSPI = 0x51535049u, // "QSPI"
        UT_SPI = UT_QSPI,
        UT_DPI = 0x44325049u, // "D2PI"
        UT_QPI = 0x51345049u, // "Q4PI"
    };
    static void select_nor(unsigned type) { UT = type; }

#endif // _FEMTO_UT_H