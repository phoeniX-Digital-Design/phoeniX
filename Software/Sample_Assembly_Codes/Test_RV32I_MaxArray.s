main:
    #init stack pointer
	addi    sp,     zero,     512
    #create stack
	addi	sp,     sp,     -48
	
	addi	s0,     sp,     48

    #init arr[] to memory
    li	    a5,     10
    sw	    a5,     -48(s0)
    li	    a5,     324
    sw	    a5,     -44(s0)
    li	    a5,     45
    sw	    a5,     -40(s0)
    li	    a5,     90
    sw	    a5,     -36(s0)
    li	    a5,     216
    sw	    a5,     -32(s0)

    addi    s1,     s0,     0
    addi    s2,     s0,     20
    mv      t1,     zero

swap:
    mv      t0,     t1
load:
    lw      t1,     -48(s1)
    addi    s1,     s1,     4
    bgt     t1,     t0,     swap    # if t1 > t0 then swap
    blt     s1,     s2,     load    # if s0 <= s1 then load
    sw      t0,     -28(s0)
    