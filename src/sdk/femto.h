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

// QSPI
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
    } femto_qspi_t;

    #define QSPI ((femto_qspi_t*)0x40000000)

    #define QSPI_IPCSR_SEL_SHIFT        (0u)
    #define QSPI_IPCSR_SEL_MASK         (MASK_WIDTH(1u)<<QSPI_IPCSR_SEL_SHIFT)

    #define QSPI_IPCSR_BSY_SHIFT        (1u)
    #define QSPI_IPCSR_BSY_MASK         (MASK_WIDTH(1u)<<QSPI_IPCSR_BSY_SHIFT)

    #define QSPI_IPCSR_DIR_SHIFT        (4u)
    #define QSPI_IPCSR_DIR_MASK         (MASK_WIDTH(1u)<<QSPI_IPCSR_DIR_SHIFT)
    #define QSPI_IPCSR_DIR(v)           (((v) << QSPI_IPCSR_DIR_SHIFT) & QSPI_IPCSR_DIR_MASK)

    #define QSPI_IPCSR_DMY_SHIFT        (5u)
    #define QSPI_IPCSR_DMY_MASK         (MASK_WIDTH(1u)<<QSPI_IPCSR_DMY_SHIFT)

    #define QSPI_IPCSR_WID_SHIFT        (6u)
    #define QSPI_IPCSR_WID_MASK         (MASK_WIDTH(2u)<<QSPI_IPCSR_WID_SHIFT)
    #define QSPI_IPCSR_WID(v)           (((v) << QSPI_IPCSR_WID_SHIFT) & QSPI_IPCSR_WID_MASK)

    #define QSPI_IPCSR_CNT_SHIFT        (8u)
    #define QSPI_IPCSR_CNT_MASK         (MASK_WIDTH(4u)<<QSPI_IPCSR_CNT_SHIFT)
    #define QSPI_IPCSR_CNT(v)           (((v) << QSPI_IPCSR_CNT_SHIFT) & QSPI_IPCSR_CNT_MASK)

    #define QSPI_IPCSR_DOP_SHIFT        (12u) // dummy out pattern
    #define QSPI_IPCSR_DOP_MASK         (MASK_WIDTH(4u)<<QSPI_IPCSR_DOP_SHIFT)
    #define QSPI_IPCSR_DOP(v)           (((v) << QSPI_IPCSR_DOP_SHIFT) & QSPI_IPCSR_DOP_MASK)

    #define QSPI_TXQCSR_CNT_SHIFT       (0u)
    #define QSPI_TXQCSR_CNT_MASK        (MASK_WIDTH(5u)<<QSPI_TXQCSR_CNT_SHIFT)
    #define QSPI_TXQCSR_CNT(v)          (((v) & QSPI_TXQCSR_CNT_MASK) >> QSPI_TXQCSR_CNT_SHIFT)

    #define QSPI_TXQCSR_CLR_SHIFT       (7u)
    #define QSPI_TXQCSR_CLR_MASK        (MASK_WIDTH(1u)<<QSPI_TXQCSR_CLR_SHIFT)

    #define QSPI_RXQCSR_CNT_SHIFT       (0u)
    #define QSPI_RXQCSR_CNT_MASK        (MASK_WIDTH(5u)<<QSPI_RXQCSR_CNT_SHIFT)
    #define QSPI_RXQCSR_CNT(v)          (((v) & QSPI_RXQCSR_CNT_MASK) >> QSPI_RXQCSR_CNT_SHIFT)

    #define QSPI_RXQCSR_CLR_SHIFT       (7u)
    #define QSPI_RXQCSR_CLR_MASK        (MASK_WIDTH(1u)<<QSPI_RXQCSR_CLR_SHIFT)

    #define QSPI_NORCSR_MODE_SHIFT      (0u)
    #define QSPI_NORCSR_MODE_MASK       (MASK_WIDTH(3u)<<QSPI_NORCSR_MODE_SHIFT)
    #define QSPI_NORCSR_MODE(v)         (((v) << QSPI_NORCSR_MODE_SHIFT) & QSPI_NORCSR_MODE_MASK)

    #define QSPI_NORCSR_DMYDIR_SHIFT    (3u)
    #define QSPI_NORCSR_DMYDIR_MASK     (MASK_WIDTH(1u)<<QSPI_NORCSR_DMYDIR_SHIFT)

    #define QSPI_NORCSR_DMYCNT_SHIFT    (4u)
    #define QSPI_NORCSR_DMYCNT_MASK     (MASK_WIDTH(4u)<<QSPI_NORCSR_DMYCNT_SHIFT)
    #define QSPI_NORCSR_DMYCNT(v)       (((v) << QSPI_NORCSR_DMYCNT_SHIFT) & QSPI_NORCSR_DMYCNT_MASK)

    #define QSPI_NORCSR_DMYPAT_SHIFT    (8u)
    #define QSPI_NORCSR_DMYPAT_MASK     (MASK_WIDTH(4u)<<QSPI_NORCSR_DMYPAT_SHIFT)
    #define QSPI_NORCSR_DMYPAT(v)       (((v) << QSPI_NORCSR_DMYPAT_SHIFT) & QSPI_NORCSR_DMYPAT_MASK)

    enum femto_qspi_width {
        QSPI_X1,
        QSPI_X2,
        QSPI_X4,
    };

    enum femto_qspi_norcsr_mode_t {
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

    #define QSPI_FIFO_DEPTH  (16u)

// EIC
    typedef struct {
        volatile unsigned   ipfr; // interrupt pending flag register
    } femto_eic_t;

    #define EIC ((femto_eic_t*)0x80000000)

    #define EIC_IPFR_TMRF       (1u<<0)
    #define EIC_IPFR_UARTF      (1u<<1)

// UART
    typedef struct {
        volatile unsigned char       txd;
        const volatile unsigned char rxd;
        volatile unsigned char       txqcsr;
        volatile unsigned char       rxqcsr;
    } femto_uart_t;

    #define UART    ((femto_uart_t*)0x90000000)

    #define UART_TXQCSR_RDY_SHIFT   (0u)
    #define UART_TXQCSR_RDY_MASK    (MASK_WIDTH(1u)<<UART_TXQCSR_RDY_SHIFT)

    #define UART_TXQCSR_INTEN_SHIFT (7u)
    #define UART_TXQCSR_INTEN_MASK  (MASK_WIDTH(1u)<<UART_TXQCSR_INTEN_SHIFT)

    #define UART_RXQCSR_RDY_SHIFT   (0u)
    #define UART_RXQCSR_RDY_MASK    (MASK_WIDTH(1u)<<UART_RXQCSR_RDY_SHIFT)

    #define UART_RXQCSR_CLR_SHIFT   (1u)
    #define UART_RXQCSR_CLR_MASK    (MASK_WIDTH(1u)<<UART_RXQCSR_CLR_SHIFT)

    #define UART_RXQCSR_INTEN_SHIFT (7u)
    #define UART_RXQCSR_INTEN_MASK  (MASK_WIDTH(1u)<<UART_RXQCSR_INTEN_SHIFT)

// GPIO
    typedef struct {
        volatile unsigned io;
        volatile unsigned dir;
    } femto_gpio_t;

    #define GPIO        ((femto_gpio_t*)0xa0000000)
    #define GPIO_BITS   (4u) // valid gpio bits
    #define GPIO_MASK   MASK_WIDTH(GPIO_BITS) // valid gpio bit mask

// TIMER
    typedef struct {
        volatile unsigned   tr;
        volatile unsigned   intcsr;
    } femto_timer_t;

    #define TIMER_INTCSR_INTEN_SHIFT    (7u)
    #define TIMER_INTCSR_INTEN_MASK     (MASK_WIDTH(1u)<<TIMER_INTCSR_INTEN_SHIFT)

    #define TIMER ((femto_timer_t*)0xb0000000)

// RESET
    typedef struct {
        volatile unsigned short       rst;
        const volatile unsigned short cause;
        volatile unsigned             info; // hardfault addr, or sw-defined message
    } femto_reset_t;

    #define RESET ((femto_reset_t*)0xf0000000)

    enum femto_reset_cause {
        RST_CAUSE_POR ,
        RST_CAUSE_HW  ,
        RST_CAUSE_SW  ,
        RST_FAULT_CORE,
        RST_FAULT_IBUS,
        RST_FAULT_DBUS,
        RST_FAULT_IPER,
        RST_FAULT_DPER,
    };

#endif // _FEMTO_H
