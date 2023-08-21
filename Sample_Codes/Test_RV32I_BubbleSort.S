main:
	addi    sp,     sp,     -4
    #create stack
	addi	sp,     sp,     -48
	
    #save s0
	sw	    s0,     44(sp)
	
    #update s0
	addi	s0,     sp,     48

	#init arr[] to memory
	li	    a5,     3
	sw	    a5,     -48(s0)
	li	    a5,     5
	sw	    a5,     -44(s0)
	li	    a5,     1
	sw	    a5,     -40(s0)
	li	    a5,     2
	sw	    a5,     -36(s0)
	li	    a5,     4
	sw	    a5,     -32(s0)

	#init i to memory
	sw	    zero,   -20(s0)
	j	    .L2
.L6:
	#init j to memory
	sw	    zero,   -24(s0)
	j	    .L3
.L5:
	#load arr[ j ] to a4
	lw	    a5,     -24(s0)
	slli	a5,     a5,     2
	addi	a4,     s0,     -16
	add	    a5,     a4,     a5
	lw	    a4,     -32(a5)

	#load arr[j+1] a5
	lw	    a5,     -24(s0)
	addi	a5,     a5,     1
	slli	a5,     a5,     2
	addi	a3,     s0,     -16
	add	    a5,     a3,     a5
	lw	    a5,     -32(a5)
	
    # if arr[j + 1] > arr[j] 
	bge	    a5,     a4,     .L4

    # arr[j+1] < arr[j]

	#load arr[j] a5
	lw	    a5,     -24(s0)
	slli	a5,     a5,     2
	addi	a4,     s0,     -16
	add	    a5,     a4,     a5
	lw	    a5,     -32(a5)

	#store arr[j] to tmp
	sw	    a5,     -28(s0)

	#load arr[j+1] to a4
	lw	    a5,     -24(s0)
	addi	a5,     a5,     1
	slli	a5,     a5,     2
	addi	a4,     s0,     -16
	add	    a5,     a4,     a5
	lw	    a4,     -32(a5)

	#arr[j] = arr[j+1]
	lw	    a5,     -24(s0)
	slli	a5,     a5,     2
	addi	a3,     s0,     -16
	add	    a5,     a3,     a5
	sw	    a4,     -32(a5)

	#store tmp to arr[j+1]
	lw	    a5,     -24(s0)
	addi	a5,     a5,     1
	slli	a5,     a5,     2
	addi	a4,     s0,     -16
	add	    a5,     a4,a5
	lw	    a4,     -28(s0)
	sw	    a4,     -32(a5)
.L4:
	#j++
	lw	    a5,     -24(s0)
	addi	a5,     a5,     1
	sw	    a5,     -24(s0)
.L3:
	#check (j - i) < 4
	li	    a4,     4
	lw	    a5,     -20(s0)
	sub	    a5,     a4,     a5
	lw	    a4,     -24(s0)
	blt	    a4,     a5,     .L5

	#i++
	lw	    a5,     -20(s0)
	addi	a5,     a5,     1
	sw	    a5,     -20(s0)
.L2:
	#check i < 4
	lw	    a4,     -20(s0)
	li	    a5,     3
	bge	    a5,     a4,     .L6

	#return
	li	    a5,     0
	mv	    a0,     a5
	lw	    s0,     44(sp)
	addi    sp,     sp,     48
	jr	    ra