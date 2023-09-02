riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32i -o Hello_World.o Hello_World.c
riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32i -o syscalls.o syscalls.c

riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32i -Wl,--gc-sections -o firmware.elf Hello_World.o syscalls.o -T riscv.ld -lstdc++

riscv64-unknown-elf-gcc -mabi=ilp32 -march=rv32i -nostdlib -o start.elf start.S -T start.ld -lstdc++
chmod -x start.elf

riscv64-unknown-elf-objcopy -O verilog start.elf start.tmp
riscv64-unknown-elf-objcopy -O verilog firmware.elf firmware.tmp

cat start.tmp firmware.tmp > firmware.hex
python3 hex8tohex32.py firmware.hex > firmware32.hex
rm -f start.tmp firmware.tmp

cp ./PHOENIX-CORE/phoeniX_Code_Executant/Linux_GCC/firmware32.hex ./PHOENIX-CORE

#iverilog -o phoeniX.vvp phoeniX_Testbench.v
#chmod -x phoeniX.vvp
#vvp -N phoeniX.vvp
#gtkwave phoeniX.vcd