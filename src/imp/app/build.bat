riscv-none-embed-gcc -march=rv32ec -mabi=ilp32e -static --specs=nosys.specs -ffreestanding -nostartfiles -I..\..\sdk -Wl,-T..\..\linker\qspinor.ld -Wl,-Map=..\..\out.map start.s main.c -o ..\..\out.elf
riscv-none-embed-objdump -d ..\..\out.elf -M no-aliases,numeric > ..\..\out.s
REM riscv-none-embed-objdump -d ..\..\out.elf > ..\..\out.s
riscv-none-embed-objcopy -O binary -S ..\..\out.elf ..\..\out.bin
copy ..\..\out.bin ..\..\nor.bin
python ..\..\tools\bin2hex.py ..\..\out.bin 8 > ..\..\nor-init.hex
move ..\..\nor-init.hex ..\..\..\rtl\sim
