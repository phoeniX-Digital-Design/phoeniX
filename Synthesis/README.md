Synthesis
===========
<div align="justify">

The directory contains synthesis results and scripts of the phoeniX processor. The RTL synthesis of the phoeniX processor has been subjected to two distinct flows, leveraging diverse tools and technology nodes.

## TSMC 0.18um - Yosys

First synthesis process was obtained using the [Qflow tool](http://opencircuitdesign.com/qflow/) and [Magic VLSI](http://opencircuitdesign.com/magic/). The `/Qflow_TSMC_180nm` subdirectory includes log files, layout files, and images related to the process. The first synthesis was performed using the `osu018` process, which is also known as [TSMC 0.18 micron](https://www.tsmc.com/english/dedicatedFoundry/technology/logic/l_018micron) technology and `Yosys` open-source project. Processor was able to reach the maximum frequency of **200 - 250 MHz** using the 180nm technology in the 5 stage pipeline architecture which is V0.1 of the processor.

</div>

Here is a picture of final layout result of the phoeniX core using Qflow in 180nm Technology:

![phoeniX_GDS_Layout](https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Synthesis/Yosys_TSMC180/layout_pictures/GDS.png)

![phoeniX_MAG_Layout](https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Synthesis/Yosys_TSMC180/layout_pictures/MAG.png)

<div align="justify">

## 45nm CMOS - Design Compiler

The main RTL synthesis of the phoeniX processor was done using Synopsys Design Compiler tool, using the `NanGate OpenCell Library` and `FreePDK45` technology. By adhering to the timing requirements, the processor can achieve a performance level of **500 - 620MHz**, enabling efficient execution of instructions and supporting the desired operational specifications in embedded processors.

![phoeniX_45nm_Layout](https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Synthesis/DesignCompiler_NanGate45/layout_image/phoeniX_RV32IEM_layout_45nm.png)

</div>

> [!NOTE]\
> It is important to note that phoeniX is an embedded processor platform which is extensive, and execution units are reconfigurable; This means that any reported results of phoeniX core in different documenation may vary due to the integrated execution units. Results in the table below is extracted from the platform using its default (demo) execution engine. 

The `Synthesis/DesignCompiler_NanGate45` includes a `tcl` file (synthesis script) customized for the target processor.

```console
[user@USER ~]$ dc_shell-t -f compile_dc.tcl
[user@USER ~]$ encounter -init encounter.tcl
```

| Processor                    | Max Frequency (MHz) | Technology Node (nm) | Architecture | Pipeline         |
| ---------------------------- | ------------------- | -------------------- | ------------ | ---------------- |
| phoeniX V0.4                 | 620                 | 45                   | RV32IEM      | 3-stage in order |
| phoeniX V0.3                 | 620                 | 45                   | RV32IEM      | 3-stage in order |
| phoeniX V0.2                 | 500                 | 45                   | RV32I        | 3-stage in order |
| phoeniX V0.1                 | 200                 | 180                  | RV32I        | 5-stage in order |