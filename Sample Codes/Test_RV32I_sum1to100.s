        add x10, x0, x0
        add x14, x10, x0 
        addi x12, x10, 10
        add x13, x10, x0 
LOOP :  add x14, x13, x14
        addi x13, x13, 1
        blt x13, x12, LOOP
        add x10, x14, x0 
        sw x0, 100(x10)
        lw x17, 100(x0)