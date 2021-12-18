#ifndef _FEMTO_H
#define _FEMTO_H

    #define MASK_WIDTH(n) (((1u << ((n)-1))<<1u)-1u) /* 1<=n<=32 */

    enum femto_io_dir {
        DIR_IN,
        DIR_OUT,
    };

    typedef _Bool bool;
    #define false (0)
    #define true  (1)

// Mem
    #define ROM     0x00000000u
    #define TCM     0x10000000u

// GPIO
    typedef struct {
        volatile unsigned io;
        volatile unsigned dir;
    } femto_gpio_t;

    #define GPIO        ((femto_gpio_t*)0x40000000)
    #define GPIO_BITS   (4u) // valid gpio bits
    #define GPIO_MASK   MASK_WIDTH(GPIO_BITS) // valid gpio bit mask

// UART
    typedef struct {
        volatile unsigned char       txd;
        const volatile unsigned char rxd;
        const volatile unsigned char txqsr;
        volatile unsigned char       rxqcsr;
    } femto_uart_t;

    #define UART    ((femto_uart_t*)0x50000000)

    #define UART_TXQSR_RDY_SHIFT    (0u)
    #define UART_TXQSR_RDY_MASK     (MASK_WIDTH(1u)<<UART_TXQSR_RDY_SHIFT)

    #define UART_RXQCSR_RDY_SHIFT   (0u)
    #define UART_RXQCSR_RDY_MASK    (MASK_WIDTH(1u)<<UART_RXQCSR_RDY_SHIFT)

    #define UART_RXQCSR_CLR_SHIFT   (1u)
    #define UART_RXQCSR_CLR_MASK    (MASK_WIDTH(1u)<<UART_RXQCSR_CLR_SHIFT)

// TIMER
    typedef struct {
        volatile unsigned   tr;
    } femto_timer_t;

    #define TIMER ((femto_timer_t*)0x70000000)

// ADA - audio data acquisition
    typedef struct {
        const volatile int  ssr;
    } femto_audacq_t;

    #define ADA ((femto_audacq_t*)0x80000000)

    #define ADA_SAMPLE_SHIFT    (0u)
    #define ADA_SAMPLE_WIDTH    (24u)
    #define ADA_SAMPLE_MASK     (MASK_WIDTH(ADA_SAMPLE_WIDTH)<<ADA_SAMPLE_SHIFT)

    #define ADA_STATUS_SHIFT    (24u)
    #define ADA_STATUS_WIDTH    (8u)
    #define ADA_STATUS_MASK     ((MASK_WIDTH(ADA_STATUS_WIDTH)<<ADA_STATUS_SHIFT))
#endif // _FEMTO_H
