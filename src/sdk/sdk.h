#ifndef _FEMTO_SDK_H
#define _FEMTO_SDK_H

#include <stddef.h>
#include <stdint.h>
#include "femto.h"

// GPIO
typedef enum femto_io_dir gpio_dir_t;

extern gpio_dir_t gpio_get_dir(uint8_t pin_index);
extern void gpio_set_dir(uint8_t pin_index, gpio_dir_t dir);

extern bool gpio_get(uint8_t pin_index);
extern void gpio_set(uint8_t pin_index, bool level);
extern void gpio_tog(uint8_t pin_index);

// UART
extern bool uart_rx_ready(void);
extern bool uart_tx_ready(void);

extern void uart_clear_rxq(void);

extern bool uart_read_rxq(uint8_t* const ptr_d);
extern bool uart_write_txq(uint8_t d);

extern void uart_receive_data(uint8_t* const buf, size_t n);
extern void uart_send_data(const uint8_t* const buf, size_t n);

// TIMER
extern void timer_set(uint32_t val);
extern uint32_t timer_get(void);
extern void timer_delay_us(uint32_t val);

// ADAACQ
typedef union {
    int32_t ssr;
    struct {
        int16_t value;
        uint8_t count;
        uint8_t :7;
        uint8_t fresh:1;
    };
    uint8_t data[sizeof(int16_t)];
} ada_sample_t;

extern bool ada_get_sample(ada_sample_t* const ptr_d);
extern void ada_configure(bool enable_filter, uint8_t trunc_width);

#endif // _FEMTO_SDK_H
