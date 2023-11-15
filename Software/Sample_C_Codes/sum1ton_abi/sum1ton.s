.section .text
.global sum1ton
.type sum1ton, @function

sum1ton:
        add 	a4, a0, zero        
        add 	a2, a0, a1          
        add	a3, a0, zero        
        addi    x31, x0, -127
loop:	
        csrrw   x0, 0x800, x31
        add 	a4, a3, a4    
        csrrw   x0, 0x800, x0      
        addi 	a3, a3, 1           
        blt 	a3, a2, loop        
        add	a0, a4, zero        
        ret
        