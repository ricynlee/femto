#include <stdbool.h>
#include "femto.h"
#include "qspinor.h"

// Definitions
#if defined(NOR_N25Q032)
#define SIZE_BULK   (0x00400000u)
#elif defined(NOR_W25Q128)
#define SIZE_BULK   (0x01000000u)
#else
#error NOR model not supported
#endif

#define SIZE_SECTOR  (0x00001000u)
#define SIZE_PAGE    (0x00000100u)

// Globals
qspinor_t* const qspinor = QSPINOR;

// APIs
#if defined(NOR_N25Q032)
void restore_spi() { // N25Q only
    qspinor->mode =
          ((0<<QSPINOR_MODE_QUAD_SHIFT) & QSPINOR_MODE_QUAD_MASK)
        | ((0<<QSPINOR_MODE_DUMMY_SHIFT) & QSPINOR_MODE_DUMMY_MASK)
        | ((0x03<<QSPINOR_MODE_CMD_SHIFT) & QSPINOR_MODE_CMD_MASK);
    qspinor->qclr = QSPINOR_QCLR_CLR_MASK;
    qspinor->wrq = 0xff;
    qspinor->seq =
          ((0<<QSPINOR_SEQ_READ_SHIFT) & QSPINOR_SEQ_READ_MASK)
        | ((0<<QSPINOR_SEQ_READLEN_SHIFT) & QSPINOR_SEQ_READLEN_MASK);
    while (qspinor->stat & QSPINOR_STAT_BUSY_MASK);
}
#endif

static void write_enable() {
    qspinor->qclr = QSPINOR_QCLR_CLR_MASK;
    qspinor->wrq = 0x06;
    qspinor->seq =
          ((0<<QSPINOR_SEQ_READ_SHIFT) & QSPINOR_SEQ_READ_MASK)
        | ((0<<QSPINOR_SEQ_READLEN_SHIFT) & QSPINOR_SEQ_READLEN_MASK);
    while (qspinor->stat & QSPINOR_STAT_BUSY_MASK);
}

#if defined(NOR_N25Q032)
void quad_enable() { // N25Q only
    write_enable();
    // qspinor->qclr = QSPINOR_QCLR_CLR_MASK;
    qspinor->wrq = 0x61;
    qspinor->wrq = 0x5f;
    qspinor->seq =
          ((0<<QSPINOR_SEQ_READ_SHIFT) & QSPINOR_SEQ_READ_MASK)
        | ((0<<QSPINOR_SEQ_READLEN_SHIFT) & QSPINOR_SEQ_READLEN_MASK);
    while (qspinor->stat & QSPINOR_STAT_BUSY_MASK);
    qspinor->mode =
          ((1<<QSPINOR_MODE_QUAD_SHIFT) & QSPINOR_MODE_QUAD_MASK)
        | ((10<<QSPINOR_MODE_DUMMY_SHIFT) & QSPINOR_MODE_DUMMY_MASK)
        | ((0xeb<<QSPINOR_MODE_CMD_SHIFT) & QSPINOR_MODE_CMD_MASK);
}
#endif

void erase_bulk() {
    write_enable();
    // qspinor->qclr = QSPINOR_QCLR_CLR_MASK;
    qspinor->wrq = 0xc7;
    qspinor->seq =
          ((0<<QSPINOR_SEQ_READ_SHIFT) & QSPINOR_SEQ_READ_MASK)
        | ((0<<QSPINOR_SEQ_READLEN_SHIFT) & QSPINOR_SEQ_READLEN_MASK);
    while (qspinor->stat & QSPINOR_STAT_BUSY_MASK);

    do {
        qspinor->wrq = 0x05;
        qspinor->seq =
              ((1<<QSPINOR_SEQ_READ_SHIFT) & QSPINOR_SEQ_READ_MASK)
            | ((1<<QSPINOR_SEQ_READLEN_SHIFT) & QSPINOR_SEQ_READLEN_MASK);
        while (qspinor->stat & QSPINOR_STAT_BUSY_MASK);
    } while (qspinor->rdq & 0x1);
}

static bool erase_sector_4KB(unsigned phy_addr) {
    if ((phy_addr & 0xfff) || (phy_addr>=(4<<20)))
        return false;

    const char* const phy_addr_buf = (char*)&phy_addr;
    write_enable();
    // qspinor->qclr = QSPINOR_QCLR_CLR_MASK;
    qspinor->wrq = 0x20;
    for (int i=0; i<3; i++) {
        qspinor->wrq = phy_addr_buf[2-i];
    }
    qspinor->seq =
          ((0<<QSPINOR_SEQ_READ_SHIFT) & QSPINOR_SEQ_READ_MASK)
        | ((0<<QSPINOR_SEQ_READLEN_SHIFT) & QSPINOR_SEQ_READLEN_MASK);
    while (qspinor->stat & QSPINOR_STAT_BUSY_MASK);

    do {
        qspinor->wrq = 0x05;
        qspinor->seq =
              ((1<<QSPINOR_SEQ_READ_SHIFT) & QSPINOR_SEQ_READ_MASK)
            | ((1<<QSPINOR_SEQ_READLEN_SHIFT) & QSPINOR_SEQ_READLEN_MASK);
        while (qspinor->stat & QSPINOR_STAT_BUSY_MASK);
    } while (qspinor->rdq & 0x1);

    return true;
}

static bool program_page_256B(unsigned phy_addr, const char* data, unsigned len) {
    if ((!data) || (len>256) || (phy_addr>=(4<<20)) || (phy_addr/256 != (phy_addr+len)/256))
        return false;

    const char* const phy_addr_buf = (char*)&phy_addr;
    write_enable();
    // qspinor->qclr = QSPINOR_QCLR_CLR_MASK;
    qspinor->wrq = 0x02;
    for (int i=0; i<3; i++) {
        qspinor->wrq = phy_addr_buf[2-i];
    }
    for (int i=0; i<len; i++) {
        qspinor->wrq = data[i];
    }
    qspinor->seq =
          ((0<<QSPINOR_SEQ_READ_SHIFT) & QSPINOR_SEQ_READ_MASK)
        | ((0<<QSPINOR_SEQ_READLEN_SHIFT) & QSPINOR_SEQ_READLEN_MASK);
    while (qspinor->stat & QSPINOR_STAT_BUSY_MASK);

    do {
        qspinor->wrq = 0x05;
        qspinor->seq =
              ((1<<QSPINOR_SEQ_READ_SHIFT) & QSPINOR_SEQ_READ_MASK)
            | ((1<<QSPINOR_SEQ_READLEN_SHIFT) & QSPINOR_SEQ_READLEN_MASK);
        while (qspinor->stat & QSPINOR_STAT_BUSY_MASK);
    } while (qspinor->rdq & 0x1);

    return true;
}

bool erase(unsigned addr, unsigned size) {
    size = (size + (addr & (SIZE_SECTOR-1)) + SIZE_SECTOR-1) & ~(SIZE_SECTOR-1);
    addr &= ~(SIZE_SECTOR-1);

    if ((addr<QSPINOR_DATA) || (addr+size>=QSPINOR_DATA+SIZE_BULK)){
        return false;
    }

    if (0==size) {
        return true;
    }

    bool status = true;

    while (size && status) {
        status &= erase_sector_4KB(addr-QSPINOR_DATA);
        size -= SIZE_SECTOR;
        addr += SIZE_SECTOR;
    }

    return status;
}

bool program(unsigned dst, const char* src, unsigned len){
    if (dst<QSPINOR_DATA || dst+len>=QSPINOR_DATA+SIZE_BULK) {
        return false;
    }

    if (!src) {
        return false;
    }

    if (0==len) {
        return true;
    }

    unsigned first_program_len_aligned = ((dst + SIZE_PAGE-1) & ~(SIZE_PAGE-1)) - dst;
    unsigned program_len = len<first_program_len_aligned ? len : first_program_len_aligned;
    bool status = program_page_256B(dst-QSPINOR_DATA, src, program_len);

    if (!status) {
        return status;
    }

    while (len>program_len && status) {
        len -= program_len;
        dst += program_len;
        src += program_len;

        program_len = SIZE_PAGE<len ? SIZE_PAGE : len;

        status &= program_page_256B(dst-QSPINOR_DATA, src, program_len);
    }

    return status;
}
