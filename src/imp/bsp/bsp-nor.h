#ifndef _BSP_NOR_H
#define _BSP_NOR_H

#include "sdk.h"

extern void nor_bus_read_init(void);
extern void nor_erase(size_t start, size_t size);
extern void nor_program(size_t start, size_t size, const uint8_t* const data);
extern void nor_read(size_t start, size_t size, uint8_t* const data);

#endif // _BSP_NOR_H
