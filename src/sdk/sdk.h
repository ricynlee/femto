#ifndef _FEMTO_SDK_H
#define _FEMTO_SDK_H

#include <stddef.h>
#include <stdint.h>
#include "femto.h"

// NOR
typedef enum {
    NOR_MODE_111,
    NOR_MODE_112,
    NOR_MODE_114,
    NOR_MODE_122,
    NOR_MODE_144,
    NOR_MODE_222,
    NOR_MODE_444,
    NOR_MODE_LLIM = NOR_MODE_111,
    NOR_MODE_ULIM = NOR_MODE_444,
} nor_mode_t;

extern void nor_init(nor_mode_t mode, uint8_t cmd, uint8_t dmy_cycle_no, bool dmy_out, uint8_t dmy_out_pattern);

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

// QSPI
typedef enum femto_qspi_width qspi_width_t;
typedef enum {
    WHOLE_FIFO = 0, // send until fifo empty, or receive until fifo full
    DMY_CNT_16 = 0, // 0 stands for 16 dummy cycles
} qspi_cmd_cnt_t;

extern bool qspi_rxq_ready(void);
extern bool qspi_txq_ready(void);
extern void qspi_clear_rxq(void);
extern void qspi_clear_txq(void);
extern bool qspi_read_rxq(uint8_t* const ptr_d);
extern bool qspi_write_txq(uint8_t d);

extern bool qspi_is_busy(void);
extern void qspi_begin_receive(uint8_t n, qspi_width_t width);
extern void qspi_begin_send(uint8_t n, qspi_width_t width);
extern void qspi_send_dummy_cycle(uint8_t n, qspi_width_t width, bool dmy_out, uint8_t dmy_out_pattern);
extern void qspi_finish(void);

extern void qspi_receive_data(uint8_t* const buf, size_t n, qspi_width_t width);
extern void qspi_send_data(const uint8_t* const buf, size_t n, qspi_width_t width);

// TIMER
extern void timer_set(uint32_t val);
extern uint32_t timer_get(void);
extern void timer_delay_us(uint32_t val);

// EIC
extern unsigned get_interrupt_pending_flag(void);
extern void clr_interrupt_pending_flag(unsigned bit_mask);

// RESET
extern void reset_soc(void);
extern unsigned short get_reset_cause(void);
extern unsigned get_reset_info(void);
extern void set_reset_info(unsigned info);

#endif // _FEMTO_SDK_H
