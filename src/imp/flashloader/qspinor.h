#ifndef QSPINOR_H
#define QSPINOR_H

#include <stdbool.h>

#define NOR_W25Q128

// xSPI NOR
#define QSPINOR_DATA (0x30000000u)

// API declarations
#if defined(NOR_N25Q032)
void restore_spi();
void quad_enable();
#endif

void erase_bulk();
bool erase(unsigned addr, unsigned size);
bool program(unsigned dst, const char* src, unsigned len);

#endif
