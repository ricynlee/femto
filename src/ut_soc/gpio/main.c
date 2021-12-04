#include "femto.h"
#include "ut.h"

#include <stdint.h>

int main(){
    GPIO->dir=0xeu;
    GPIO->io =0x4u;
    GPIO->io =0xau;
    GPIO->io =0x4u;
    GPIO->dir=0x0u;
    trigger_pass();
    return 0;
}
