    /* --------------------------------------------------------------
    |    THE FOLLOWING MODULE IS ONLY THE BASE OF HAZARD DETECTION  |
    |    AND FORWARDING UNIT. THIS MODULE IS NOT COMPLETED YET      |
    |    AND IT WILL BE UPDATED SOON                                |
    -------------------------------------------------------------- */

module Hazard_Forward_Unit 
(
    input  [5:0] rs1,           // Register source 1
    input  [5:0] rs2,           // Register source 2
    input  [5:0] id_ex_rd,      // Destination register in the ID/EX pipeline stage
    input  [5:0] if_id_rs1,     // Register source 1 in the IF/ID pipeline stage
    input  [5:0] if_id_rs2,     // Register source 2 in the IF/ID pipeline stage

    input  mem_read,            // Memory Read signal from the Control Unit
    input  mem_write,           // Memory Write signal from the Control Unit

    output hazard,              // Hazard detection signal

    output forward_exe_mux1,    // Forward data from execution satge - mux 1
    output forward_exe_mux2,    // Forward data from execution satge - mux 2
    output forward_mem_mux1,    // Forward data from memory satge - mux 1
    output forward_mem_mux2     // Forward data from memory satge - mux 2
);

    wire data_hazard;       // Data hazard signal
    wire control_hazard;    // Data hazard signal

    // Detect Data Hazard
    assign data_hazard = ((rs1 == id_ex_rd) || (rs2 == id_ex_rd));

    // Detect Control Hazard
    assign control_hazard = mem_read || mem_write;

    // Hazard Detection Signal
    assign hazard = data_hazard || control_hazard;

endmodule