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
    debug_printf("Waiting for data to write to NOR...\n");

    gpio_init();
    uart_clear_rxq();

    while (1)
        for (int t=0; t<2; t++) {
            for (int dc=0; dc<64; dc++)
                for (int c=0; c<64; c++) {
                    timer_set(192u);
                    while (timer_get())
                        if (uart_rx_ready())
                            goto done_waiting;
                    light_leds((t & 0x1u) ? (c>dc) : (c<=dc), false, false);
                }
            if (t & 0x1u) {
                timer_set(1024u*256u);
                while (timer_get())
                    if (uart_rx_ready())
                        goto done_waiting;
            }
        }

    done_waiting:

    timer_delay_us(8u); // do not cause a glitch
    light_leds(false, false, false);

    // receive data, 128KB at most
    static uint8_t buffer[128u*1024u];
    size_t n=0;

    do {
        while (uart_rx_ready()) {
            uart_read_rxq(&buffer[n++]);
            timer_set(512u*1024u); // ~0.5s time out
        }
    } while (timer_get());

    // write nor
    debug_printf("Got %d bytes. Erasing NOR...\n", n);
    for (int i=0; i<(n+64u*1024u-1u)/(64u*1024u); i++)
        nor_erase_block(i);

    debug_printf("Done erasing. Programming NOR...\n");
    nor_program(0u, buffer, n);

    nor_bus_read_init();
    void (* const func)(void) = (void (*)(void))(NOR);
    debug_printf("Done programming. Ready for jumping to NOR!\n");
    func();

    // should never arrive here
    while(1);
}
