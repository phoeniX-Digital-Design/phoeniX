riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32im -o factorial_abi.o factorial_abi.c 
riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32im -o factorial.o factorial.s

riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32im -o Firmware/syscalls.o Firmware/syscalls.c
riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32im -Wl,--gc-sections -o firmware.elf factorial.o factorial_abi.o Firmware/syscalls.o -T Firmware/riscv.ld -lstdc++
chmod -x firmware.elf
riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32im -nostdlib -o start.elf Firmware/start.s -T Firmware/start.ld -lstdc++
chmod -x start.elf
riscv64-unknown-elf-objcopy -O verilog start.elf start.tmp
riscv64-unknown-elf-objcopy -O verilog firmware.elf firmware.tmp
cat start.tmp firmware.tmp > firmware.mem

python3 Firmware/hex_converter.py firmware.mem > factorial_abi_firmware.hex

rm -rf Firmware/*.o
rm -rf *.tmp *.mem *.o *.elf