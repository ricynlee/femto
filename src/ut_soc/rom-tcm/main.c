#include "femto.h"
#include "ut.h"

#define trap_handler interrupt // interrupt/exception handler

void f(void) __attribute__((aligned(4))) __attribute__((trap_handler("machine")));

int main(){
    while(1);

    return 0;
}

void f(void) {
    asm(
        "csrr x9, mstatus" \
        :::"x9"
    );
    volatile int a = 3;
    a++;
    // while(1);
}
