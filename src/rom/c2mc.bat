riscv-none-embed-gcc -g -march=rv32ec -mabi=ilp32e -static --specs=nosys.specs -ffreestanding -nostartfiles -I..\hdr -Wl,-Trom.ld -Wl,-Map=..\out.map start.s init.c main.c -o ..\out.elf
riscv-none-embed-objdump -S -d ..\out.elf -M no-aliases,numeric > ..\out.s
REM riscv-none-embed-objdump -S -d ..\out.elf > ..\out.s
riscv-none-embed-objcopy -O binary -S ..\out.elf ..\out.bin
python ..\tool\bin2hdl.py ..\out.bin 32 > ..\rom.vh
move ..\rom.vh ..\..\rtl\
