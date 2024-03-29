#include "bsdk.h"

/* No data/bss */

void main(void) {
    gpio_init();

    while (1)
        for (int t=0; t<2; t++) {
            for (int dc=0; dc<64; dc++)
                for (int c=0; c<64; c++) {
                    timer_delay_us(192u); // looks like NOR is too slow to use 256
                    light_leds((t & 0x1u) ? (c>dc) : (c<=dc), false, false);
                }
            if (t & 0x1u) {
                timer_delay_us(768u*256u);
            }
        }
}
