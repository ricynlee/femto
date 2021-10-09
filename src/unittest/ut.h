#ifndef _FEMTO_UT_H
#define _FEMTO_UT_H

// RESET
    #define UT (*(volatile char*)0xf0000000)

    enum {
        UT_PASS,
        UT_FAIL,
    };

#endif // _FEMTO_UT_H
