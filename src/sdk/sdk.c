#include <stddef.h>
#include <stdint.h>
#include "femto.h"
#include "sdk.h"

// GPIO
gpio_dir_t gpio_get_dir(uint8_t pin_index) {
    pin_index &= 0x1fU;
    return (GPIO->dir & (1U<<pin_index)) ? DIR_OUT : DIR_IN;
}

void gpio_set_dir(uint8_t pin_index, gpio_dir_t dir) {
    pin_index &= 0x1fU;
    uint32_t val = GPIO->dir;
    if (dir==DIR_OUT) {
        val |= (1U<<pin_index);
    } else /*DIR_IN*/ {
        val &= ~(1U<<pin_index);
    }
    GPIO->dir = val;
}

bool gpio_get(uint8_t pin_index) {
    pin_index &= 0x1fU;
#if 0 // Do we need to return values for DIR_IN only?
    if (gpio_get_dir(pin_index)==DIR_OUT) {
        return (GPIO->io & (1U<<pin_index)) ? true : false;
    } else {
        return (GPIO->io & (1U<<pin_index)) ? true : false;
    }
#else
    return (GPIO->io & (1U<<pin_index)) ? true : false;
#endif
}

void gpio_set(uint8_t pin_index, bool level) {
    pin_index &= 0x1fU;
#if 0 // Do we need to act for DIR_OUT only?
    if (gpio_get_dir(pin_index)!=DIR_OUT) {
        return;
    }
#endif
    if (level) {
        GPIO->io |= (1U<<pin_index);
    } else {
        GPIO->io &= ~(1U<<pin_index);
    }
}

void gpio_tog(uint8_t pin_index) {
    gpio_set(pin_index, !gpio_get(pin_index));
}

// UART
bool uart_rx_ready(void) {
    return (UART->rxqcsr & UART_RXQCSR_RDY_MASK) ? true : false;
}

bool uart_tx_ready(void) {
    return (UART->txqsr & UART_TXQSR_RDY_MASK) ? true : false;
}

void uart_clear_rxq(void) {
    UART->rxqcsr = UART_RXQCSR_CLR_MASK;
}

bool uart_read_rxq(uint8_t* const ptr_d) {
    if (!ptr_d) {
        return false;
    }

    if (uart_rx_ready()) {
        *ptr_d = UART->rxd;
        return true;
    } else {
        return false;
    }
}

bool uart_write_txq(uint8_t d) {
    if (uart_tx_ready()) {
        UART->txd = d;
        return true;
    } else {
        return false;
    }
}

void uart_receive_data(uint8_t* const buf, size_t n) {
    for (size_t i=0; i<n; i++) {
        while (!uart_read_rxq(buf+i));
    }
}

void uart_send_data(const uint8_t* const buf, size_t n) {
    for (size_t i=0; i<n; i++) {
        while (!uart_write_txq(buf[i]));
    }
}

// TIMER
void timer_set(uint32_t val) {
    TIMER->tr = val;
}

uint32_t timer_get(void) {
    return TIMER->tr;
}

void timer_delay_us(uint32_t val) {
    timer_set(val);
    while(timer_get());
}

// AUDACQ
bool ada_get_sample(ada_sample_t* const ptr_d) {
    static int16_t prev_count = 0;

    ptr_d->ssr = ADA->ssr;

    bool status;

    if (ptr_d->count == prev_count) {
        status = false;
    } else {
        prev_count = ptr_d->count;
        status = false;
    }

    return status;
}

void ada_configure(bool enable_filter, uint8_t trunc_width) {
    ADA->cr = ADA_FILTEN(enable_filter) | ADA_TRUNC(trunc_width);
}
