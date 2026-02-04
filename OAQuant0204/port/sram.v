// **************************************************************
// SRAM Black Box / Stub Model for Synthesis
// **************************************************************
// This module provides the interface for the SRAM macro but 
// contains no logic. It allows synthesis to pass without 
// needing the physical library or behavioral model of the SRAM.
// **************************************************************

module TS6N12FFCLLLVTB1024X64M4W (
    // OUTPUT
    output wire [63:0] Q,      // Read Data
    
    // INPUTS
    input  wire        CLK,    // Clock
    input  wire [9:0]  AA,     // Write Address (Calculated from waddr [9:0])
    input  wire [63:0] D,      // Write Data
    input  wire [63:0] BWEB,   // Bit Write Enable Bar (Active Low/Bitmask)
    input  wire        WEB,    // Write Enable Bar (Active Low)
    
    input  wire [1:0]  RTSEL,  // Read Timing Select
    input  wire [1:0]  WTSEL,  // Write Timing Select
    input  wire [1:0]  MTSEL,  // Memory Timing Select
    
    input  wire [9:0]  AB,     // Read Address (Calculated from raddr [9:0])
    input  wire        REB     // Read Enable Bar (Active Low)
);

    // 设置 Black Box 属性 (针对不同综合工具的可选操作)
    // Synopsys DC / FC:
    // // synopsys translate_off
    // initial $display("SRAM TS6N12FFCLLLVTB1024X64M4W is treated as Black Box");
    // // synopsys translate_on
    
    // Vivado attribute:
    // (* black_box *)

    // 为了防止综合工具因为输出悬空而报错，
    // 或者为了防止后续逻辑被优化掉，给输出赋一个常数 0。
    assign Q = 64'b0;

endmodule