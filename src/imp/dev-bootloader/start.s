.section .text
.global _start

_start:
  .cfi_startproc
  .cfi_undefined ra
  j main
  .cfi_endproc
  .end
