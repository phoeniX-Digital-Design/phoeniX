riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32im -o hello_world.o hello_world.c
riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32im -o load.o load.s
riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32im -o syscalls.o syscalls.c

riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32im -Wl,--gc-sections -o firmware.elf hello_world.o load.o syscalls.o -T riscv.ld -lstdc++

riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32im -nostdlib -o start.elf start.S -T start.ld -lstdc++
chmod -x start.elf

riscv64-unknown-elf-objcopy -O verilog start.elf start.tmp
riscv64-unknown-elf-objcopy -O verilog firmware.elf firmware.tmp

cat start.tmp firmware.tmp > firmware.hex
python3 hex8tohex32.py firmware.hex > firmware32.hex
python3 phoeniX_firmware.py
rm -f start.tmp firmware.tmp

iverilog -o phoeniX.vvp phoeniX_Testbench.v phoeniX.v
chmod -x phoeniX.vvp
vvp -N phoeniX.vvp
gtkwave phoeniX.vcd