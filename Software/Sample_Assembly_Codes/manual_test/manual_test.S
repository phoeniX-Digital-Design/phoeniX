li sp, 0xffc
addi sp, sp, -48
li x15, 0xDEAD
sw x15, 0(sp)
nop
nop
nop
nop
lw x16, 0(sp)
addi x17, x16, 1
ebreak