#include <stdint.h>
#include "bsdk.h"

// Qspinor - W25Q128
typedef union {
    size_t  offset_n;
    uint8_t offset_a[4];
} offset_converter_t;

void nor_bus_read_init(void) {
    nor_init(NOR_MODE_122, 0xbbu, 4u);
}

void nor_erase_block(size_t block_offset) {
    offset_converter_t offset = {.offset_n = block_offset*(64u*1024u)};
    uint8_t status;

    qspinor_finish();
    qspinor_clear_txq();
    qspinor_clear_rxq();

    // Send WREN
    qspinor_write_txq(0x06u);
    qspinor_send_data(1u, QSPINOR_X1);
    qspinor_finish();

    // Send erasure command
    timer_set(10u);
    while(timer_get());
    qspinor_write_txq(0xd8u);
    for (int i=2; i>=0; i--)
        qspinor_write_txq(offset.offset_a[i]);
    qspinor_send_data(4u, QSPINOR_X1);
    qspinor_finish();

    // Wait for finish
    do {
        timer_set(10u);
        while(timer_get());
        qspinor_write_txq(0x05u);
        qspinor_send_data(1u, QSPINOR_X1);
        qspinor_receive_data(1u, QSPINOR_X1);
        qspinor_finish();
        qspinor_read_rxq(&status);
    } while(status & 0x1u);
}

void nor_program(size_t start_page_offset, const uint8_t* const data, size_t size) {
    if (!data || !size)
        return;

    offset_converter_t offset = {.offset_n = start_page_offset*256u};
    uint8_t status;
    size_t k = 0, n;

    while (size) {
        n = size>256u ? 256u : size;

        qspinor_finish();
        qspinor_clear_txq();
        qspinor_clear_rxq();

        // Send WREN
        qspinor_write_txq(0x06u);
        qspinor_send_data(1u, QSPINOR_X1);
        qspinor_finish();

        // Send page program command & data
        timer_set(10u);
        while(timer_get());
        qspinor_write_txq(0x02u);
        for (int i=2; i>=0; i--)
            qspinor_write_txq(offset.offset_a[i]);
        qspinor_send_data(4u, QSPINOR_X1);
        qspinor_send_blob(data+k, n, QSPINOR_X1);
        qspinor_finish();

        // Wait for finish
        do {
            timer_set(10u);
            while(timer_get());
            qspinor_write_txq(0x05u);
            qspinor_send_data(1u, QSPINOR_X1);
            qspinor_receive_data(1u, QSPINOR_X1);
            qspinor_finish();
            qspinor_read_rxq(&status);
        } while(status & 0x1u);

        size -= n;
        k += n;
    }
}

void nor_read(size_t byte_offset, uint8_t* const data, size_t size) {
    if (!data || !size)
        return;

    offset_converter_t offset = {.offset_n = byte_offset};

    qspinor_finish();
    qspinor_clear_txq();
    qspinor_clear_rxq();

    // Send command
    qspinor_write_txq(0xbbu);
    qspinor_send_data(1u, QSPINOR_X1);

    // Send address
    for (int i=2; i>=0; i--)
        qspinor_write_txq(offset.offset_a[i]);
    qspinor_send_data(3u, QSPINOR_X2);

    // Send dummy cycles
    qspinor_send_dummy_cycle(4u, QSPINOR_X2);

    // Receive data
    qspinor_receive_blob(data, size, QSPINOR_X2);
    qspinor_finish();
}

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
