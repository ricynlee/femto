#include "bsdk.h"

const uint8_t wdata[] = "This is a test";
uint8_t rdata[sizeof(wdata)];

void main() {
    gpio_init();
    nor_bus_read_init();
    light_leds(true, false, false);
    nor_erase_block(0u);
    light_leds(false, true, false);
    nor_program(0u, wdata, sizeof(wdata));
    light_leds(false, false, true);
    nor_read(0u, rdata, sizeof(wdata));
}
