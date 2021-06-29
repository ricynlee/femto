#ifndef _FEMTO_H
#define _FEMTO_H

// GPIO
typedef struct {
    volatile int io;
    volatile int dir;
} gpio_t;

#define GPIO        ((gpio_t*)0x40000000)
#define GPIO_BITS   (4u) // valid gpio bits
#define GPIO_MASK   ((1u<<GPIO_BITS)-1) // valid gpio bit mask

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
#define SHARED_QUEUE    1

#if defined(SHARED_QUEUE) && SHARED_QUEUE
typedef struct {
    volatile unsigned short         mode;    // RW
    volatile unsigned short         seq;     // WO
    volatile unsigned char          wrq;     // WO
    volatile const unsigned char    rdq;     // RO
    volatile const unsigned char    stat;    // RO
    volatile unsigned char          qclr;    // WO
} qspinor_t;
#else
#error QSPINOR separate seq queues: not implemented
#endif

#define QSPINOR ((qspinor_t*)0x31000000)

#define QSPINOR_MODE_QUAD_SHIFT     (0u)
#define QSPINOR_MODE_QUAD_MASK      (1u<<QSPINOR_MODE_QUAD_SHIFT)

#define QSPINOR_MODE_DUMMY_SHIFT    (4u)
#define QSPINOR_MODE_DUMMY_MASK     (0xfu<<QSPINOR_MODE_DUMMY_SHIFT)

#define QSPINOR_MODE_CMD_SHIFT      (8u)
#define QSPINOR_MODE_CMD_MASK       (0xffu<<QSPINOR_MODE_CMD_SHIFT)

#define QSPINOR_SEQ_READLEN_SHIFT   (0u)
#define QSPINOR_SEQ_READLEN_MASK    (0x1ffu<<QSPINOR_SEQ_READLEN_SHIFT)

#define QSPINOR_SEQ_READ_SHIFT      (15u)
#define QSPINOR_SEQ_READ_MASK       (1u<<QSPINOR_SEQ_READ_SHIFT)

#define QSPINOR_STAT_QFULL_SHIFT    (0u)
#define QSPINOR_STAT_QFULL_MASK     (1u<<QSPINOR_STAT_QFULL_SHIFT)

#define QSPINOR_STAT_QEMPTY_SHIFT   (1u)
#define QSPINOR_STAT_QEMPTY_MASK    (1u<<QSPINOR_STAT_QEMPTY_SHIFT)

#define QSPINOR_STAT_BUSY_SHIFT     (7u)
#define QSPINOR_STAT_BUSY_MASK      (1u<<QSPINOR_STAT_BUSY_SHIFT)

#define QSPINOR_QCLR_CLR_SHIFT      (0u)
#define QSPINOR_QCLR_CLR_MASK       (1u<<QSPINOR_QCLR_CLR_SHIFT)

#endif // _FEMTO_H
