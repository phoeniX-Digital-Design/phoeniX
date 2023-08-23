riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32im -o a.o a.c
riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32im -o b.o b.c
riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32im -o syscalls.o syscalls.c

riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32im -Wl,--gc-sections -o firmware.elf a.o b.o syscalls.o -T riscv.ld -lstdc++
