#include <stdlib.h> // int abs
#include "bsdk.h"

#define THRESH  7000

bool decision(void) {
    int sum = 0;
    ada_sample_t sample;

    for (int i=0; i<7; i++) {
        while(!ada_get_sample(&sample));
        sum += (int)sample.value;
    }

    return (bool)(sum>7000);
}

uint8_t decode(void) {
    bool    level[3];
    uint8_t byte;

    while (true) {
        // start symbol detection
        while (!decision());
        for (int i=0; i<3; i++) {
            timer_delay_us(25*1200);
            level[i] = decision();
            light_leds(level[i], false, false);
        }

        if ((level[0] && level[1]) || (level[1] && level[2]) || (level[2] && level[0]))
            timer_delay_us(25*1200);
        else
            continue;

        // decoding
        byte = 0;
        for (int b=7; b>=0; b--) {
            for (int i=0; i<3; i++) {
                timer_delay_us(25*1200);
                level[i] = decision();
                light_leds(level[i], false, false);
            }
            byte |= (((level[0] && level[1]) || (level[1] && level[2]) || (level[2] && level[0]))<<b);
        }

        timer_delay_us(25*1200);

        // stop symbol confirmation
        for (int i=0; i<3; i++) {
            timer_delay_us(25*1200);
            level[i] = decision();
            light_leds(level[i], false, false);
        }

        if ((level[0] && level[1]) || (level[1] && level[2]) || (level[2] && level[0]))
            continue;
        else
            timer_delay_us(25*600);

        break;
    }
    return byte;
}

void main(void) {
    gpio_init();
    ada_configure(true, 4u);

    timer_delay_us(1000000u);

    while (true) {
        uart_write_txq(decode());
        // decode();
    }
}
