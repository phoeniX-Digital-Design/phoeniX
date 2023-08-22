.global _boot

.text
_boot:
    jal x0,FindMax

    FindMax:
        lw   x8, 1000(x0)           # maxElement = mem[1000]
        add  x9, x0, x0             # i

        Loop:
            addi x9, x9, 4          # i += 4
            slti x6, x9, 40         # check if 10 elements are traversed (40 = 4 * 10)
            beq  x6, x0, EndLoop    # if 10 elements are traversed, jump to EndLoop
            lw   x18, 1000(x9)      # element = mem[i]
            slt  x6, x8, x18        # check if element is greater than maxElement
            beq  x6, x0, Loop       # if element is not greater than maxElement, jump to Loop
            add  x8, x18, x0        # maxElement = element
            jal  x0,Loop               # jump to Loop

        EndLoop:
            sw x8, 2000(x0)         # mem[2000] = maxElement
            jal x0,End                 # return

    End: