#include "bsdk.h"

// int8_t audata[60*1024];

void main(void) {
    gpio_init();

    while(!get_button_level()) {
        light_leds(true, false, false);
        timer_delay_us(100u*1000u);
        light_leds(false, true, false);
        timer_delay_us(100u*1000u);
        light_leds(false, false, true);
        timer_delay_us(100u*1000u);
    }
    light_leds(false, false, false);

    ada_sample_t sample;

    while(true) {
        while(!ada_get_sample(&sample));
        uart_write_txq(sample.data[1]);
        uart_write_txq(sample.data[2]);

//         for (int i=0; i<sizeof(audata); i+=3) {
//             while(!ada_get_sample(&sample));
//             audata[i+0] = sample.data[0];
//             audata[i+1] = sample.data[1];
//             audata[i+2] = sample.data[2];
//         }
//
//         while(!get_button_level()) {
//             light_leds(true, false, false);
//             timer_delay_us(200u*1000u);
//             light_leds(false, true, false);
//             timer_delay_us(200u*1000u);
//             light_leds(false, false, true);
//             timer_delay_us(200u*1000u);
//             light_leds(false, false, false);
//         }
//
//         uart_send_data((uint8_t*)audata, sizeof(audata));
    }
}
