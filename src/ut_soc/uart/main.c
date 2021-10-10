#include "femto.h"
#include "ut.h"

#include <stdint.h>

int main(){
    UART->txd=0x55u;
    UART->txd=0xaau;

    while (!UART->rxq_rdy);
    if (UART->rxd!=0x55u)
        trigger_fail();

    while (!UART->rxq_rdy);
    if (UART->rxd!=0xaau)
        trigger_fail();

    trigger_pass();
    return 0;
}
