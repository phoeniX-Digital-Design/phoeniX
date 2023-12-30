        addi    x12,    x0,    101
        add     x13,    x0,    x0 
        add     x14,    x0,     x0 
LOOP:   
        add     x14,    x13,    x14
        addi    x13,    x13,    1
        blt     x13,    x12,    LOOP
        sw      x14,    100(x0)
        ebreak