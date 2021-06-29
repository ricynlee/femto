OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  sram (w) : ORIGIN = 0x20000000, LENGTH = 512K
  nor (rx) : ORIGIN = 0x30000000, LENGTH = 4M
}

$stack_size = 512;
$sram_begin = 0x20040000;
$nor_begin = 0x30300000;

SECTIONS
{
  . = $sram_begin;
  .stack (.) (NOLOAD):
  {
    . = $stack_size;
    . = ALIGN(128);
  } > sram
  PROVIDE(__stack_pointer = .);
  PROVIDE(__global_pointer = $sram_begin + 0x800);

  . = $nor_begin;
  .text (.):
  {
    *(.text*)
    . = ALIGN(4);
  } > nor

  .ro (.):
  {
    *(.rodata* .srodata* .eh_frame .rela*) /* WTF eh_frame rela */
    . = ALIGN(4);
  } > nor
}
