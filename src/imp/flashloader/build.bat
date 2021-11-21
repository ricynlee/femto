REM pushd xip-nor
REM cmd /c build.bat
REM popd ..

REM python ..\..\tools\bin2arr.py ..\..\nor.bin 8 > ..\..\nor.h

riscv-none-embed-gcc -g -march=rv32ec -mabi=ilp32e -static --specs=nosys.specs -ffreestanding -nostartfiles -I..\..\sdk -Wl,-T..\..\linker\sram.ld -Wl,-Map=..\..\out.map start.s main.c ..\..\sdk\sdk.c ..\..\sdk\bsdk.c -o ..\..\out.elf
riscv-none-embed-objdump -d ..\..\out.elf -M no-aliases,numeric -S > ..\..\out.s
REM riscv-none-embed-objdump -d ..\..\out.elf > ..\..\out.s
riscv-none-embed-objcopy -O binary -S ..\..\out.elf ..\..\out.bin
copy ..\..\out.bin ..\..\app.bin
python ..\..\tools\bin2hex.py ..\..\out.bin 8 > ..\..\sram-init.hex
copy /Y ..\..\sram-init.hex ..\..\..\rtl\sim\
