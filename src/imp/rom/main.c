#include "bsdk.h"

void go_uart_boot(void);
void go_nor_boot(void);

void main(void) {
    // wait ~16 sec for uart activity
    gpio_init();
    uart_clear_rx_fifo();

    for (int t=0; t<16; t++) {
        for (int dc=0; dc<64; dc++) {
            for (int c=0; c<64; c++) {
                timer_set(192u);
                while (timer_get())
                    if (uart_rx_ready())
                        goto done_waiting;
                light_leds(false, (t & 0x1u) ? (c>dc) : (c<=dc), false);
            }
        }

        if (t & 0x1u) {
            timer_set(1024u*256u);
            while (timer_get())
                if (uart_rx_ready())
                    goto done_waiting;
        }
    }

    done_waiting:

    // led off
    timer_set(8u); // do not cause a glitch
    while (timer_get());
    light_leds(false, false, false);

    // boot flow
    if (uart_rx_ready()) {
        go_uart_boot();
    } else {
        go_nor_boot();
    }

    // should never arrive here
    while(1);
}

void go_uart_boot(void) {
    uint8_t* sram = (uint8_t*)SRAM;

    do {
        while (uart_rx_ready()) {
            uart_read_fifo(sram++);
            timer_set(512u*1024u); // ~0.5s time out
        }
    } while (timer_get());

    void (* const func)(void) = (void (*)(void))(SRAM);

    light_leds(false, true, false);
    timer_set(1024u*256u);
    while (timer_get());
    light_leds(false, false, false);
    timer_set(1024u*256u);
    while (timer_get());
    light_leds(false, true, false);
    timer_set(1024u*256u);
    while (timer_get());
    light_leds(false, false, false);
    timer_set(1024u*256u);
    while (timer_get());
    light_leds(false, true, false);
    timer_set(1024u*256u);
    while (timer_get());
    light_leds(false, false, false);

    func();
}

void go_nor_boot(void) {
    nor_bus_read_init();
    void (* const func)(void) = (void (*)(void))(NOR);

    light_leds(false, true, false);
    timer_set(1024u*256u);
    while (timer_get());
    light_leds(false, false, false);
    timer_set(1024u*256u);
    while (timer_get());
    light_leds(false, true, false);
    timer_set(1024u*256u);
    while (timer_get());
    light_leds(false, false, false);
    timer_set(1024u*256u);
    while (timer_get());
    light_leds(false, true, false);
    timer_set(1024u*256u);
    while (timer_get());
    light_leds(false, false, false);

    func();
}
