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
    #define SRAM    0x20000000u
    #define NOR     0x30000000u

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

// QSPI NOR
    typedef struct {
        volatile unsigned short          ipcsr;
        union {
            volatile unsigned char       txd;
            const volatile unsigned char rxd;
        };
        volatile unsigned char           txqcsr;
        volatile unsigned char           rxqcsr;
        volatile unsigned char           norcmd;
        volatile unsigned short          norcsr;
    } femto_qspinor_t;

    #define QSPINOR ((femto_qspinor_t*)0x60000000)

    #define QSPINOR_IPCSR_SEL_SHIFT     (0u)
    #define QSPINOR_IPCSR_SEL_MASK      (MASK_WIDTH(1u)<<QSPINOR_IPCSR_SEL_SHIFT)

    #define QSPINOR_IPCSR_BSY_SHIFT     (1u)
    #define QSPINOR_IPCSR_BSY_MASK      (MASK_WIDTH(1u)<<QSPINOR_IPCSR_BSY_SHIFT)

    #define QSPINOR_IPCSR_DIR_SHIFT     (4u)
    #define QSPINOR_IPCSR_DIR_MASK      (MASK_WIDTH(1u)<<QSPINOR_IPCSR_DIR_SHIFT)
    #define QSPINOR_IPCSR_DIR(v)        (((v) << QSPINOR_IPCSR_DIR_SHIFT) & QSPINOR_IPCSR_DIR_MASK)

    #define QSPINOR_IPCSR_DMY_SHIFT     (5u)
    #define QSPINOR_IPCSR_DMY_MASK      (MASK_WIDTH(1u)<<QSPINOR_IPCSR_DMY_SHIFT)

    #define QSPINOR_IPCSR_WID_SHIFT     (6u)
    #define QSPINOR_IPCSR_WID_MASK      (MASK_WIDTH(2u)<<QSPINOR_IPCSR_WID_SHIFT)
    #define QSPINOR_IPCSR_WID(v)        (((v) << QSPINOR_IPCSR_WID_SHIFT) & QSPINOR_IPCSR_WID_MASK)

    #define QSPINOR_IPCSR_CNT_SHIFT     (8u)
    #define QSPINOR_IPCSR_CNT_MASK      (MASK_WIDTH(4u)<<QSPINOR_IPCSR_CNT_SHIFT)
    #define QSPINOR_IPCSR_CNT(v)        (((v) << QSPINOR_IPCSR_CNT_SHIFT) & QSPINOR_IPCSR_CNT_MASK)

    #define QSPINOR_IPCSR_DOP_SHIFT     (12u) // dummy out pattern
    #define QSPINOR_IPCSR_DOP_MASK      (MASK_WIDTH(4u)<<QSPINOR_IPCSR_DOP_SHIFT)

    #define QSPINOR_TXQCSR_CNT_SHIFT    (0u)
    #define QSPINOR_TXQCSR_CNT_MASK     (MASK_WIDTH(5u)<<QSPINOR_TXQCSR_CNT_SHIFT)
    #define QSPINOR_TXQCSR_CNT(v)       (((v) & QSPINOR_TXQCSR_CNT_MASK) >> QSPINOR_TXQCSR_CNT_SHIFT)

    #define QSPINOR_TXQCSR_CLR_SHIFT    (7u)
    #define QSPINOR_TXQCSR_CLR_MASK     (MASK_WIDTH(1u)<<QSPINOR_TXQCSR_CLR_SHIFT)

    #define QSPINOR_RXQCSR_CNT_SHIFT    (0u)
    #define QSPINOR_RXQCSR_CNT_MASK     (MASK_WIDTH(5u)<<QSPINOR_RXQCSR_CNT_SHIFT)
    #define QSPINOR_RXQCSR_CNT(v)       (((v) & QSPINOR_RXQCSR_CNT_MASK) >> QSPINOR_RXQCSR_CNT_SHIFT)

    #define QSPINOR_RXQCSR_CLR_SHIFT    (7u)
    #define QSPINOR_RXQCSR_CLR_MASK     (MASK_WIDTH(1u)<<QSPINOR_RXQCSR_CLR_SHIFT)

    #define QSPINOR_NORCSR_MODE_SHIFT   (0u)
    #define QSPINOR_NORCSR_MODE_MASK    (MASK_WIDTH(3u)<<QSPINOR_NORCSR_MODE_SHIFT)
    #define QSPINOR_NORCSR_MODE(v)      (((v) << QSPINOR_NORCSR_MODE_SHIFT) & QSPINOR_NORCSR_MODE_MASK)

    #define QSPINOR_NORCSR_DMYDIR_SHIFT (3u)
    #define QSPINOR_NORCSR_DMYDIR_MASK  (MASK_WIDTH(1u)<<QSPINOR_NORCSR_DMYDIR_SHIFT)

    #define QSPINOR_NORCSR_DMYCNT_SHIFT (4u)
    #define QSPINOR_NORCSR_DMYCNT_MASK  (MASK_WIDTH(4u)<<QSPINOR_NORCSR_DMYCNT_SHIFT)
    #define QSPINOR_NORCSR_DMYCNT(v)    (((v) << QSPINOR_NORCSR_DMYCNT_SHIFT) & QSPINOR_NORCSR_DMYCNT_MASK)

    #define QSPINOR_NORCSR_DMYPAT_SHIFT (8u)
    #define QSPINOR_NORCSR_DMYPAT_MASK  (MASK_WIDTH(4u)<<QSPINOR_NORCSR_DMYPAT_SHIFT)
    #define QSPINOR_NORCSR_DMYPAT(v)    (((v) << QSPINOR_NORCSR_DMYPAT_SHIFT) & QSPINOR_NORCSR_DMYPAT_MASK)

    enum femto_nor_mode {
        NOR_MODE_111,
        NOR_MODE_112,
        NOR_MODE_114,
        NOR_MODE_122,
        NOR_MODE_144,
        NOR_MODE_222,
        NOR_MODE_444,
        NOR_MODE_LLIM = NOR_MODE_111,
        NOR_MODE_ULIM = NOR_MODE_444,
    };

    enum femto_qspinor_width {
        QSPINOR_X1,
        QSPINOR_X2,
        QSPINOR_X4,
    };

    #define QSPINOR_FIFO_DEPTH  (16u)

// TIMER
    typedef struct {
        volatile unsigned   tr;
    } femto_timer_t;

    #define TIMER ((femto_timer_t*)0x70000000)

// RESET
    typedef struct {
        volatile unsigned char  rst;
    } femto_reset_t;

    #define RESET ((femto_reset_t*)0xf0000000)

    enum femto_reset_target {
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
