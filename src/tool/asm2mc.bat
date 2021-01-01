@echo off
riscv-none-embed-as -march=rv32e %1 -o a.o
riscv-none-embed-objdump -M no-aliases,numeric -d a.o
del a.o
