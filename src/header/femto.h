#ifndef _FEMTO_H
#define _FEMTO_H

    #define MASK_WIDTH(n) (((1u << ((n)-1))<<1u)-1u) /* 1<=n<=32 */

// GPIO
    typedef struct {
        volatile unsigned io;
        volatile unsigned dir;
    } gpio_t;

    #define GPIO        ((gpio_t*)0x40000000)
    #define GPIO_BITS   (4u) // valid gpio bits
    #define GPIO_MASK   MASK_WIDTH(GPIO_BITS) // valid gpio bit mask

// UART
    typedef struct {
        volatile unsigned char       txd;
        const volatile unsigned char rxd;
        const volatile unsigned char txq_full:1;
                       unsigned char :7;
        const volatile unsigned char rxq_empty;
                       unsigned char :7;
    } uart_t;

    #define UART    ((uart_t*)0x50000000)

// QSPI NOR
    typedef struct {
        volatile unsigned short      req;
        volatile unsigned char       txd;
        const volatile unsigned char rxd;
        volatile unsigned char       txqcsr;
        volatile unsigned char       rxqcsr;
        volatile unsigned short      norcsr;
    } qspinor_t;

    #define QSPINOR ((qspinor_t*)0x60000000)

    #define QSPINOR_REQ_SEL_SHIFT       (0u)
    #define QSPINOR_REQ_SEL_MASK        (MASK_WIDTH(1u)<<QSPINOR_REQ_SEL_SHIFT)

    #define QSPINOR_REQ_DIR_SHIFT       (2u)
    #define QSPINOR_REQ_DIR_MASK        (MASK_WIDTH(1u)<<QSPINOR_REQ_DIR_SHIFT)

    #define QSPINOR_REQ_DMY_SHIFT       (3u)
    #define QSPINOR_REQ_DMY_MASK        (MASK_WIDTH(1u)<<QSPINOR_REQ_DMY_SHIFT)

    #define QSPINOR_REQ_WID_SHIFT       (4u)
    #define QSPINOR_REQ_WID_MASK        (MASK_WIDTH(2u)<<QSPINOR_REQ_WID_SHIFT)

    #define QSPINOR_REQ_CNT_SHIFT       (4u)
    #define QSPINOR_REQ_CNT_MASK        (MASK_WIDTH(4u)<<QSPINOR_REQ_CNT_SHIFT)

    #define QSPINOR_REQ_DOP_SHIFT       (4u) // dummy out pattern
    #define QSPINOR_REQ_DOP_MASK        (MASK_WIDTH(4u)<<QSPINOR_REQ_DOP_SHIFT)

    #define QSPINOR_TXQCSR_RDY_SHIFT    (0u)
    #define QSPINOR_TXQCSR_RDY_MASK     (MASK_WIDTH(1u)<<QSPINOR_TXQCSR_RDY_SHIFT)

    #define QSPINOR_TXQCSR_CLR_SHIFT    (1u)
    #define QSPINOR_TXQCSR_CLR_MASK     (MASK_WIDTH(1u)<<QSPINOR_TXQCSR_CLR_SHIFT)

    #define QSPINOR_RXQCSR_RDY_SHIFT    (0u)
    #define QSPINOR_RXQCSR_RDY_MASK     (MASK_WIDTH(1u)<<QSPINOR_RXQCSR_RDY_SHIFT)

    #define QSPINOR_RXQCSR_CLR_SHIFT    (1u)
    #define QSPINOR_RXQCSR_CLR_MASK     (MASK_WIDTH(1u)<<QSPINOR_RXQCSR_CLR_SHIFT)

    #define QSPINOR_NORCSR_MODE_SHIFT   (0u)
    #define QSPINOR_NORCSR_MODE_MASK    (MASK_WIDTH(3u)<<QSPINOR_NORCSR_MODE_SHIFT)

    #define QSPINOR_NORCSR_DMYDIR_SHIFT (0u)
    #define QSPINOR_NORCSR_DMYDIR_MASK  (MASK_WIDTH(3u)<<QSPINOR_NORCSR_DMYDIR_SHIFT)

    #define QSPINOR_NORCSR_DMYCNT_SHIFT (0u)
    #define QSPINOR_NORCSR_DMYCNT_MASK  (MASK_WIDTH(3u)<<QSPINOR_NORCSR_DMYCNT_SHIFT)

    #define QSPINOR_NORCSR_CMD_SHIFT    (0u)
    #define QSPINOR_NORCSR_CMD_MASK     (MASK_WIDTH(3u)<<QSPINOR_NORCSR_CMD_SHIFT)

// TIMER
    typedef struct {
        volatile unsigned   tr;
    } timer_t;

    #define TIMER ((timer_t*)0x70000000)

// RESET
    typedef struct {
        volatile unsigned char  rst;
    } reset_t;

    #define RESET ((reset_t*)0xf0000000)

    enum {
        RESET_ALL    ,
        RESET_CORE   ,
        RESET_ROM    ,
        RESET_TCM    ,
        RESET_SRAM   ,
        RESET_NOR    ,
        RESET_GPIO   ,
        RESET_UART   ,
        RESET_QSPINOR,
        RESET_TIMER  ,
    };

#endif // _FEMTO_H
