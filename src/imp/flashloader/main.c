#include "bsdk.h"
#include <stdio.h>

#define debug_printf(...) \
    ({                                                                  \
        char debug_buffer[256];                                         \
        int ret = sprintf(debug_buffer, __VA_ARGS__);                   \
        for (int i=0; i<sizeof(debug_buffer) && debug_buffer[i]; i++) { \
            while(!uart_write_txq(debug_buffer[i]));                    \
        }                                                               \
        ret;                                                            \
    })

void main(void) {
    debug_printf("Hello, world!\n");

    gpio_init();

    while (1)
        for (int t=0; t<2; t++) {
            for (int dc=0; dc<64; dc++)
                for (int c=0; c<64; c++) {
                    timer_set(192u);
                    while (timer_get());
                    light_leds((t & 0x1u) ? (c>dc) : (c<=dc), false, false);
                }
            if (t & 0x1u) {
                timer_set(1024u*256u);
                while (timer_get());
            }
        }
}
