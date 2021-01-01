riscv-none-embed-gcc -march=rv32e -mabi=ilp32e -static --specs=nosys.specs -ffreestanding -nostartfiles -I..\..\hdr -Wl,-Tqspinor.ld -Wl,-Map=..\..\out.map start.s main.c -o ..\..\out.elf
riscv-none-embed-objdump -d ..\..\out.elf -M no-aliases,numeric > ..\..\out.s
REM riscv-none-embed-objdump -d ..\..\out.elf > ..\..\out.s
riscv-none-embed-objcopy -O binary -S ..\..\out.elf ..\..\out.bin
copy ..\..\out.bin ..\..\nor.bin
python ..\..\tool\bin2hdl.py ..\..\out.bin 8 > ..\..\qspinor.vh
move ..\..\qspinor.vh ..\..\..\rtl\sim
