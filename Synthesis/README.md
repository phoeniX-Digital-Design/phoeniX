Synthesis
===========
<div align="justify">

The directory contains synthesis results of the phoeniX processor. The RTL synthesis of the phoeniX processor has been subjected to two distinct flows, leveraging diverse tools and technology nodes.

## TSMC 0.18um - Yosys

First synthesis process was obtained using the [Qflow tool](http://opencircuitdesign.com/qflow/) and [Magic VLSI](http://opencircuitdesign.com/magic/). The `/Qflow_TSMC_180nm` subdirectory includes log files, layout files, and images related to the process. The first synthesis was performed using the `osu018` process, which is also known as [TSMC 0.18 micron](https://www.tsmc.com/english/dedicatedFoundry/technology/logic/l_018micron) technology and `Yosys` open-source project. Processor was able to reach the maximum frequency of **125 MHz** using the 180nm technology.

</div>

Here is a picture of final layout result of the phoeniX core using Qflow in TSMC 180nm Technology:

![GDS](https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Synthesis/Qflow_TSMC_180nm/Pictures/GDS.png)

![MAG](https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Synthesis/Qflow_TSMC_180nm/Pictures/MAG.png)

<div align="justify">

## NanGate 45nm - Cadence

The main RTL synthesis of the phoeniX processor was done using Cadence Genus tool, using the `NanGate 45nm` technology, also known as the `FreePDK45, Open Cell Library` process technology. The Static Time Analysis (STA) results indicate that the maximum delay observed in the core modules, and consequently in the pipeline stages, is about **2600** nanoseconds using the **45nm** technology. Setting the clock cycle time at **3 nanoseconds** allows for sufficient margin to account for the maximum delay across the modules, ensuring that data propagates through the pipeline within the specified time frame. By adhering to this timing requirement, the processor can achieve a performance level of **333MHz**, enabling efficient execution of instructions and supporting the desired operational specifications in embedded processors.

This table provides a comparison of similar embedded processors to phoeniX, used in the industry, in terms of frequency, architecture, and manufacturing technology. This analysis helps to assess their performance and technical aspects, aiding decision-making for selecting the most suitable processor for various industrial applications. It is important to note that phoeniX is an embedded processor platform which is extensive, and execution units are replaceable; This means that these reported results of phoeniX core is extracted from the platform using its default (demo) execution engine.

| Processor             | Max Frequency (MHz) | Technology Node (nm) | Brand             | Architecture   |
| --------------------- | ------------------- | -------------------- | ----------------- | -------------- |
| phoeniX               | 333                 | 45                   | IUST ERC          | RV32IEM        |
| Cortex-M0             | 48                  | 90                   | ARM               | ARM Cortex-M0  |
| Cortex-M0+            | 48                  | 90                   | ARM               | ARM Cortex-M0+ |
| Cortex-M1             | 128                 | 180                  | ARM               | ARM Cortex-M1  |
| Cortex-M3             | 120                 | 90                   | ARM               | ARM Cortex-M3  |
| Cortex-M4             | 180                 | 90                   | ARM               | ARM Cortex-M4  |
| Cortex-M7             | 400                 | 40                   | ARM               | ARM Cortex-M7  |
| Cortex-M23            | 48                  | 55                   | ARM               | ARMv8-M        |
| Cortex-M33            | 100                 | 40                   | ARM               | ARMv8-M        |
| Cortex-A5             | 500                 | 40                   | ARM               | ARMv7-A        |
| Cortex-A7             | 1000                | 28                   | ARM               | ARMv7-A        |
| Cortex-A9             | 1500                | 28                   | ARM               | ARMv7-A        |
| FE310                 | 150                 | 180                  | Si-Five           | RV32IMAC       |
| ESP32                 | 240                 | 40                   | Espressif         | Xtensa LX6     |
| PIC32MX795F512L       | 80                  | 90                   | Microchip         | MIPS32 M4K     |
| RL78/G13              | 32                  | 90                   | Renesas           | RL78 (CISC)    |
| MSP430F5529           | 25                  | 180                  | Texas Instruments | MSP430         |


## FPGA Implementation

The core can be implemented as a softcore CPU on `Xilinx 7 Ultrascale/Ultrascale+` series FPGA boards using logic synthesis. This allows flexible integration of the core's functionality within the FPGA fabric. The **Xilinx 7 series FPGA boards** provide a versatile platform for hosting the softcore CPU implementation, offering configurable features and adaptability.

Additionally, within the repository, you will find a subdirectory called `/Vivado_Schematics` that contains schematic diagrams in PDF and PNG format. These diagrams were generated as a result of the synthesis and implementation process using **Xilinx Vivado 2022.2** software. The inclusion of these diagrams provides a visual representation of the synthesized and implemented design for every module and the phoeniX processor. This allows for a more comprehensive understanding of the phoeniX processor's architecture and functionality.

</div>