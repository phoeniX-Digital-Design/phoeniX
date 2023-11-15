.section .text
.global factorial
.type factorial, @function

factorial:
    add     a4, a0, zero
    add     a2, a0, a1
    add     a3, a0, zero
    addi    x31, x0, -127
    csrrw   x0, 0x801, x1
loop:
    mul     a4, a3, a4
    addi    a3, a3, 1
    blt     a3, a2, loop
    add     a0, a4, zero
    csrrw   x0, 0x801, x0
    ret
