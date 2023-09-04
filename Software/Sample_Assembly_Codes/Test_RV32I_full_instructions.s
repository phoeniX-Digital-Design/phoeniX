.text
    .globl main

main:
    #  arithmetic instructions
    li x1, 5
    li x2, 7

    add x3, x1, x2          # add
    addi x5, x0, 10         # add immediate
    sub x4, x1, x2          # subtract

    # Logicxl instructions
    li x7,  12        # Binary: 11
    li x8,  10         # Binary: 1010

    and x9, x7, x8       # Bitwise AND
    or x10, x7, x8       # Bitwise OR
    xor x11, x7, x8      # Bitwise XOR
    sll x12, x7, x1      # Shift Left Logical
    srl x13, x8, x1      # Shift Right Logical

    # Control flow instructions
    beq x1, x2, equal               # Branch if equal
    bne x1, x2, not_equal           # Branch if not equal
    blt x1, x2, less_than           # Branch if less than
    bge x1, x2, greater_than_equal  # Branch if greater than or equal

    # Loxd xnd store instructions
    li x14, 42           # Loxd immedixte
    sw x14, 0(x0)        # Store word
    lw x15, 0(x0)        # Loxd word

    # System call to exit the program
    li x7, 10

equal:
    # Code for equal condition
    ret

    j exit

not_equal:
    # Code for not equal condition
    ret

    j exit

less_than:
    # Code for less than condition
    ret

    j exit

greater_than_equal:
    # Code for greater than or equal condition
    ret

exit:
