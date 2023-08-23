riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32im -o hello.o hello.c
riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32im -o mother.o mother.c
riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32im -o fucker.o fucker.c
riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32im -o syscalls.o syscalls.c

riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32im -Wl,--gc-sections -o firmware.elf hello.o mother.o fucker.o syscalls.o -T riscv.ld -lstdc++

riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32im -nostdlib -o start.elf start.S -T start.ld -lstdc++
chmod -x start.elf

riscv64-unknown-elf-objcopy -O verilog start.elf start.tmp
riscv64-unknown-elf-objcopy -O verilog firmware.elf firmware.tmp

cat start.tmp firmware.tmp > firmware.hex
python3 hex8tohex32.py firmware.hex > firmware32.hex
python3 phoeniX_firmware.py
rm -f start.tmp firmware.tmp