OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  rom (rx) : ORIGIN = 0x00000000, LENGTH = 4K
  tcm (wx) : ORIGIN = 0x10000000, LENGTH = 4K
}

$rom_begin = 0;
$tcm_begin = 0x10000000;
$stack_size = 512;
$heap_size = 512;

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

  PROVIDE(__data_lma_begin = .);
  /* Initializers of .data */
  _rom_size = __data_lma_begin + SIZEOF(.data) - $rom_begin;

  PROVIDE(__data_vma_begin = $tcm_begin);
  .data (__data_vma_begin): AT(__data_lma_begin)
  {
    *(.data* .sdata*)
      . = ALIGN(4);
  } > tcm /* AT > rom */
  PROVIDE(__data_size = . - __data_vma_begin);
  PROVIDE(__global_pointer = __data_vma_begin + 0x800);

  PROVIDE(__bss_begin = .);
  .bss (NOLOAD):
  {
    *(.bss* .sbss*)
    . = ALIGN(4);
  } > tcm
  PROVIDE(__bss_size = . - __bss_begin);

  .stack (NOLOAD):
  {
    . = $stack_size;
    . = ALIGN(128);
  } > tcm
  PROVIDE(__stack_pointer = .);
}
