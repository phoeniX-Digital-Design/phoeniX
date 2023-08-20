add x10, x0, x0

add x14, x10, x0 
addi x12, x10, 1010
add x13, x10, x0 

add x14, x13, x14
addi x13, x13, 1
blt x13, x12, 1111111111000
add x10, x14, r0 
   
sw x0, x10, 100
lw x17, x0, 100