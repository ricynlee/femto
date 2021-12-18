riscv-none-embed-gcc -g -march=rv32ec -mabi=ilp32e -static --specs=nosys.specs -ffreestanding -nostartfiles -I..\..\sdk -ffunction-sections -fdata-sections -Wl,-gc-sections -Wl,-Tdev-application.ld -Wl,-Map=..\dev-application.map start.s main.c ..\..\sdk\sdk.c ..\..\sdk\bsdk.c -o ..\dev-application.elf -Os -pedantic
riscv-none-embed-objdump -d ..\dev-application.elf -M no-aliases,numeric -S > ..\dev-application.s
riscv-none-embed-objcopy -O binary -S ..\dev-application.elf ..\dev-application.bin
python ..\..\tools\bin2hex.py ..\dev-application.bin 8 > ..\dev-application.hex
copy ..\dev-application.hex ..\..\..\rtl\sim\sram-init.hex
