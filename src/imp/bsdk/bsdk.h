#ifndef _BSDK_H
#define _BSDK_H

#include "sdk.h"

// Qspinor
extern void nor_bus_read_init(void);
extern void nor_erase_1MB(void);
extern void nor_erase_all(void);
extern void nor_program(size_t start, size_t size, const uint8_t* const data);
extern void nor_read(size_t start, size_t size, uint8_t* const data);

// Gpio
extern void gpio_init(void);
extern bool get_button_level(void);
extern void light_leds(bool red, bool green, bool blue);

#endif // _BSDK_H
