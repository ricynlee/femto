#ifndef _BSDK_H
#define _BSDK_H

#include "sdk.h"

// Qspinor
extern void nor_bus_read_init(void);
extern void nor_erase_block(size_t block_offset);
extern void nor_program(size_t start_page_offset, const uint8_t* const data, size_t size);
extern void nor_read(size_t byte_offset, uint8_t* const data, size_t size);

// Gpio
extern void gpio_init(void);
extern bool get_button_level(void);
extern void light_leds(bool red, bool green, bool blue);

#endif // _BSDK_H
