#ifndef _FEMTO_SDK_H
#define _FEMTO_SDK_H

#include <stddef.h>
#include <stdint.h>
#include "femto.h"

// NOR
typedef enum femto_nor_mode nor_mode_t;

extern void nor_init(nor_mode_t mode, uint8_t cmd, uint8_t dmy_cycle_no);

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

extern void uart_receive_blob(uint8_t* const buf, size_t n);
extern void uart_send_blob(const uint8_t* const buf, size_t n);

// QSPINOR
typedef enum femto_qspinor_width qspinor_width_t;
typedef enum {
    WHOLE_FIFO = 0, // send until fifo empty, or receive until fifo full
    DMY_CNT_16 = 0, // 0 stands for 16 dummy cycles
} qspinor_cmd_cnt_t;

extern bool qspinor_rxq_ready(void);
extern bool qspinor_txq_ready(void);
extern void qspinor_clear_rxq(void);
extern void qspinor_clear_txq(void);
extern bool qspinor_read_rxq(uint8_t* const ptr_d);
extern bool qspinor_write_txq(uint8_t d);

extern bool qspinor_is_busy(void);
extern void qspinor_receive_data(uint8_t n, qspinor_width_t width);
extern void qspinor_send_data(uint8_t n, qspinor_width_t width);
extern void qspinor_send_dummy_cycle(uint8_t n, qspinor_width_t width);
extern void qspinor_finish(void);

extern void qspinor_receive_blob(uint8_t* const buf, size_t n, qspinor_width_t width);
extern void qspinor_send_blob(const uint8_t* const buf, size_t n, qspinor_width_t width);

// TIMER
extern void timer_set(uint32_t val);
extern uint32_t timer_get(void);
extern void timer_delay_us(uint32_t val);

// RESET
extern void reset_soc(void);
extern void reset_core(void);
extern void reset_uart(void);
extern void reset_gpio(void);
extern void reset_qspinor(void);
extern void reset_timer(void);

#endif // _FEMTO_SDK_H
