#include <stdint.h>
#include "bsdk.h"

// Gpio
enum {
    BUTTON_INDEX,
    RED_INDEX,
    GREEN_INDEX,
    BLUE_INDEX,
};

void gpio_init(void) {
    light_leds(false, false, false);
    gpio_set_dir(BUTTON_INDEX, DIR_IN );
    gpio_set_dir(RED_INDEX,    DIR_OUT);
    gpio_set_dir(GREEN_INDEX,  DIR_OUT);
    gpio_set_dir(BLUE_INDEX,   DIR_OUT);
}

bool get_button_level(void) {
    return gpio_get(BUTTON_INDEX);
}

void light_leds(bool red, bool green, bool blue) {
    gpio_set(RED_INDEX,   !red  );
    gpio_set(GREEN_INDEX, !green);
    gpio_set(BLUE_INDEX,  !blue );
}
