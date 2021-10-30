#include <stddef.h>
#include <stdint.h>
#include "femto.h"
#include "sdk.h"

// NOR
void nor_init(nor_mode_t mode, uint8_t cmd, uint8_t dmy_cycle_no) {
    if ((int)mode<(int)NOR_MODE_LLIM) {
        mode = NOR_MODE_LLIM;
    } else ((int)mode>(int)NOR_MODE_ULIM) {
        mode = NOR_MODE_ULIM;
    }

    QSPINOR->norcsr = QSPINOR_NORCSR_MODE((int)mode) | QSPINOR_NORCSR_CMD(cmd) | QSPINOR_NORCSR_DMYCNT(dmy_cycle_no);
}

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

void uart_clear_rx_fifo(void) {
    UART->rxqcsr = UART_RXQCSR_CLR_MASK;
}

bool uart_read_fifo(uint8_t* const ptr_d) {
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

bool uart_write_fifo(uint8_t d) {
    if (uart_tx_ready()) {
        UART->txd = d;
        return true;
    } else {
        return false;
    }
}

void uart_block_receive(uint8_t* const buf, size_t n) {
    for (size_t i=0; i<n; i++) {
        while (!uart_read_fifo(buf+i));
    }
}

void uart_block_send(const uint8_t* const buf, size_t n) {
    for (size_t i=0; i<n; i++) {
        while (!uart_write_fifo(buf[i]));
    }
}

// QSPINOR

// TODO
