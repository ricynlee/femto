OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)



MEMORY
{
  tcm (wx) : ORIGIN = 0x10000000, LENGTH = 4K
}

$tcm_begin = 0x10000000;
$stack_size = 512;
$heap_size = 512;

SECTIONS
{
  . = $tcm_begin;
  .text :
  {
    *(.text*)
    . = ALIGN(4);
  } > tcm

  .ro :
  {
    *(.rodata* .srodata* .eh_frame .rela*) /* WTF eh_frame rela */
    . = ALIGN(4);
  } > tcm

  PROVIDE(__data_vma_begin = .);
  .data :
  {
    *(.data* .sdata*)
      . = ALIGN(4);
  } > tcm
  PROVIDE(__global_pointer = __data_vma_begin + 0x800);

  PROVIDE(__bss_begin = .);
  .bss (NOLOAD):
  {
    *(.bss* .sbss*)
    . = ALIGN(4);
  } > tcm
  PROVIDE(__bss_size = . - __bss_begin);

  /* heap should be here */

  .stack (ORIGIN(tcm)+LENGTH(tcm)-$stack_size) (NOLOAD) :
  {
    . = $stack_size;
    . = ALIGN(128);
  } > tcm
  PROVIDE(__stack_pointer = .);
}
