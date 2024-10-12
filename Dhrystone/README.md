Dhrystone Benchmark
==========================

<div align="justify">

Dhrystone is a general-performance benchmark test originally developed by Reinhold Weicker in 1984. This benchmark is used to measure and compare the performance of different computers or, in this case, the efficiency of the code generated for the same computer by different compilers. The test reports general performance in Dhrystone per second.

Like most benchmark programs, Dhrystone consists of standard code and concentrates on string handling. It uses no floating-point operations. It is heavily influenced by hardware and software design, compiler and linker options, code optimizing, cache memory, wait states, and integer data types.

To execute dhrystone benchmark program on phoeniX, enter the following command in the terminal, in the root directory:
```shell
make dhrystone
```
Make sure to set the `MARCH` parameter in the Makefile correctly. Currently available options are: `rv32i`, `rv32e`, `rv32im` and `rv32em`.

Dhrystone Result on phoeniX (RV32I):
```
Number_Of_Runs: 100
User_Time: 32846 cycles, 29341 insn
Cycles_Per_Instruction: 1.119
Dhrystones_Per_Second_Per_MHz: 3044
DMIPS_Per_MHz: 1.732
```

Dhrystone Result on phoeniX (RV32IM):
```
Number_Of_Runs: 100
User_Time: 31248 cycles, 26442 insn
Cycles_Per_Instruction: 1.181
Dhrystones_Per_Second_Per_MHz: 3200
DMIPS_Per_MHz: 1.821
```

</div>