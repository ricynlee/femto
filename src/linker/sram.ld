OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  sram (wx) : ORIGIN = 0x20000000, LENGTH = 512K
}

$sram_begin = 0x20000000;
$stack_size = 512;
$heap_size = 512;

SECTIONS
{
  . = $sram_begin;
  .text :
  {
    *(.text*)
    . = ALIGN(4);
  } > sram

  .ro :
  {
    *(.rodata* .srodata* .eh_frame .rela*) /* WTF eh_frame rela */
    . = ALIGN(4);
  } > sram

  __data_vma_begin = .;
  .data :
  {
    *(.data* .sdata*)
      . = ALIGN(4);
  } > sram
  PROVIDE(__global_pointer = __data_vma_begin + 0x800);
  _app_size = . - $sram_begin;
  
  .bss (NOLOAD):
  {
    *(.bss* .sbss*)
    . = ALIGN(4);
  } > sram

  .stack (NOLOAD):
  {
    . = $stack_size;
    . = ALIGN(128);
  } > sram
  PROVIDE(__stack_pointer = .);
  
  PROVIDE(end = .); /* for malloc, etc. */
  .heap (NOLOAD):
  {
    . = $heap_size;
    . = ALIGN(4);
  } > sram
}
