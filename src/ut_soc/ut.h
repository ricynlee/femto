#ifndef _FEMTO_UT_H
#define _FEMTO_UT_H

// RESET
    #define UT (*(volatile char*)0xf0000000)

    enum {
        UT_PASS,
        UT_FAIL,
    };

// Prototypes
    static void trigger_pass(void) { UT = UT_PASS; while(1); }
    static void trigger_fail(void) { UT = UT_FAIL; while(1); }

#endif // _FEMTO_UT_H
