Synthesis
===========
<div align="justify">

The directory contains synthesis results of the phoeniX processor, which were obtained using the [Qflow tool](http://opencircuitdesign.com/qflow/) and [Magic VLSI](http://opencircuitdesign.com/magic/). The `/Qflow_TSMC_180nm` subdirectory includes log files, layout files, and images related to the process. The synthesis was performed using the `osu018` process, which is also known as [TSMC 0.18 micron](https://www.tsmc.com/english/dedicatedFoundry/technology/logic/l_018micron) technology.

Additionally, within the repository, you will find a subdirectory called `/Vivado_Schematics` that contains schematic diagrams in PDF and PNG format. These diagrams were generated as a result of the synthesis and implementation process using Xilinx Vivado 2022.2 software. The inclusion of these diagrams provides a visual representation of the synthesized and implemented design for every module and the phoeniX processor. This allows for a more comprehensive understanding of the phoeniX processor's architecture and functionality.
</div>

Here is a picture of final layout result of the phoeniX core using Qflow:

![GDS](https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Synthesis/Qflow_TSMC_180nm/Pictures/GDS.png)

![MAG](https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Synthesis/Qflow_TSMC_180nm/Pictures/MAG.png)

<div align="justify">

The Static Time Analysis (STA) results indicate that the maximum delay observed in the core modules, and consequently in the pipeline stages, is approximately 4 nanoseconds. Setting the **clock cycle time at 4 nanoseconds** allows for sufficient margin to account for the maximum delay across the modules, ensuring that data propagates through the pipeline within the specified time frame. 
By adhering to this timing requirement, the processor can achieve a performance level of approximately **250 MHz**, enabling efficient execution of instructions and supporting the desired operational specifications.

</div>