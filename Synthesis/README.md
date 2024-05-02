Synthesis
===========
<div align="justify">

The directory contains synthesis results of the phoeniX processor. The RTL synthesis of the phoeniX processor has been subjected to two distinct flows, leveraging diverse tools and technology nodes.

## TSMC 0.18um - Yosys

First synthesis process was obtained using the [Qflow tool](http://opencircuitdesign.com/qflow/) and [Magic VLSI](http://opencircuitdesign.com/magic/). The `/Qflow_TSMC_180nm` subdirectory includes log files, layout files, and images related to the process. The first synthesis was performed using the `osu018` process, which is also known as [TSMC 0.18 micron](https://www.tsmc.com/english/dedicatedFoundry/technology/logic/l_018micron) technology and `Yosys` open-source project. Processor was able to reach the maximum frequency of **200 - 250 MHz** using the 180nm technology in the 5 stage pipeline architecture.

</div>

Here is a picture of final layout result of the phoeniX core using Qflow in 180nm Technology:

![phoeniX_GDS_Layout](https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Synthesis/TSMC_018um/Pictures/GDS.png)

![phoeniX_MAG_Layout](https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Synthesis/TSMC_018um/Pictures/MAG.png)

<div align="justify">

## NanGate 45nm - Design Compiler

The main RTL synthesis of the phoeniX processor was done using Synopsys Design Compiler tool, using the `NanGate 45nm` technology. By adhering to the timing requirements, the processor can achieve a performance level of **500 - 620MHz**, enabling efficient execution of instructions and supporting the desired operational specifications in embedded processors.

It is important to note that phoeniX is an embedded processor platform which is extensive, and execution units are reconfigurable; This means that these reported results of phoeniX core is extracted from the platform using its default (demo) execution engine.

| Processor                    | Max Frequency (MHz) | Technology Node (nm) | Architecture | Pipeline         |
| ---------------------------- | ------------------- | -------------------- | ------------ | ---------------- |
| phoeniX V0.3                 | 620                 | 45                   | RV32IEM      | 3-stage in order |
| phoeniX V0.2                 | 500                 | 45                   | RV32IEM      | 5-stage in order |
| phoeniX V0.1                 | 200                 | 180                  | RV32I        | 5-stage in order |

## FPGA Implementation

The core can be implemented as a softcore CPU on `Xilinx` series FPGA boards using logic synthesis. This allows flexible integration of the core's functionality within the FPGA fabric. The **Xilinx 7 series FPGA boards** provide a versatile platform for hosting the softcore CPU implementation, offering configurable features and adaptability.

| Processor                    | Max Frequency (MHz) | Technology Node (nm) | Architecture          |
| ---------------------------- | ------------------- | -------------------- | --------------------- |
| phoeniXS6                    | 100                 | Xilinx SPARTAN6      | 3-stage in order RV32I|
| phoeniXS7                    | 100 - 350           | Xilinx ZYNQ 7020     | 3-stage in order RV32I|

</div>