#include "bsdk.h"

void main(){
    bool r = false, g=false, b=false;

    gpio_init();

    while (1) {
        while (!get_button_level());
        while (get_button_level());
        light_leds(r, false, false);
        r = !r;
    }
}
