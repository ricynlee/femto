#include <stddef.h>
#include <stdint.h>
#include "femto.h"
#include "sdk.h"

// NOR
void nor_init(nor_mode_t mode, uint8_t cmd, uint8_t dmy_cycle_no, bool dmy_out, uint8_t dmy_out_pattern) {
    if ((int)mode<(int)NOR_MODE_LLIM) {
        mode = NOR_MODE_LLIM;
    } else if ((int)mode>(int)NOR_MODE_ULIM) {
        mode = NOR_MODE_ULIM;
    }

    QSPINOR->norcmd = cmd;
    QSPINOR->norcsr = QSPINOR_NORCSR_MODE((int)mode)             |
                      QSPINOR_NORCSR_DMYCNT(dmy_cycle_no)        |
                      QSPINOR_NORCSR_DMYPAT(dmy_out_pattern)     |
                      (dmy_out ? QSPINOR_NORCSR_DMYDIR_MASK : 0u);
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

// QSPINOR
bool qspinor_rxq_ready(void) {
    return (QSPINOR->rxqcsr & QSPINOR_RXQCSR_CNT_MASK) ? true : false;
}

bool qspinor_txq_ready(void) {
    return (QSPINOR->txqcsr & QSPINOR_RXQCSR_CNT_MASK) ? true : false;
}

void qspinor_clear_rxq(void) {
    QSPINOR->rxqcsr = QSPINOR_RXQCSR_CLR_MASK;
}

void qspinor_clear_txq(void) {
    QSPINOR->txqcsr = QSPINOR_TXQCSR_CLR_MASK;
}

bool qspinor_read_rxq(uint8_t* const ptr_d) {
    if (!ptr_d) {
        return false;
    }

    if (qspinor_rxq_ready()) {
        *ptr_d = QSPINOR->rxd;
        return true;
    } else {
        return false;
    }
}

bool qspinor_write_txq(uint8_t d) {
    if (qspinor_txq_ready()) {
        QSPINOR->txd = d;
        return true;
    } else {
        return false;
    }
}

bool qspinor_is_busy(void) {
    if (QSPINOR->ipcsr & QSPINOR_IPCSR_BSY_MASK) {
        return true;
    } else {
        return false;
    }
}

void qspinor_begin_receive(uint8_t n, qspinor_width_t width) {
    QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK     |
                     QSPINOR_IPCSR_DIR(DIR_IN)  |
                     QSPINOR_IPCSR_WID(width)   |
                     QSPINOR_IPCSR_CNT(n)       ;
}

void qspinor_begin_send(uint8_t n, qspinor_width_t width) {
    QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK     |
                     QSPINOR_IPCSR_DIR(DIR_OUT) |
                     QSPINOR_IPCSR_WID(width)   |
                     QSPINOR_IPCSR_CNT(n)       ;
}

void qspinor_send_dummy_cycle(uint8_t n, qspinor_width_t width) {
    QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK     |
                     QSPINOR_IPCSR_DMY_MASK     |
                     QSPINOR_IPCSR_DIR(DIR_OUT) |
                     QSPINOR_IPCSR_WID(width)   |
                     QSPINOR_IPCSR_CNT(n)       ;
}

void qspinor_finish(void) {
    QSPINOR->ipcsr = QSPINOR_IPCSR_SEL_MASK & ~QSPINOR_IPCSR_SEL_MASK;
}

void qspinor_receive_data(uint8_t* const buf, size_t n, qspinor_width_t width) {
    if (!buf || !n)
        return;

    while (qspinor_is_busy());
    qspinor_clear_rxq();

    for (size_t i=0, rxn; i<n; i+=rxn) {
        rxn = n-i;
        if (rxn>QSPINOR_FIFO_DEPTH) {
            rxn = QSPINOR_FIFO_DEPTH;
        }
        qspinor_begin_receive(rxn, width);
        while (qspinor_is_busy());

        for (size_t k=0; k<rxn; k++) {
            buf[i+k] = QSPINOR->rxd;
        }
    }
}

void qspinor_send_data(const uint8_t* const buf, size_t n, qspinor_width_t width) {
    if (!buf || !n)
        return;

    while (qspinor_is_busy());
    qspinor_clear_txq();

    for (size_t i=0, txn; i<n; i+=txn) {
        txn = n-i;
        if (txn>QSPINOR_FIFO_DEPTH) {
            txn = QSPINOR_FIFO_DEPTH;
        }
        for (size_t k=0; k<txn; k++) {
            QSPINOR->txd = buf[i+k];
        }

        qspinor_begin_send(txn, width);
        while (qspinor_is_busy());
    }
}

/* DO NOT USE
 *  Core speed too low: qspinor_receive_blob will probably block control flow!
 */
void qspinor_receive_blob(uint8_t* const buf, size_t n, qspinor_width_t width) __attribute__((optimize("O3")));
void qspinor_receive_blob (uint8_t* const buf, size_t n, qspinor_width_t width) {
    if (!buf || !n)
        return;

    while (qspinor_is_busy());
    qspinor_clear_rxq();

    uint8_t rxn = (uint8_t)(n>=QSPINOR_FIFO_DEPTH ? WHOLE_FIFO : n);
    qspinor_begin_receive(rxn, width);

    register size_t i=0;
    while (i<n) {
        register size_t e = i+QSPINOR_RXQCSR_CNT(QSPINOR->rxqcsr);
        for (e=(n<e?n:e); i<e; i++) {
            buf[i] = QSPINOR->rxd;
        }
    }

    while (qspinor_is_busy());
    qspinor_clear_rxq();
}

/* DO NOT USE
 *  Core speed too low: qspinor_send_blob will probably block control flow!
 */
void qspinor_send_blob(const uint8_t* const buf, size_t n, qspinor_width_t width) __attribute__((optimize("O3")));
void qspinor_send_blob (const uint8_t* const buf, size_t n, qspinor_width_t width) {
    if (!buf || !n)
        return;

    while (qspinor_is_busy());
    qspinor_clear_txq();

    uint8_t txn = (uint8_t)(n>=QSPINOR_FIFO_DEPTH ? WHOLE_FIFO : n);
    qspinor_begin_send(txn, width);

    register size_t i=0;
    while (i<n) {
        register size_t e = i+QSPINOR_TXQCSR_CNT(QSPINOR->txqcsr);
        for (e=(n<e?n:e); i<e; i++) {
            QSPINOR->txd = buf[i];
        }
    }

    while (qspinor_is_busy());
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

// RESET
void reset_soc(void) {
    RESET->rst = RESET_ALL;
}

void reset_core(void) {
    RESET->rst = RESET_CORE;
}

void reset_uart(void) {
    RESET->rst = RESET_UART;
}

void reset_gpio(void) {
    RESET->rst = RESET_GPIO;
}

void reset_qspinor(void) {
    RESET->rst = RESET_QSPINOR;
}

void reset_timer(void) {
    RESET->rst = RESET_TIMER;
}
