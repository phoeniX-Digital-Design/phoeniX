        add x1, x0, x0
        add x7, x0, x0
LOOP:   addi x2, x0, 1
        addi x3, x0, 2
        addi x0, x0, 0
        addi x0, x0, 0
        add  x4, x2, x3
        lw   x5, 0(x4) 
        beq x2, x3, LOOP 
        