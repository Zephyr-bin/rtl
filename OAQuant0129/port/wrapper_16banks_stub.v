// ============================================================
// File: wrapper_16banks_stub.v
// Description: Black-box stub for synthesis. 
//              Replaces the behavioral SRAM wrapper to prevent 
//              logic pruning while excluding SRAM internals.
// ============================================================

module wrapper_16banks(
    input         clk,
    input         rst_n,

    // --- INPUTS ---
    input         bce0_i , bce1_i , bce2_i , bce3_i ,
    input         bce4_i , bce5_i , bce6_i , bce7_i ,
    input         bce8_i , bce9_i , bce10_i, bce11_i,
    input         bce12_i, bce13_i, bce14_i, bce15_i,
    
    input [2:0]   bwmod0_i , bwmod1_i , bwmod2_i , bwmod3_i ,
    input [2:0]   bwmod4_i , bwmod5_i , bwmod6_i , bwmod7_i ,
    input [2:0]   bwmod8_i , bwmod9_i , bwmod10_i, bwmod11_i,
    input [2:0]   bwmod12_i, bwmod13_i, bwmod14_i, bwmod15_i,
    
    input [1:0]   bwren0_i , bwren1_i , bwren2_i , bwren3_i ,
    input [1:0]   bwren4_i , bwren5_i , bwren6_i , bwren7_i ,
    input [1:0]   bwren8_i , bwren9_i , bwren10_i, bwren11_i,
    input [1:0]   bwren12_i, bwren13_i, bwren14_i, bwren15_i,
    
    input [14:0]  bwaddr0_i , bwaddr1_i , bwaddr2_i , bwaddr3_i ,
    input [14:0]  bwaddr4_i , bwaddr5_i , bwaddr6_i , bwaddr7_i ,
    input [14:0]  bwaddr8_i , bwaddr9_i , bwaddr10_i, bwaddr11_i,
    input [14:0]  bwaddr12_i, bwaddr13_i, bwaddr14_i, bwaddr15_i,
    
    input [255:0] bwdata0_i , bwdata1_i , bwdata2_i , bwdata3_i ,
    input [255:0] bwdata4_i , bwdata5_i , bwdata6_i , bwdata7_i ,
    input [255:0] bwdata8_i , bwdata9_i , bwdata10_i, bwdata11_i,
    input [255:0] bwdata12_i, bwdata13_i, bwdata14_i, bwdata15_i,
    
    input [2:0]   brmod0_i , brmod1_i , brmod2_i , brmod3_i ,
    input [2:0]   brmod4_i , brmod5_i , brmod6_i , brmod7_i ,
    input [2:0]   brmod8_i , brmod9_i , brmod10_i, brmod11_i,
    input [2:0]   brmod12_i, brmod13_i, brmod14_i, brmod15_i,
    
    input [14:0]  braddr0_i , braddr1_i , braddr2_i , braddr3_i ,
    input [14:0]  braddr4_i , braddr5_i , braddr6_i , braddr7_i ,
    input [14:0]  braddr8_i , braddr9_i , braddr10_i, braddr11_i,
    input [14:0]  braddr12_i, braddr13_i, braddr14_i, braddr15_i,

    // --- OUTPUTS ---
    output wire [255:0] brdata0_o , brdata1_o , brdata2_o , brdata3_o ,
    output wire [255:0] brdata4_o , brdata5_o , brdata6_o , brdata7_o ,
    output wire [255:0] brdata8_o , brdata9_o , brdata10_o, brdata11_o,
    output wire [255:0] brdata12_o, brdata13_o, brdata14_o, brdata15_o,
    
    output wire         brvalid0_o , brvalid1_o , brvalid2_o , brvalid3_o ,
    output wire         brvalid4_o , brvalid5_o , brvalid6_o , brvalid7_o ,
    output wire         brvalid8_o , brvalid9_o , brvalid10_o, brvalid11_o,
    output wire         brvalid12_o, brvalid13_o, brvalid14_o, brvalid15_o
);

    // ******************************
    // OUTPUT ASSIGNMENTS (STUB)
    // ******************************
    // Drive all outputs to 0 to avoid floating inputs in the top module
    // and prevent synthesis tools from pruning logic connected to inputs.

    assign brdata0_o  = 256'd0; assign brvalid0_o  = 1'b0;
    assign brdata1_o  = 256'd0; assign brvalid1_o  = 1'b0;
    assign brdata2_o  = 256'd0; assign brvalid2_o  = 1'b0;
    assign brdata3_o  = 256'd0; assign brvalid3_o  = 1'b0;
    assign brdata4_o  = 256'd0; assign brvalid4_o  = 1'b0;
    assign brdata5_o  = 256'd0; assign brvalid5_o  = 1'b0;
    assign brdata6_o  = 256'd0; assign brvalid6_o  = 1'b0;
    assign brdata7_o  = 256'd0; assign brvalid7_o  = 1'b0;
    assign brdata8_o  = 256'd0; assign brvalid8_o  = 1'b0;
    assign brdata9_o  = 256'd0; assign brvalid9_o  = 1'b0;
    assign brdata10_o = 256'd0; assign brvalid10_o = 1'b0;
    assign brdata11_o = 256'd0; assign brvalid11_o = 1'b0;
    assign brdata12_o = 256'd0; assign brvalid12_o = 1'b0;
    assign brdata13_o = 256'd0; assign brvalid13_o = 1'b0;
    assign brdata14_o = 256'd0; assign brvalid14_o = 1'b0;
    assign brdata15_o = 256'd0; assign brvalid15_o = 1'b0;

endmodule