OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  rom (rx) : ORIGIN = 0x00000000, LENGTH = 4K
  tcm (wx) : ORIGIN = (0x10000000+15*0x400+512), LENGTH = 512
}

$rom_begin = 0;
$tcm_begin = (0x10000000+15*0x400+512);
$stack_size = 512;

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

  .stack (NOLOAD):
  {
    . = $stack_size;
    . = ALIGN(128);
  } > tcm
  PROVIDE(__stack_pointer = .);
}
