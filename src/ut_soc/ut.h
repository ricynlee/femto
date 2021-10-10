#ifndef _FEMTO_UT_H
#define _FEMTO_UT_H

// RESET
    #define UT (*(volatile unsigned*)0x70000000)

    enum {
        UT_PASS = 0x50415353u, // "PASS"
        UT_FAIL = 0x4641494cu, // "FAIL"
    };

// Prototypes
    static void trigger_pass(void) { UT = UT_PASS; while(1); }
    static void trigger_fail(void) { UT = UT_FAIL; while(1); }

#endif // _FEMTO_UT_H
