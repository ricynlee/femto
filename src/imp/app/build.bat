riscv-none-embed-gcc -g -march=rv32ec -mabi=ilp32e -static --specs=nosys.specs -ffreestanding -nostartfiles -I..\..\sdk -Wl,-T..\..\linker\qspinor.ld -Wl,-Map=..\..\out-app.map start.s main.c ..\..\sdk\sdk.c ..\..\sdk\bsdk.c -o ..\..\out-app.elf -O3
riscv-none-embed-objdump -d ..\..\out-app.elf -M no-aliases,numeric -S > ..\..\out-app.s
riscv-none-embed-objcopy -O binary -S ..\..\out-app.elf ..\..\out-app.bin
python ..\..\tools\bin2hex.py ..\..\out-app.bin 8 > ..\..\nor-init.hex
move ..\..\nor-init.hex ..\..\..\rtl\sim
