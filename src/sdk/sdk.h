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

extern void uart_clear_rx_fifo(void);

extern bool uart_read_fifo(uint8_t* const ptr_d);
extern bool uart_write_fifo(uint8_t d);

extern void uart_block_receive(uint8_t* const buf, size_t n);
extern void uart_block_send(const uint8_t* const buf, size_t n);

// QSPINOR
typedef enum femto_qspinor_width qspinor_width_t;

extern bool qspinor_rx_ready(void);
extern bool qspinor_tx_ready(void);

extern void qspinor_clear_fifo(bool rx, bool tx);

extern bool qspinor_read_fifo(uint8_t* const ptr_d);
extern bool qspinor_write_fifo(uint8_t d);

typedef enum {
    WHOLE_FIFO = 0, // send until fifo empty, or receive until fifo full
    DMY_CNT_16 = 0, // 0 stands for 16 dummy cycles
} qspinor_cmd_cnt_t;

extern bool qspinor_busy(void);
extern void qspinor_fifo_send(uint8_t n, qspinor_width_t width);
extern void qspinor_fifo_receive(uint8_t n, qspinor_width_t width);
extern void qspinor_dummy_cycle(uint8_t n);
extern void qspinor_stop(void);

extern void qspinor_block_receive(uint8_t* const buf, size_t n);
extern void qspinor_block_send(const uint8_t* const buf, size_t n);

// TIMER
extern void timer_set(uint32_t val);
extern uint32_t timer_get(void);

// RESET
extern void reset_soc(void);
extern void reset_core(void);
extern void reset_uart(void);
extern void reset_gpio(void);
extern void reset_qspinor(void);
extern void reset_timer(void);

#endif // _FEMTO_SDK_H
