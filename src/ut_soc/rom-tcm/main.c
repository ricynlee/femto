#include "femto.h"
#include "ut.h"

void f(void) __attribute__((aligned(4))) __attribute__((interrupt("machine")));

int main(){
    while(1);

    return 0;
}

void f(void) {
    volatile int a = 3;
    a++;
    // while(1);
}
