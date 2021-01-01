#include "femto.h"

gpio_t* const gpio = GPIO;
uart_t* const uart = UART;

#define BIT(n)  (1<<(n))
#define RED     BIT(1)
#define GREEN   BIT(2)
#define BLUE    BIT(3)

void main() {
    gpio->dir=BLUE;
    gpio->io =BLUE;

    while (1) {
        for (int i=0; i<5000; i++);
        gpio->io = BLUE^gpio->io;
    }
}
