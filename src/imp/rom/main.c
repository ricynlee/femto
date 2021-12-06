#include "bsdk.h"

void go_uart_boot(void);
void go_nor_boot(void);

void main(void) {
    gpio_init();

    ada_sample_t sample;

    while(true) {
        while(!ada_get_sample(&sample));
        uart_write_txq(sample.data[0]);
        uart_write_txq(sample.data[1]);
        uart_write_txq(sample.data[2]);
    }
}
