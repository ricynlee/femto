#include "bsdk.h"

void go_uart_boot(void);

void main(void) {
    gpio_init();
    uart_clear_rxq();

    while (true)
        for (int t=0; t<2; t++) {
            for (int dc=0; dc<64; dc++) {
                for (int c=0; c<64; c++) {
                    timer_set(256u);
                    while (timer_get())
                        if (uart_rx_ready())
                            goto done_waiting;
                    light_leds(false, (t & 0x1u) ? (c>dc) : (c<=dc), false);
                }
            }

            if (t & 0x1u) {
                timer_set(768u*256u);
                while (timer_get())
                    if (uart_rx_ready())
                        goto done_waiting;
            }
        }

    done_waiting:

    // led off
    timer_delay_us(8u); // do not cause a glitch
    light_leds(false, false, false);

    // boot
    go_uart_boot();

    // shoud never arrive here
    while(true);
}

void led_flash_before_boot(void) {
    for (int i=0; i<3; i++) {
        for (int b=0; b<=1; b++) {
            light_leds(false, !b, false);
            timer_delay_us(1024u*256u);
        }
    }
}

void go_uart_boot(void) {
    uint8_t* tcm = (uint8_t*)TCM;

    do {
        while (uart_rx_ready()) {
            uart_read_rxq(tcm++);
            timer_set(512u*1024u); // ~0.5s time out
        }
    } while (timer_get());

    void (* const func)(void) = (void (*)(void))(TCM);

    led_flash_before_boot();

    func();
}
