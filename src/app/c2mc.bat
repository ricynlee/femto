pushd xip-nor
cmd /c c2mc.bat
popd ..

python ..\tool\bin2arr.py ..\nor.bin 8 > ..\nor.h
riscv-none-embed-gcc -g -march=rv32e -mabi=ilp32e -static --specs=nosys.specs -ffreestanding -nostartfiles -I..\hdr -Wl,-Tsram.ld -Wl,-Map=..\out.map start.s main.c qspinor.c -o ..\out.elf
riscv-none-embed-objdump -S -d ..\out.elf -M no-aliases,numeric > ..\out.s
REM riscv-none-embed-objdump -S -d ..\out.elf > ..\out.s
riscv-none-embed-objcopy -O binary -S ..\out.elf ..\out.bin
copy ..\out.bin ..\app.bin
python ..\tool\bin2hex.py ..\out.bin 8 > ..\sram-init.hex
copy /Y ..\sram-init.hex ..\..\rtl\sim\
