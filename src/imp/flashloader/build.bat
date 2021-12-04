riscv-none-embed-gcc -g -march=rv32ec -mabi=ilp32e -static --specs=nosys.specs -ffreestanding -nostartfiles -I..\..\sdk -Wl,-T..\..\linker\sram.ld -Wl,-Map=..\..\out-fld.map start.s main.c ..\..\sdk\sdk.c ..\..\sdk\bsdk.c -o ..\..\out-fld.elf -Os
riscv-none-embed-objdump -d ..\..\out-fld.elf -M no-aliases,numeric -S > ..\..\out-fld.s
riscv-none-embed-objcopy -O binary -S ..\..\out-fld.elf ..\..\out-fld.bin
python ..\..\tools\bin2hex.py ..\..\out-fld.bin 8 > ..\..\sram-init.hex
move ..\..\sram-init.hex ..\..\..\rtl\sim\
