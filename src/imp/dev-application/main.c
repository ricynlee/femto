#include <stdlib.h> // int abs
#include "bsdk.h"

#define ENVELOPE_THRESH 64

int demodulate(void) {
    static int prev_raw = 0;

    int acc = 0;

    for (int i=0; i<103; i++) {
        ada_sample_t sample;

        // Sampling & Band-pass Filtering
        while(!ada_get_sample(&sample));
        int raw = sample.value;

        // Recitification
        raw = abs(raw);

        // Envelop Detection
        raw = (prev_raw+raw)/2;
        if (raw>prev_raw+ENVELOPE_THRESH)
            raw = prev_raw+ENVELOPE_THRESH;
        else if (raw<prev_raw-ENVELOPE_THRESH)
            raw = prev_raw-ENVELOPE_THRESH;
        prev_raw = raw;

        // Accumulation
        acc += raw;
    }

    return acc;
}

int get_noise_level(void) {
    int noise_level = 0;
    for (int i=0; i<16; i++) {
        noise_level += demodulate();
    }
    return noise_level/16;
}

uint8_t decode(int thresh) {
    uint8_t byte = 0;
    bool bin_level;
    int sum;

    while (true) {
        // Start symbol detection
        do {
            bin_level = (bool)(demodulate()>thresh);
        } while (!bin_level);
        sum = 0;
        for (int i=1; i<7; i++) {
            bin_level = (bool)(demodulate()>thresh);
            sum += (int)(!bin_level);
            if (sum>3)
                break;
        }
        if (sum>3)
            continue; // Start symbol not detected

        // Decode
        for (int bit=7; bit>=0; bit--) {
            sum = 0;
            for (int i=0; i<7; i++) {
                bin_level = (bool)(demodulate()>thresh);
                sum += (int)bin_level;
            }
            byte |= ((uint8_t)(sum>3))<<bit;
        }

        // Stop symbol confirmation
        sum = 0;
        for (int i=0; i<7; i++) {
            bin_level = (bool)(demodulate()>thresh);
            sum += (int)bin_level;
            if (sum>3)
                break;
        }
        if (sum>3)
            continue; // Stop symbol not detected

        break;
    }

    return byte;
}

void main(void) {
    gpio_init();
    ada_configure(true, 4u);

    timer_delay_us(1000000u);
    int noise_level = get_noise_level();

    int thresh = noise_level + 2000;

    bool red = true;

    while (true) {
        uart_write_txq(decode(thresh));
        light_leds(red, false, false);
        red = !red;
    }
}
