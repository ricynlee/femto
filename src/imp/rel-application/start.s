.section .text
.global _start

_start:
  .cfi_startproc
  .cfi_undefined ra
  .option push
  .option norelax
  la gp, __global_pointer
  .option pop
  la sp, __stack_pointer
  call init_bss
  call init_data
  j main
  .cfi_endproc
  .end
