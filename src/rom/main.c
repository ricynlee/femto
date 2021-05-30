#include "femto.h"

gpio_t* const gpio = GPIO;
uart_t* const uart = UART;

#define BIT(n)  (1<<(n))
#define RED     BIT(1)
#define GREEN   BIT(2)
#define BLUE    BIT(3)

void main(){    
    gpio->dir=RED;
    gpio->io =RED;
    
    do {
#if 1 // set 0 for RTL test, 1 for FPGA test
        for (int i=0; i<100000 && uart->rxq_empty; i++);
#endif
        if (uart->rxq_empty)
            gpio->io = RED^gpio->io;
    } while(uart->rxq_empty);

    gpio->io = 0;
    gpio->dir = 0;

    volatile char* sram = (char*)0x20000000;

    do {
        *(sram++) = uart->rxd;
        for (int i=0; i<1000000 && uart->rxq_empty; i++);
    } while (!uart->rxq_empty);

    void (* const app)(void) = (void (*)(void))0x20000000;
    app();

    // should never reach here
    while (1);
}
