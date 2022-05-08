#include "bsdk.h"

void go_uart_boot(void);
void go_nor_boot(void);
void say_hello(void);

void main(void) {
    say_hello();

    gpio_init();
    uart_clear_rxq();

    for (int t=0; t<16; t++) {
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

    // boot flow
    if (uart_rx_ready()) {
        go_uart_boot();
    } else {
        go_nor_boot();
    }

    // should never arrive here
    while(1);
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
    uint8_t* sram = (uint8_t*)SRAM;

    do {
        while (uart_rx_ready()) {
            uart_read_rxq(sram++);
            timer_set(512u*1024u); // ~0.5s time out
        }
    } while (timer_get());

    void (* const func)(void) = (void (*)(void))(SRAM);

    led_flash_before_boot();

    func();
}

void go_nor_boot(void) {
    nor_bus_read_init();
    void (* const func)(void) = (void (*)(void))(NOR);

    led_flash_before_boot();

    func();
}

#define STR2ANL(s) (const uint8_t *)s, sizeof(s)-1 // string to array and length
void say_hello(void) {
    unsigned short rst_cause = get_reset_cause();
    unsigned rst_info = get_reset_info();

    uart_send_data(STR2ANL("femto Bootloader\n"));
    uart_send_data(STR2ANL("Reset "));
    while(!uart_write_txq((rst_cause & 0xfu) + '0'));
    while(!uart_write_txq(','));
    for (int i=7; i>=0; i--) {
        char c = (rst_info >> (4*i)) & 0xfu;
        c += (c < 10) ? '0' : 'a';
        while(!uart_write_txq(c));
    }
    while(!uart_write_txq('\n'));
    uart_send_data(STR2ANL("Send an SRAM app or wait for the NOR app\n"));
}
