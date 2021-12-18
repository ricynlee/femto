OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  rom (rx) : ORIGIN = 0x00000000, LENGTH = 4K
}

$rom_begin = 0;

SECTIONS
{
  . = $rom_begin;
  .text :
  {
    *(.text*)
    . = ALIGN(4);
  } > rom /* AT > rom */

  .ro :
  {
    *(.rodata* .srodata* .eh_frame .rela*) /* WTF eh_frame rela */
    . = ALIGN(4);
  } > rom /* AT > rom */
}
