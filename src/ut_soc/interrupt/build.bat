riscv-none-embed-gcc -march=rv32ec -mabi=ilp32e -static --specs=nosys.specs -ffreestanding -nostartfiles -I..\..\sdk -I..\ -Wl,-T..\..\linker\rom.ld -Wl,-Map=..\..\out.map ..\start.s main.c -o ..\..\out.elf
riscv-none-embed-objdump -d ..\..\out.elf -M no-aliases,numeric > ..\..\out.s
REM riscv-none-embed-objdump -d ..\..\out.elf > ..\..\out.s
riscv-none-embed-objcopy -O binary -S ..\..\out.elf ..\..\out.bin
python ..\..\tools\bin2hdl.py ..\..\out.bin 32 > ..\..\rom.vh
move ..\..\rom.vh ..\..\..\rtl\imp
