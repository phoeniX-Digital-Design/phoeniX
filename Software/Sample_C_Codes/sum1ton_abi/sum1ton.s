.section .text
.global sum1ton
.type sum1ton, @function

sum1ton:
        add 	a4, a0, zero        // Initialize sum register a4 with 0x0
        add 	a2, a0, a1          // store count of 10 in register a2. Register a1 is sum1toned with 0xa (decimal 10) from main program
        add	    a3, a0, zero        // initialize intermediate sum register a3 by 0

loop:	
        add 	a4, a3, a4          // Incremental addition
        addi 	a3, a3, 1           // Increment intermediate register by 1	
        blt 	a3, a2, loop        // If a3 is less than a2, branch to label named <loop>
        add	    a0, a4, zero        // Store final result to register a0 so that it can be read by main program
        ret