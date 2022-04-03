#include "femto.h"
#include "ut.h"

#include <stdint.h>

void main(void) {
    while (!(UART->txqsr & UART_TXQSR_RDY_MASK));

    UART->txd=0x55u;
    UART->txd=0xaau;

    while (!(UART->rxqcsr & UART_RXQCSR_RDY_MASK));
    if (UART->rxd!=0x55u)
        trigger_fail();

    while (!(UART->rxqcsr & UART_RXQCSR_RDY_MASK));
    UART->rxqcsr = UART_RXQCSR_CLR_MASK;
    if (UART->rxqcsr & UART_RXQCSR_RDY_MASK)
        trigger_fail();

    trigger_pass();
}
