riscv-none-embed-gcc -g -march=rv32ec -mabi=ilp32e -static --specs=nosys.specs -ffreestanding -nostartfiles -I..\..\sdk -Wl,-T..\..\linker\rom.ld -Wl,-Map=..\..\out-rom.map start.s init.c main.c ..\..\sdk\sdk.c ..\..\sdk\bsdk.c -o ..\..\out-rom.elf -Os -pedantic
riscv-none-embed-objdump -d ..\..\out-rom.elf -M no-aliases,numeric -S > ..\..\out-rom.s
riscv-none-embed-objcopy -O binary -S ..\..\out-rom.elf ..\..\out-rom.bin
python ..\..\tools\bin2hdl.py ..\..\out-rom.bin 32 > ..\..\rom.vh
move ..\..\rom.vh ..\..\..\rtl\imp\rom
