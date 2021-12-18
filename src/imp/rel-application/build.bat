:: riscv-none-embed-gcc -g -march=rv32ec -mabi=ilp32e -static --specs=nosys.specs -ffreestanding -nostartfiles -I..\..\sdk -ffunction-sections -fdata-sections -Wl,-gc-sections -Wl,-Trel-application.ld -Wl,-Map=..\rel-application.map start.s init.c main.c ..\..\sdk\sdk.c ..\..\sdk\bsdk.c -o ..\rel-application.elf -Os -pedantic
riscv-none-embed-gcc -g -march=rv32ec -mabi=ilp32e -static --specs=nosys.specs -ffreestanding -nostartfiles -I..\..\sdk -Wl,-Trel-application.ld -Wl,-Map=..\rel-application.map start.s init.c main.c ..\..\sdk\sdk.c ..\..\sdk\bsdk.c -o ..\rel-application.elf -pedantic
riscv-none-embed-objdump -d ..\rel-application.elf -M no-aliases,numeric -S > ..\rel-application.s
riscv-none-embed-objcopy -O binary -S ..\rel-application.elf ..\rel-application.bin
python ..\..\tools\bin2hdl.py ..\rel-application.bin 32 > ..\rel-application.vh
copy ..\rel-application.vh ..\..\..\rtl\imp\rom.vh
