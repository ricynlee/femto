#include <stdio.h>
#include "femto.h"
#include "qspinor.h"

gpio_t* const gpio = GPIO;
uart_t* const uart = UART;

// GPIO
#define BIT(n)  (1<<(n))
#define RED     BIT(1)
#define GREEN   BIT(2)
#define BLUE    BIT(3)

/*
 entry
 */
#include "../nor.h" // XIP image
#define SIZE_3MB    (0x00300000u)

#define debug_printf(...) \
    ({                                                                  \
        char debug_buffer[256];                                         \
        int ret = sprintf(debug_buffer, __VA_ARGS__);                   \
        for (int i=0; i<sizeof(debug_buffer) && debug_buffer[i]; i++) { \
            while(uart->txq_full);                                      \
            uart->txd = debug_buffer[i];                                \
        }                                                               \
        ret;                                                            \
    })

void main() {
    // restore_spi();
    // quad_enable();
    if ((*(int*)(QSPINOR_DATA+SIZE_3MB)) != (*(int*)image)) {
        debug_printf("Flash is being correctly programmed\n");
        erase(QSPINOR_DATA+SIZE_3MB, sizeof(image));
        program(QSPINOR_DATA+SIZE_3MB, image, sizeof(image));
    }

    // Jump to QSPINOR
    gpio->io=0;
    gpio->dir=GREEN;
    
    for (int i=0; i<36; i++) {
        gpio->io = GREEN ^ gpio->io;
        for (int i=0; i<60000; i++);
    }

    gpio->dir = 0;
    gpio->io = 0;

    for (int i=0; i<64; i++) {
        debug_printf("%d: 0x%02x\n", i, ((char*)(QSPINOR_DATA+SIZE_3MB))[i]);
    }

    void (* const app)(void) = (void (*)(void))(QSPINOR_DATA+SIZE_3MB);

    app();

    while(1);
}
