.text
.globl	main

main:
    li      sp,     0xffc
	addi	sp,     sp,         -48
	sw	    s0,     44(sp)
	addi	s0,     sp,         48
	sw	    zero,   -20(s0)
	li	    a5,     1
	sw	    a5,     -24(s0)
	li	    a5,     10
	sw	    a5,     -32(s0)
	sw	    zero,   -28(s0)
	j	.L2
.L3:
	lw	    a4,     -20(s0)
	lw	    a5,     -24(s0)
	add	    a5,     a4,         a5
	sw	    a5,     -36(s0)
	lw	    a5,     -24(s0)
	sw	    a5,     -20(s0)
	lw	    a5,     -36(s0)
	sw	    a5,     -24(s0)
	lw	    a5,     -28(s0)
	addi	a5,     a5,         1
	sw	    a5,     -28(s0)
.L2:
	lw	    a4,     -28(s0)
	lw	    a5,     -32(s0)
	blt	    a4,     a5,         .L3
	li	    a5,     0
	mv	    a0,     a5
	lw	    s0,     44(sp)
	addi	sp,     sp,         48
	ebreak