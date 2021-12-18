#ifndef _BSDK_H
#define _BSDK_H

#include "sdk.h"

// Gpio
extern void gpio_init(void);
extern bool get_button_level(void);
extern void light_leds(bool red, bool green, bool blue);

#endif // _BSDK_H
