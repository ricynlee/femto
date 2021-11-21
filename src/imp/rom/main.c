#include "bsdk.h"

void go_uart_boot(void);
void go_nor_boot(void);

void main(void) {
    // wait 16 sec for uart activity
    gpio_init();
    uart_clear_rx_fifo();

    for (int t=0; t<8; t++) {
        for (int dc=0; dc<64; dc++) {
            for (int c=0; c<64; c++) {
                timer_set(256u);
                while (timer_get())
                    if (uart_rx_ready())
                        goto done_waiting;
                light_leds(false, c<dc, false);
            }
        }

        for (int dc=0; dc<64; dc++) {
            for (int c=0; c<64; c++) {
                timer_set(256u);
                while (timer_get())
                    if (uart_rx_ready())
                        goto done_waiting;
                light_leds(false, c>=dc, false);
            }
        }
    }

    done_waiting:

    // led off
    timer_set(128u); // do not cause a glitch
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
    // TODO

}

void go_nor_boot(void) {
    void (*func)(void) = (void (*)(void))(NOR);
    func();
    while(1);
}
