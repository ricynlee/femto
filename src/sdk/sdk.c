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

    QSPI->norcmd = cmd;
    QSPI->norcsr = QSPI_NORCSR_MODE((int)mode)             |
                      QSPI_NORCSR_DMYCNT(dmy_cycle_no)        |
                      QSPI_NORCSR_DMYPAT(dmy_out_pattern)     |
                      (dmy_out ? QSPI_NORCSR_DMYDIR_MASK : 0u);
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
    return (UART->txqcsr & UART_TXQCSR_RDY_MASK) ? true : false;
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

// QSPI
bool qspi_rxq_ready(void) {
    return (QSPI->rxqcsr & QSPI_RXQCSR_CNT_MASK) ? true : false;
}

bool qspi_txq_ready(void) {
    return (QSPI->txqcsr & QSPI_RXQCSR_CNT_MASK) ? true : false;
}

void qspi_clear_rxq(void) {
    QSPI->rxqcsr = QSPI_RXQCSR_CLR_MASK;
}

void qspi_clear_txq(void) {
    QSPI->txqcsr = QSPI_TXQCSR_CLR_MASK;
}

bool qspi_read_rxq(uint8_t* const ptr_d) {
    if (!ptr_d) {
        return false;
    }

    if (qspi_rxq_ready()) {
        *ptr_d = QSPI->rxd;
        return true;
    } else {
        return false;
    }
}

bool qspi_write_txq(uint8_t d) {
    if (qspi_txq_ready()) {
        QSPI->txd = d;
        return true;
    } else {
        return false;
    }
}

bool qspi_is_busy(void) {
    if (QSPI->ipcsr & QSPI_IPCSR_BSY_MASK) {
        return true;
    } else {
        return false;
    }
}

void qspi_begin_receive(uint8_t n, qspi_width_t width) {
    QSPI->ipcsr = QSPI_IPCSR_SEL_MASK     |
                     QSPI_IPCSR_DIR(DIR_IN)  |
                     QSPI_IPCSR_WID(width)   |
                     QSPI_IPCSR_CNT(n)       ;
}

void qspi_begin_send(uint8_t n, qspi_width_t width) {
    QSPI->ipcsr = QSPI_IPCSR_SEL_MASK     |
                     QSPI_IPCSR_DIR(DIR_OUT) |
                     QSPI_IPCSR_WID(width)   |
                     QSPI_IPCSR_CNT(n)       ;
}

void qspi_send_dummy_cycle(uint8_t n, qspi_width_t width, bool dmy_out, uint8_t dmy_out_pattern) {
    QSPI->ipcsr = QSPI_IPCSR_SEL_MASK                        |
                     QSPI_IPCSR_DMY_MASK                        |
                     QSPI_IPCSR_DIR(dmy_out ? DIR_OUT : DIR_IN) |
                     QSPI_IPCSR_DOP(dmy_out_pattern)            |
                     QSPI_IPCSR_WID(width)                      |
                     QSPI_IPCSR_CNT(n)                          ;
}

void qspi_finish(void) {
    QSPI->ipcsr = QSPI_IPCSR_SEL_MASK & ~QSPI_IPCSR_SEL_MASK;
}

void qspi_receive_data(uint8_t* const buf, size_t n, qspi_width_t width) {
    if (!buf || !n)
        return;

    while (qspi_is_busy());
    qspi_clear_rxq();

    for (size_t i=0, rxn; i<n; i+=rxn) {
        rxn = n-i;
        if (rxn>QSPI_FIFO_DEPTH) {
            rxn = QSPI_FIFO_DEPTH;
        }
        qspi_begin_receive(rxn, width);
        while (qspi_is_busy());

        for (size_t k=0; k<rxn; k++) {
            buf[i+k] = QSPI->rxd;
        }
    }
}

void qspi_send_data(const uint8_t* const buf, size_t n, qspi_width_t width) {
    if (!buf || !n)
        return;

    while (qspi_is_busy());
    qspi_clear_txq();

    for (size_t i=0, txn; i<n; i+=txn) {
        txn = n-i;
        if (txn>QSPI_FIFO_DEPTH) {
            txn = QSPI_FIFO_DEPTH;
        }
        for (size_t k=0; k<txn; k++) {
            QSPI->txd = buf[i+k];
        }

        qspi_begin_send(txn, width);
        while (qspi_is_busy());
    }
}

/* DO NOT USE
 *  Core speed too low: qspi_receive_blob will probably block control flow!
 */
void qspi_receive_blob(uint8_t* const buf, size_t n, qspi_width_t width) __attribute__((optimize("O3")));
void qspi_receive_blob (uint8_t* const buf, size_t n, qspi_width_t width) {
    if (!buf || !n)
        return;

    while (qspi_is_busy());
    qspi_clear_rxq();

    uint8_t rxn = (uint8_t)(n>=QSPI_FIFO_DEPTH ? WHOLE_FIFO : n);
    qspi_begin_receive(rxn, width);

    register size_t i=0;
    while (i<n) {
        register size_t e = i+QSPI_RXQCSR_CNT(QSPI->rxqcsr);
        for (e=(n<e?n:e); i<e; i++) {
            buf[i] = QSPI->rxd;
        }
    }

    while (qspi_is_busy());
    qspi_clear_rxq();
}

/* DO NOT USE
 *  Core speed too low: qspi_send_blob will probably block control flow!
 */
void qspi_send_blob(const uint8_t* const buf, size_t n, qspi_width_t width) __attribute__((optimize("O3")));
void qspi_send_blob (const uint8_t* const buf, size_t n, qspi_width_t width) {
    if (!buf || !n)
        return;

    while (qspi_is_busy());
    qspi_clear_txq();

    uint8_t txn = (uint8_t)(n>=QSPI_FIFO_DEPTH ? WHOLE_FIFO : n);
    qspi_begin_send(txn, width);

    register size_t i=0;
    while (i<n) {
        register size_t e = i+QSPI_TXQCSR_CNT(QSPI->txqcsr);
        for (e=(n<e?n:e); i<e; i++) {
            QSPI->txd = buf[i];
        }
    }

    while (qspi_is_busy());
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

// EIC
unsigned get_interrupt_pending_flag(void) {
    return EIC->ipfr;
}

void clr_interrupt_pending_flag(unsigned bit_mask) {
    EIC->ipfr = bit_mask & (EIC_IPFR_TMRF | EIC_IPFR_UARTF);
}

// RESET
void reset_soc(void) {
    RESET->rst = 1;
}

unsigned short get_reset_cause(void) {
    return RESET->cause;
}

unsigned get_reset_info(void) {
    return RESET->info;
}

void set_reset_info(unsigned info) {
    RESET->info = info;
}
