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
  call main
  .cfi_endproc
  .end
