.section .text
.global _start

_start:
  .cfi_startproc
  .cfi_undefined ra
  la sp, __stack_pointer
  j main
  .cfi_endproc
  .end
