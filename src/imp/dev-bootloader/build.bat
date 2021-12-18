riscv-none-embed-gcc -g -march=rv32ec -mabi=ilp32e -static --specs=nosys.specs -ffreestanding -nostartfiles -I..\..\sdk -ffunction-sections -fdata-sections -Wl,-gc-sections -Wl,-Tdev-bootloader.ld -Wl,-Map=..\dev-bootloader.map start.s main.c ..\..\sdk\sdk.c ..\..\sdk\bsdk.c -o ..\dev-bootloader.elf -Os -pedantic
riscv-none-embed-objdump -d ..\dev-bootloader.elf -M no-aliases,numeric -S > ..\dev-bootloader.s
riscv-none-embed-objcopy -O binary -S ..\dev-bootloader.elf ..\dev-bootloader.bin
python ..\..\tools\bin2hdl.py ..\dev-bootloader.bin 32 > ..\dev-bootloader.vh
copy ..\dev-bootloader.vh ..\..\..\rtl\imp\rom.vh
