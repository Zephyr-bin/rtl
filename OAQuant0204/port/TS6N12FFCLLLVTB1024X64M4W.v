//*#*********************************************************************************************************************/
//*# Software       : TSMC MEMORY COMPILER tsn12ffclluhd2prf_2013.12.00.f.130b						*/
//*# Technology     : TSMC 12nm CMOS Logic FinFet Compact (FFC) Low Leakage HKMG							*/
//*# Memory Type    : TSMC 12nm FFC Ultra High Density Two Port Register File with d0907 bit cell */
//*# Library Name   : ts6n12ffclllvtb1024x64m4w (user specify : ts6n12ffclllvtb1024x64m4w)				*/
//*# Library Version: 130b												*/
//*# Generated Time : 2024/02/28, 15:29:45										*/
//*#*********************************************************************************************************************/
//*#															*/
//*# STATEMENT OF USE													*/
//*#															*/
//*# This information contains confidential and proprietary information of TSMC.					*/
//*# No part of this information may be reproduced, transmitted, transcribed,						*/
//*# stored in a retrieval system, or translated into any human or computer						*/
//*# language, in any form or by any means, electronic, mechanical, magnetic,						*/
//*# optical, chemical, manual, or otherwise, without the prior written permission					*/
//*# of TSMC. This information was prepared for informational purpose and is for					*/
//*# use by TSMC's customers only. TSMC reserves the right to make changes in the					*/
//*# information at any time and without notice.									*/
//*#															*/
//*#*********************************************************************************************************************/
//********************************************************************************/
//*                                                                              */
//*      Usage Limitation: PLEASE READ CAREFULLY FOR CORRECT USAGE               */
//* Please be careful when using non 2^n  memory.                                */
//* In a non-fully decoded array, a write cycle to a nonexistent address location*/
//* does not change the memory array contents and output remains the same.       */
//* In a non-fully decoded array, a read cycle to a nonexistent address location */
//* does not change the memory array contents but the output becomes unknown.    */
//*                                                                              */
//* In the verilog model, the behavior of unknown clock will corrupt the         */
//* memory data and make output unknown regardless of WEB/REB signal.But in the  */
//* silicon, the unknown clock at WEB/REB high, the memory and output data will  */
//* be held. The verilog model behavior is more conservative in this condition.  */
//*                                                                              */
//* The model doesn't identify physical column and row address                   */
//*                                                                              */
//* The verilog model provides TSMC_CM_UNIT_DELAY mode for the fast function     */
//* simulation.                                                                  */
//* All timing values in the specification are not checked in the                */
//* TSMC_CM_UNIT_DELAY mode simulation.                                          */
//* The timing values specified in this model do not reflect real circuit        */
//* behavior. For real timing simulation, please back annotate SDF file.         */
//*                                                                              */
//* Template Version : S_01_61302                                                */
//****************************************************************************** */
//*      Macro Usage       : (+define[MACRO] for Verilog compiliers)             */
//* +TSMC_CM_UNIT_DELAY : Enable fast function simulation.                       */
//* +TSMC_CM_NO_WARNING : Disable all runtime warnings message from this model.  */
//* +TSMC_INITIALIZE_MEM : Initialize the memory data in verilog format.         */
//* +TSMC_INITIALIZE_FAULT : Initialize the memory fault data in verilog format. */
//* +TSMC_NO_TESTPINS_DEFAULT_VALUE_CHECK : Disable the wrong test pins          */
//*                            connection error  message if necessary.           */
//* +TSMC_STUCKAT_FAULT : Enable injectSA task. Please don't use this option     */
//*                       with initial options like +vcs+initmem+0/1 or          */
//*                       +vcs+initreg+0/1 ...                                   */
//****************************************************************************** */
`resetall
`celldefine

`timescale 1ns/1ps

`delay_mode_path

`suppress_faults
`enable_portfaults

module TS6N12FFCLLLVTB1024X64M4W (
  AA,
  D,
  BWEB,
  WEB,
  AB,
  REB,CLK,
            RTSEL,
            WTSEL,
            MTSEL,
  Q);

// Parameter declarations
parameter  N = 64;
parameter  W = 1024;
parameter  M = 10;



`ifdef TSMC_CM_UNIT_DELAY
parameter  SRAM_DELAY = 0.0010;
`endif
`ifdef TSMC_INITIALIZE_MEM
parameter INITIAL_MEM_DELAY = 0.01;
`else
  `ifdef TSMC_INITIALIZE_MEM_USING_DEFAULT_TASKS
parameter INITIAL_MEM_DELAY = 0.01;
  `endif
`endif
`ifdef TSMC_INITIALIZE_FAULT
parameter INITIAL_FAULT_DELAY = 0.01;
`endif

// Input-Output declarations
   input [M-1:0] AA;                // Address write bus
   input [N-1:0] D;                 // Date input bus
   input [N-1:0] BWEB;              // BW data input bus //bitsmask
   input         WEB;               // Active-low Write enable
   input [M-1:0] AB;                // Address read bus 
   input         REB;               // Active-low Read enable
   input         CLK;              // Clock
// Test Mode
   input [1:0] RTSEL;
   input [1:0] WTSEL;
   input [1:0] MTSEL;

   output [N-1:0] Q;                 // Data output bus


//=== IO Ports ===//

`ifdef TSMC_CM_NO_WARNING
parameter MES_ALL = "OFF";
`else
parameter MES_ALL = "ON";
`endif

`ifdef TSMC_INITIALIZE_MEM
  parameter cdeFileInit  = "TS6N12FFCLLLVTB1024X64M4W_initial.cde";
`endif
`ifdef TSMC_INITIALIZE_FAULT
   parameter cdeFileFault = "TS6N12FFCLLLVTB1024X64M4W_fault.cde";
`endif

// Registers
reg invalid_rslp;
reg invalid_wslp;
reg invalid_rdslp;
reg invalid_wdslp;
reg invalid_sd_dslp;

// Registers
reg [N-1:0] DL;
reg [N-1:0] bDL;

reg [N-1:0] BWEBL;
reg [N-1:0] bBWEBL;

reg [M-1:0] AAL;
reg [M-1:0] ABL;
reg [M-1:0] bAAL;
reg [M-1:0] bABL;

reg WEBL;
reg REBL;

wire [N-1:0] QL;


wire iSLP = 1'b0;
wire bSLP = 1'b0;
wire iDSLP = 1'b0;
wire bDSLP = 1'b0;
wire bSD = 1'b0;
reg bSLPL;
reg bDSLPL;
reg bSDL;
reg valid_testpin;
reg valid_ck;
reg valid_wea;
reg valid_reb;
reg valid_aa;
reg valid_ab;
reg valid_pd;
reg valid_sd_dslp;
reg valid_d63, valid_d62, valid_d61, valid_d60, valid_d59, valid_d58, valid_d57, valid_d56, valid_d55, valid_d54, valid_d53, valid_d52, valid_d51, valid_d50, valid_d49, valid_d48, valid_d47, valid_d46, valid_d45, valid_d44, valid_d43, valid_d42, valid_d41, valid_d40, valid_d39, valid_d38, valid_d37, valid_d36, valid_d35, valid_d34, valid_d33, valid_d32, valid_d31, valid_d30, valid_d29, valid_d28, valid_d27, valid_d26, valid_d25, valid_d24, valid_d23, valid_d22, valid_d21, valid_d20, valid_d19, valid_d18, valid_d17, valid_d16, valid_d15, valid_d14, valid_d13, valid_d12, valid_d11, valid_d10, valid_d9, valid_d8, valid_d7, valid_d6, valid_d5, valid_d4, valid_d3, valid_d2, valid_d1, valid_d0;
reg valid_bw63, valid_bw62, valid_bw61, valid_bw60, valid_bw59, valid_bw58, valid_bw57, valid_bw56, valid_bw55, valid_bw54, valid_bw53, valid_bw52, valid_bw51, valid_bw50, valid_bw49, valid_bw48, valid_bw47, valid_bw46, valid_bw45, valid_bw44, valid_bw43, valid_bw42, valid_bw41, valid_bw40, valid_bw39, valid_bw38, valid_bw37, valid_bw36, valid_bw35, valid_bw34, valid_bw33, valid_bw32, valid_bw31, valid_bw30, valid_bw29, valid_bw28, valid_bw27, valid_bw26, valid_bw25, valid_bw24, valid_bw23, valid_bw22, valid_bw21, valid_bw20, valid_bw19, valid_bw18, valid_bw17, valid_bw16, valid_bw15, valid_bw14, valid_bw13, valid_bw12, valid_bw11, valid_bw10, valid_bw9, valid_bw8, valid_bw7, valid_bw6, valid_bw5, valid_bw4, valid_bw3, valid_bw2, valid_bw1, valid_bw0;


reg rstb_toggle_flag;




integer clk_count;
integer sd_mode;
integer awt_counter;
integer wk_counter;

reg EN;
reg RDA, RDB;

reg RCLK;

wire [N-1:0] bBWEB;

wire [N-1:0] bD;

wire [M-1:0] bAA;
wire [M-1:0] bAB;

wire bWEB;
wire bREB;
wire bCLK;

// Test Mode
wire [1:0] RTSEL_i;
wire [1:0] WTSEL_i;
wire [1:0] MTSEL_i;

reg [N-1:0] bQ;
reg [N-1:0] bQ_tmp;
wire [N-1:0] bbQ;



wire bDFTBYP;
assign bDFTBYP = 1'b0;
wire bSE;
assign bSE = 1'b0;

integer i;

// Address Inputs
buf sAA0 (bAA[0], AA[0]);
buf sAB0 (bAB[0], AB[0]);
buf sAA1 (bAA[1], AA[1]);
buf sAB1 (bAB[1], AB[1]);
buf sAA2 (bAA[2], AA[2]);
buf sAB2 (bAB[2], AB[2]);
buf sAA3 (bAA[3], AA[3]);
buf sAB3 (bAB[3], AB[3]);
buf sAA4 (bAA[4], AA[4]);
buf sAB4 (bAB[4], AB[4]);
buf sAA5 (bAA[5], AA[5]);
buf sAB5 (bAB[5], AB[5]);
buf sAA6 (bAA[6], AA[6]);
buf sAB6 (bAB[6], AB[6]);
buf sAA7 (bAA[7], AA[7]);
buf sAB7 (bAB[7], AB[7]);
buf sAA8 (bAA[8], AA[8]);
buf sAB8 (bAB[8], AB[8]);
buf sAA9 (bAA[9], AA[9]);
buf sAB9 (bAB[9], AB[9]);


// Bit Write/Data Inputs 
buf sD0 (bD[0], D[0]);
buf sBWEB0 (bBWEB[0], BWEB[0]);
buf sD1 (bD[1], D[1]);
buf sBWEB1 (bBWEB[1], BWEB[1]);
buf sD2 (bD[2], D[2]);
buf sBWEB2 (bBWEB[2], BWEB[2]);
buf sD3 (bD[3], D[3]);
buf sBWEB3 (bBWEB[3], BWEB[3]);
buf sD4 (bD[4], D[4]);
buf sBWEB4 (bBWEB[4], BWEB[4]);
buf sD5 (bD[5], D[5]);
buf sBWEB5 (bBWEB[5], BWEB[5]);
buf sD6 (bD[6], D[6]);
buf sBWEB6 (bBWEB[6], BWEB[6]);
buf sD7 (bD[7], D[7]);
buf sBWEB7 (bBWEB[7], BWEB[7]);
buf sD8 (bD[8], D[8]);
buf sBWEB8 (bBWEB[8], BWEB[8]);
buf sD9 (bD[9], D[9]);
buf sBWEB9 (bBWEB[9], BWEB[9]);
buf sD10 (bD[10], D[10]);
buf sBWEB10 (bBWEB[10], BWEB[10]);
buf sD11 (bD[11], D[11]);
buf sBWEB11 (bBWEB[11], BWEB[11]);
buf sD12 (bD[12], D[12]);
buf sBWEB12 (bBWEB[12], BWEB[12]);
buf sD13 (bD[13], D[13]);
buf sBWEB13 (bBWEB[13], BWEB[13]);
buf sD14 (bD[14], D[14]);
buf sBWEB14 (bBWEB[14], BWEB[14]);
buf sD15 (bD[15], D[15]);
buf sBWEB15 (bBWEB[15], BWEB[15]);
buf sD16 (bD[16], D[16]);
buf sBWEB16 (bBWEB[16], BWEB[16]);
buf sD17 (bD[17], D[17]);
buf sBWEB17 (bBWEB[17], BWEB[17]);
buf sD18 (bD[18], D[18]);
buf sBWEB18 (bBWEB[18], BWEB[18]);
buf sD19 (bD[19], D[19]);
buf sBWEB19 (bBWEB[19], BWEB[19]);
buf sD20 (bD[20], D[20]);
buf sBWEB20 (bBWEB[20], BWEB[20]);
buf sD21 (bD[21], D[21]);
buf sBWEB21 (bBWEB[21], BWEB[21]);
buf sD22 (bD[22], D[22]);
buf sBWEB22 (bBWEB[22], BWEB[22]);
buf sD23 (bD[23], D[23]);
buf sBWEB23 (bBWEB[23], BWEB[23]);
buf sD24 (bD[24], D[24]);
buf sBWEB24 (bBWEB[24], BWEB[24]);
buf sD25 (bD[25], D[25]);
buf sBWEB25 (bBWEB[25], BWEB[25]);
buf sD26 (bD[26], D[26]);
buf sBWEB26 (bBWEB[26], BWEB[26]);
buf sD27 (bD[27], D[27]);
buf sBWEB27 (bBWEB[27], BWEB[27]);
buf sD28 (bD[28], D[28]);
buf sBWEB28 (bBWEB[28], BWEB[28]);
buf sD29 (bD[29], D[29]);
buf sBWEB29 (bBWEB[29], BWEB[29]);
buf sD30 (bD[30], D[30]);
buf sBWEB30 (bBWEB[30], BWEB[30]);
buf sD31 (bD[31], D[31]);
buf sBWEB31 (bBWEB[31], BWEB[31]);
buf sD32 (bD[32], D[32]);
buf sBWEB32 (bBWEB[32], BWEB[32]);
buf sD33 (bD[33], D[33]);
buf sBWEB33 (bBWEB[33], BWEB[33]);
buf sD34 (bD[34], D[34]);
buf sBWEB34 (bBWEB[34], BWEB[34]);
buf sD35 (bD[35], D[35]);
buf sBWEB35 (bBWEB[35], BWEB[35]);
buf sD36 (bD[36], D[36]);
buf sBWEB36 (bBWEB[36], BWEB[36]);
buf sD37 (bD[37], D[37]);
buf sBWEB37 (bBWEB[37], BWEB[37]);
buf sD38 (bD[38], D[38]);
buf sBWEB38 (bBWEB[38], BWEB[38]);
buf sD39 (bD[39], D[39]);
buf sBWEB39 (bBWEB[39], BWEB[39]);
buf sD40 (bD[40], D[40]);
buf sBWEB40 (bBWEB[40], BWEB[40]);
buf sD41 (bD[41], D[41]);
buf sBWEB41 (bBWEB[41], BWEB[41]);
buf sD42 (bD[42], D[42]);
buf sBWEB42 (bBWEB[42], BWEB[42]);
buf sD43 (bD[43], D[43]);
buf sBWEB43 (bBWEB[43], BWEB[43]);
buf sD44 (bD[44], D[44]);
buf sBWEB44 (bBWEB[44], BWEB[44]);
buf sD45 (bD[45], D[45]);
buf sBWEB45 (bBWEB[45], BWEB[45]);
buf sD46 (bD[46], D[46]);
buf sBWEB46 (bBWEB[46], BWEB[46]);
buf sD47 (bD[47], D[47]);
buf sBWEB47 (bBWEB[47], BWEB[47]);
buf sD48 (bD[48], D[48]);
buf sBWEB48 (bBWEB[48], BWEB[48]);
buf sD49 (bD[49], D[49]);
buf sBWEB49 (bBWEB[49], BWEB[49]);
buf sD50 (bD[50], D[50]);
buf sBWEB50 (bBWEB[50], BWEB[50]);
buf sD51 (bD[51], D[51]);
buf sBWEB51 (bBWEB[51], BWEB[51]);
buf sD52 (bD[52], D[52]);
buf sBWEB52 (bBWEB[52], BWEB[52]);
buf sD53 (bD[53], D[53]);
buf sBWEB53 (bBWEB[53], BWEB[53]);
buf sD54 (bD[54], D[54]);
buf sBWEB54 (bBWEB[54], BWEB[54]);
buf sD55 (bD[55], D[55]);
buf sBWEB55 (bBWEB[55], BWEB[55]);
buf sD56 (bD[56], D[56]);
buf sBWEB56 (bBWEB[56], BWEB[56]);
buf sD57 (bD[57], D[57]);
buf sBWEB57 (bBWEB[57], BWEB[57]);
buf sD58 (bD[58], D[58]);
buf sBWEB58 (bBWEB[58], BWEB[58]);
buf sD59 (bD[59], D[59]);
buf sBWEB59 (bBWEB[59], BWEB[59]);
buf sD60 (bD[60], D[60]);
buf sBWEB60 (bBWEB[60], BWEB[60]);
buf sD61 (bD[61], D[61]);
buf sBWEB61 (bBWEB[61], BWEB[61]);
buf sD62 (bD[62], D[62]);
buf sBWEB62 (bBWEB[62], BWEB[62]);
buf sD63 (bD[63], D[63]);
buf sBWEB63 (bBWEB[63], BWEB[63]);


// Input Controls
buf sWEB (bWEB, WEB);
buf sREB (bREB, REB);
buf sCLK (bCLK, CLK);

buf sWE (WE, !bWEB);
wire WE_nopd = WE & ~bSD & ~bDSLP & ~bSLP & ~bDFTBYP & ~bSE;
buf sRE (RE, !bREB);
wire RE_nopd = RE & ~bSD & ~bDSLP & ~bSLP & ~bDFTBYP & ~bSE;




// Test Mode
buf sRTSEL0 (RTSEL_i[0], RTSEL[0]);
buf sRTSEL1 (RTSEL_i[1], RTSEL[1]);
buf sWTSEL0 (WTSEL_i[0], WTSEL[0]);
buf sWTSEL1 (WTSEL_i[1], WTSEL[1]);
buf sMTSEL0 (MTSEL_i[0], MTSEL[0]);
buf sMTSEL1 (MTSEL_i[1], MTSEL[1]);

// Output Data
buf sQ0 (Q[0], bbQ[0]);
//nmos (Q[0], bbQ[0], 1'b1);
buf sQ1 (Q[1], bbQ[1]);
//nmos (Q[1], bbQ[1], 1'b1);
buf sQ2 (Q[2], bbQ[2]);
//nmos (Q[2], bbQ[2], 1'b1);
buf sQ3 (Q[3], bbQ[3]);
//nmos (Q[3], bbQ[3], 1'b1);
buf sQ4 (Q[4], bbQ[4]);
//nmos (Q[4], bbQ[4], 1'b1);
buf sQ5 (Q[5], bbQ[5]);
//nmos (Q[5], bbQ[5], 1'b1);
buf sQ6 (Q[6], bbQ[6]);
//nmos (Q[6], bbQ[6], 1'b1);
buf sQ7 (Q[7], bbQ[7]);
//nmos (Q[7], bbQ[7], 1'b1);
buf sQ8 (Q[8], bbQ[8]);
//nmos (Q[8], bbQ[8], 1'b1);
buf sQ9 (Q[9], bbQ[9]);
//nmos (Q[9], bbQ[9], 1'b1);
buf sQ10 (Q[10], bbQ[10]);
//nmos (Q[10], bbQ[10], 1'b1);
buf sQ11 (Q[11], bbQ[11]);
//nmos (Q[11], bbQ[11], 1'b1);
buf sQ12 (Q[12], bbQ[12]);
//nmos (Q[12], bbQ[12], 1'b1);
buf sQ13 (Q[13], bbQ[13]);
//nmos (Q[13], bbQ[13], 1'b1);
buf sQ14 (Q[14], bbQ[14]);
//nmos (Q[14], bbQ[14], 1'b1);
buf sQ15 (Q[15], bbQ[15]);
//nmos (Q[15], bbQ[15], 1'b1);
buf sQ16 (Q[16], bbQ[16]);
//nmos (Q[16], bbQ[16], 1'b1);
buf sQ17 (Q[17], bbQ[17]);
//nmos (Q[17], bbQ[17], 1'b1);
buf sQ18 (Q[18], bbQ[18]);
//nmos (Q[18], bbQ[18], 1'b1);
buf sQ19 (Q[19], bbQ[19]);
//nmos (Q[19], bbQ[19], 1'b1);
buf sQ20 (Q[20], bbQ[20]);
//nmos (Q[20], bbQ[20], 1'b1);
buf sQ21 (Q[21], bbQ[21]);
//nmos (Q[21], bbQ[21], 1'b1);
buf sQ22 (Q[22], bbQ[22]);
//nmos (Q[22], bbQ[22], 1'b1);
buf sQ23 (Q[23], bbQ[23]);
//nmos (Q[23], bbQ[23], 1'b1);
buf sQ24 (Q[24], bbQ[24]);
//nmos (Q[24], bbQ[24], 1'b1);
buf sQ25 (Q[25], bbQ[25]);
//nmos (Q[25], bbQ[25], 1'b1);
buf sQ26 (Q[26], bbQ[26]);
//nmos (Q[26], bbQ[26], 1'b1);
buf sQ27 (Q[27], bbQ[27]);
//nmos (Q[27], bbQ[27], 1'b1);
buf sQ28 (Q[28], bbQ[28]);
//nmos (Q[28], bbQ[28], 1'b1);
buf sQ29 (Q[29], bbQ[29]);
//nmos (Q[29], bbQ[29], 1'b1);
buf sQ30 (Q[30], bbQ[30]);
//nmos (Q[30], bbQ[30], 1'b1);
buf sQ31 (Q[31], bbQ[31]);
//nmos (Q[31], bbQ[31], 1'b1);
buf sQ32 (Q[32], bbQ[32]);
//nmos (Q[32], bbQ[32], 1'b1);
buf sQ33 (Q[33], bbQ[33]);
//nmos (Q[33], bbQ[33], 1'b1);
buf sQ34 (Q[34], bbQ[34]);
//nmos (Q[34], bbQ[34], 1'b1);
buf sQ35 (Q[35], bbQ[35]);
//nmos (Q[35], bbQ[35], 1'b1);
buf sQ36 (Q[36], bbQ[36]);
//nmos (Q[36], bbQ[36], 1'b1);
buf sQ37 (Q[37], bbQ[37]);
//nmos (Q[37], bbQ[37], 1'b1);
buf sQ38 (Q[38], bbQ[38]);
//nmos (Q[38], bbQ[38], 1'b1);
buf sQ39 (Q[39], bbQ[39]);
//nmos (Q[39], bbQ[39], 1'b1);
buf sQ40 (Q[40], bbQ[40]);
//nmos (Q[40], bbQ[40], 1'b1);
buf sQ41 (Q[41], bbQ[41]);
//nmos (Q[41], bbQ[41], 1'b1);
buf sQ42 (Q[42], bbQ[42]);
//nmos (Q[42], bbQ[42], 1'b1);
buf sQ43 (Q[43], bbQ[43]);
//nmos (Q[43], bbQ[43], 1'b1);
buf sQ44 (Q[44], bbQ[44]);
//nmos (Q[44], bbQ[44], 1'b1);
buf sQ45 (Q[45], bbQ[45]);
//nmos (Q[45], bbQ[45], 1'b1);
buf sQ46 (Q[46], bbQ[46]);
//nmos (Q[46], bbQ[46], 1'b1);
buf sQ47 (Q[47], bbQ[47]);
//nmos (Q[47], bbQ[47], 1'b1);
buf sQ48 (Q[48], bbQ[48]);
//nmos (Q[48], bbQ[48], 1'b1);
buf sQ49 (Q[49], bbQ[49]);
//nmos (Q[49], bbQ[49], 1'b1);
buf sQ50 (Q[50], bbQ[50]);
//nmos (Q[50], bbQ[50], 1'b1);
buf sQ51 (Q[51], bbQ[51]);
//nmos (Q[51], bbQ[51], 1'b1);
buf sQ52 (Q[52], bbQ[52]);
//nmos (Q[52], bbQ[52], 1'b1);
buf sQ53 (Q[53], bbQ[53]);
//nmos (Q[53], bbQ[53], 1'b1);
buf sQ54 (Q[54], bbQ[54]);
//nmos (Q[54], bbQ[54], 1'b1);
buf sQ55 (Q[55], bbQ[55]);
//nmos (Q[55], bbQ[55], 1'b1);
buf sQ56 (Q[56], bbQ[56]);
//nmos (Q[56], bbQ[56], 1'b1);
buf sQ57 (Q[57], bbQ[57]);
//nmos (Q[57], bbQ[57], 1'b1);
buf sQ58 (Q[58], bbQ[58]);
//nmos (Q[58], bbQ[58], 1'b1);
buf sQ59 (Q[59], bbQ[59]);
//nmos (Q[59], bbQ[59], 1'b1);
buf sQ60 (Q[60], bbQ[60]);
//nmos (Q[60], bbQ[60], 1'b1);
buf sQ61 (Q[61], bbQ[61]);
//nmos (Q[61], bbQ[61], 1'b1);
buf sQ62 (Q[62], bbQ[62]);
//nmos (Q[62], bbQ[62], 1'b1);
buf sQ63 (Q[63], bbQ[63]);
//nmos (Q[63], bbQ[63], 1'b1);



assign bbQ=bQ;
wire check_nopd = ~bSD & ~bDSLP & ~bSLP;
wire mem_nopd = ~bSD & ~bDSLP & ~bSLP & ~bDFTBYP & ~bSE;

wire AeqB, BeqA;
wire AbeforeB, BbeforeA;

real tw_ff;
real tr_ff;

wire iREB = bREB;
wire iWEB = bWEB;
wire [N-1:0] iBWEB = bBWEB;
wire [N-1:0] iD = bD;
wire [M-1:0] iAA = bAA;
wire [M-1:0] iAB = bAB;
reg RREB, RWEB;  


wire check_ceb = (~iWEB | ~iREB) & ~bSD & ~bDSLP & ~bSLP & ~bDFTBYP & ~bSE;


wire check_noidle = (~REBL | ~WEBL) & ~bSD & ~bDSLP & ~bSLP & ~bDFTBYP & ~bSE;
wire check_idle = (REBL & WEBL) & ~bSD & ~bDSLP & ~bSLP & ~bDFTBYP & ~bSE;




`ifdef TSMC_CM_UNIT_DELAY
`else

`ifdef TSMC_CM_ACCESS
`else
`define TSMC_CM_ACCESS 0.02
`endif
`ifdef TSMC_CM_RETAIN
`else
`define TSMC_CM_RETAIN 0.015
`endif
`ifdef TSMC_CM_SETUP
`else
`define TSMC_CM_SETUP 0.001
`endif
`ifdef TSMC_CM_HOLD
`else
`define TSMC_CM_HOLD 0.001
`endif
`ifdef TSMC_CM_PERIOD
`else
`define TSMC_CM_PERIOD 1
`endif
`ifdef TSMC_CM_WIDTH
`else
`define TSMC_CM_WIDTH 0.5
`endif
`ifdef TSMC_CM_CONTENTION
`else
`define TSMC_CM_CONTENTION 0.001
`endif

specify
    specparam PATHPULSE$ = ( 0, 0.001 );

specparam

tckl = (`TSMC_CM_WIDTH),
tckh = (`TSMC_CM_WIDTH),
tcyc = (`TSMC_CM_PERIOD),


taas = (`TSMC_CM_SETUP),
taah = (`TSMC_CM_HOLD),
tabs = (`TSMC_CM_SETUP),
tabh = (`TSMC_CM_HOLD),
tds = (`TSMC_CM_SETUP),
tdh = (`TSMC_CM_HOLD),
tws = (`TSMC_CM_SETUP),
twh = (`TSMC_CM_HOLD),
trs = (`TSMC_CM_SETUP),
trh = (`TSMC_CM_HOLD),
tbws = (`TSMC_CM_SETUP),
tbwh = (`TSMC_CM_HOLD),

ttests = (`TSMC_CM_SETUP),
ttesth = (`TSMC_CM_HOLD),





tcd = (`TSMC_CM_ACCESS),
`ifdef TSMC_CM_READ_X_SQUASHING
thold = (`TSMC_CM_ACCESS);
`else
thold = (`TSMC_CM_RETAIN);
`endif




    $setuphold (posedge CLK &&& check_noidle, posedge RTSEL[0], ttests, 0, valid_testpin); 
    $setuphold (posedge CLK &&& check_noidle, negedge RTSEL[0], ttests, 0, valid_testpin);
    $setuphold (posedge CLK &&& check_idle, posedge RTSEL[0], 0, ttesth, valid_testpin); 
    $setuphold (posedge CLK &&& check_idle, negedge RTSEL[0], 0, ttesth, valid_testpin);
    $setuphold (posedge CLK &&& check_noidle, posedge RTSEL[1], ttests, 0, valid_testpin); 
    $setuphold (posedge CLK &&& check_noidle, negedge RTSEL[1], ttests, 0, valid_testpin);
    $setuphold (posedge CLK &&& check_idle, posedge RTSEL[1], 0, ttesth, valid_testpin); 
    $setuphold (posedge CLK &&& check_idle, negedge RTSEL[1], 0, ttesth, valid_testpin);
    $setuphold (posedge CLK &&& check_noidle, posedge WTSEL[0], ttests, 0, valid_testpin); 
    $setuphold (posedge CLK &&& check_noidle, negedge WTSEL[0], ttests, 0, valid_testpin);
    $setuphold (posedge CLK &&& check_idle, posedge WTSEL[0], 0, ttesth, valid_testpin); 
    $setuphold (posedge CLK &&& check_idle, negedge WTSEL[0], 0, ttesth, valid_testpin);
    $setuphold (posedge CLK &&& check_noidle, posedge WTSEL[1], ttests, 0, valid_testpin); 
    $setuphold (posedge CLK &&& check_noidle, negedge WTSEL[1], ttests, 0, valid_testpin);
    $setuphold (posedge CLK &&& check_idle, posedge WTSEL[1], 0, ttesth, valid_testpin); 
    $setuphold (posedge CLK &&& check_idle, negedge WTSEL[1], 0, ttesth, valid_testpin);
    $setuphold (posedge CLK &&& check_noidle, posedge MTSEL[0], ttests, 0, valid_testpin); 
    $setuphold (posedge CLK &&& check_noidle, negedge MTSEL[0], ttests, 0, valid_testpin);
    $setuphold (posedge CLK &&& check_idle, posedge MTSEL[0], 0, ttesth, valid_testpin); 
    $setuphold (posedge CLK &&& check_idle, negedge MTSEL[0], 0, ttesth, valid_testpin);
    $setuphold (posedge CLK &&& check_noidle, posedge MTSEL[1], ttests, 0, valid_testpin); 
    $setuphold (posedge CLK &&& check_noidle, negedge MTSEL[1], ttests, 0, valid_testpin);
    $setuphold (posedge CLK &&& check_idle, posedge MTSEL[1], 0, ttesth, valid_testpin); 
    $setuphold (posedge CLK &&& check_idle, negedge MTSEL[1], 0, ttesth, valid_testpin);





  $setuphold (posedge CLK &&& WE_nopd, posedge AA[0], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& WE_nopd, negedge AA[0], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& RE_nopd, posedge AB[0], tabs, tabh, valid_ab);
  $setuphold (posedge CLK &&& RE_nopd, negedge AB[0], tabs, tabh, valid_ab);

  $setuphold (posedge CLK &&& WE_nopd, posedge AA[1], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& WE_nopd, negedge AA[1], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& RE_nopd, posedge AB[1], tabs, tabh, valid_ab);
  $setuphold (posedge CLK &&& RE_nopd, negedge AB[1], tabs, tabh, valid_ab);

  $setuphold (posedge CLK &&& WE_nopd, posedge AA[2], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& WE_nopd, negedge AA[2], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& RE_nopd, posedge AB[2], tabs, tabh, valid_ab);
  $setuphold (posedge CLK &&& RE_nopd, negedge AB[2], tabs, tabh, valid_ab);

  $setuphold (posedge CLK &&& WE_nopd, posedge AA[3], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& WE_nopd, negedge AA[3], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& RE_nopd, posedge AB[3], tabs, tabh, valid_ab);
  $setuphold (posedge CLK &&& RE_nopd, negedge AB[3], tabs, tabh, valid_ab);

  $setuphold (posedge CLK &&& WE_nopd, posedge AA[4], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& WE_nopd, negedge AA[4], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& RE_nopd, posedge AB[4], tabs, tabh, valid_ab);
  $setuphold (posedge CLK &&& RE_nopd, negedge AB[4], tabs, tabh, valid_ab);

  $setuphold (posedge CLK &&& WE_nopd, posedge AA[5], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& WE_nopd, negedge AA[5], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& RE_nopd, posedge AB[5], tabs, tabh, valid_ab);
  $setuphold (posedge CLK &&& RE_nopd, negedge AB[5], tabs, tabh, valid_ab);

  $setuphold (posedge CLK &&& WE_nopd, posedge AA[6], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& WE_nopd, negedge AA[6], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& RE_nopd, posedge AB[6], tabs, tabh, valid_ab);
  $setuphold (posedge CLK &&& RE_nopd, negedge AB[6], tabs, tabh, valid_ab);

  $setuphold (posedge CLK &&& WE_nopd, posedge AA[7], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& WE_nopd, negedge AA[7], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& RE_nopd, posedge AB[7], tabs, tabh, valid_ab);
  $setuphold (posedge CLK &&& RE_nopd, negedge AB[7], tabs, tabh, valid_ab);

  $setuphold (posedge CLK &&& WE_nopd, posedge AA[8], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& WE_nopd, negedge AA[8], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& RE_nopd, posedge AB[8], tabs, tabh, valid_ab);
  $setuphold (posedge CLK &&& RE_nopd, negedge AB[8], tabs, tabh, valid_ab);

  $setuphold (posedge CLK &&& WE_nopd, posedge AA[9], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& WE_nopd, negedge AA[9], taas, taah, valid_aa);
  $setuphold (posedge CLK &&& RE_nopd, posedge AB[9], tabs, tabh, valid_ab);
  $setuphold (posedge CLK &&& RE_nopd, negedge AB[9], tabs, tabh, valid_ab);


  $setuphold (posedge CLK &&& WE_nopd, posedge D[0], tds, tdh, valid_d0);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[0], tds, tdh, valid_d0);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[0], tbws, tbwh, valid_bw0);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[0], tbws, tbwh, valid_bw0);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[1], tds, tdh, valid_d1);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[1], tds, tdh, valid_d1);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[1], tbws, tbwh, valid_bw1);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[1], tbws, tbwh, valid_bw1);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[2], tds, tdh, valid_d2);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[2], tds, tdh, valid_d2);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[2], tbws, tbwh, valid_bw2);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[2], tbws, tbwh, valid_bw2);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[3], tds, tdh, valid_d3);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[3], tds, tdh, valid_d3);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[3], tbws, tbwh, valid_bw3);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[3], tbws, tbwh, valid_bw3);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[4], tds, tdh, valid_d4);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[4], tds, tdh, valid_d4);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[4], tbws, tbwh, valid_bw4);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[4], tbws, tbwh, valid_bw4);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[5], tds, tdh, valid_d5);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[5], tds, tdh, valid_d5);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[5], tbws, tbwh, valid_bw5);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[5], tbws, tbwh, valid_bw5);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[6], tds, tdh, valid_d6);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[6], tds, tdh, valid_d6);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[6], tbws, tbwh, valid_bw6);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[6], tbws, tbwh, valid_bw6);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[7], tds, tdh, valid_d7);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[7], tds, tdh, valid_d7);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[7], tbws, tbwh, valid_bw7);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[7], tbws, tbwh, valid_bw7);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[8], tds, tdh, valid_d8);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[8], tds, tdh, valid_d8);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[8], tbws, tbwh, valid_bw8);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[8], tbws, tbwh, valid_bw8);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[9], tds, tdh, valid_d9);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[9], tds, tdh, valid_d9);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[9], tbws, tbwh, valid_bw9);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[9], tbws, tbwh, valid_bw9);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[10], tds, tdh, valid_d10);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[10], tds, tdh, valid_d10);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[10], tbws, tbwh, valid_bw10);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[10], tbws, tbwh, valid_bw10);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[11], tds, tdh, valid_d11);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[11], tds, tdh, valid_d11);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[11], tbws, tbwh, valid_bw11);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[11], tbws, tbwh, valid_bw11);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[12], tds, tdh, valid_d12);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[12], tds, tdh, valid_d12);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[12], tbws, tbwh, valid_bw12);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[12], tbws, tbwh, valid_bw12);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[13], tds, tdh, valid_d13);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[13], tds, tdh, valid_d13);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[13], tbws, tbwh, valid_bw13);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[13], tbws, tbwh, valid_bw13);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[14], tds, tdh, valid_d14);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[14], tds, tdh, valid_d14);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[14], tbws, tbwh, valid_bw14);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[14], tbws, tbwh, valid_bw14);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[15], tds, tdh, valid_d15);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[15], tds, tdh, valid_d15);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[15], tbws, tbwh, valid_bw15);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[15], tbws, tbwh, valid_bw15);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[16], tds, tdh, valid_d16);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[16], tds, tdh, valid_d16);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[16], tbws, tbwh, valid_bw16);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[16], tbws, tbwh, valid_bw16);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[17], tds, tdh, valid_d17);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[17], tds, tdh, valid_d17);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[17], tbws, tbwh, valid_bw17);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[17], tbws, tbwh, valid_bw17);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[18], tds, tdh, valid_d18);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[18], tds, tdh, valid_d18);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[18], tbws, tbwh, valid_bw18);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[18], tbws, tbwh, valid_bw18);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[19], tds, tdh, valid_d19);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[19], tds, tdh, valid_d19);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[19], tbws, tbwh, valid_bw19);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[19], tbws, tbwh, valid_bw19);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[20], tds, tdh, valid_d20);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[20], tds, tdh, valid_d20);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[20], tbws, tbwh, valid_bw20);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[20], tbws, tbwh, valid_bw20);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[21], tds, tdh, valid_d21);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[21], tds, tdh, valid_d21);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[21], tbws, tbwh, valid_bw21);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[21], tbws, tbwh, valid_bw21);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[22], tds, tdh, valid_d22);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[22], tds, tdh, valid_d22);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[22], tbws, tbwh, valid_bw22);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[22], tbws, tbwh, valid_bw22);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[23], tds, tdh, valid_d23);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[23], tds, tdh, valid_d23);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[23], tbws, tbwh, valid_bw23);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[23], tbws, tbwh, valid_bw23);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[24], tds, tdh, valid_d24);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[24], tds, tdh, valid_d24);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[24], tbws, tbwh, valid_bw24);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[24], tbws, tbwh, valid_bw24);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[25], tds, tdh, valid_d25);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[25], tds, tdh, valid_d25);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[25], tbws, tbwh, valid_bw25);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[25], tbws, tbwh, valid_bw25);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[26], tds, tdh, valid_d26);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[26], tds, tdh, valid_d26);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[26], tbws, tbwh, valid_bw26);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[26], tbws, tbwh, valid_bw26);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[27], tds, tdh, valid_d27);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[27], tds, tdh, valid_d27);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[27], tbws, tbwh, valid_bw27);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[27], tbws, tbwh, valid_bw27);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[28], tds, tdh, valid_d28);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[28], tds, tdh, valid_d28);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[28], tbws, tbwh, valid_bw28);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[28], tbws, tbwh, valid_bw28);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[29], tds, tdh, valid_d29);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[29], tds, tdh, valid_d29);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[29], tbws, tbwh, valid_bw29);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[29], tbws, tbwh, valid_bw29);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[30], tds, tdh, valid_d30);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[30], tds, tdh, valid_d30);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[30], tbws, tbwh, valid_bw30);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[30], tbws, tbwh, valid_bw30);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[31], tds, tdh, valid_d31);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[31], tds, tdh, valid_d31);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[31], tbws, tbwh, valid_bw31);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[31], tbws, tbwh, valid_bw31);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[32], tds, tdh, valid_d32);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[32], tds, tdh, valid_d32);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[32], tbws, tbwh, valid_bw32);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[32], tbws, tbwh, valid_bw32);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[33], tds, tdh, valid_d33);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[33], tds, tdh, valid_d33);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[33], tbws, tbwh, valid_bw33);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[33], tbws, tbwh, valid_bw33);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[34], tds, tdh, valid_d34);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[34], tds, tdh, valid_d34);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[34], tbws, tbwh, valid_bw34);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[34], tbws, tbwh, valid_bw34);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[35], tds, tdh, valid_d35);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[35], tds, tdh, valid_d35);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[35], tbws, tbwh, valid_bw35);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[35], tbws, tbwh, valid_bw35);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[36], tds, tdh, valid_d36);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[36], tds, tdh, valid_d36);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[36], tbws, tbwh, valid_bw36);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[36], tbws, tbwh, valid_bw36);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[37], tds, tdh, valid_d37);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[37], tds, tdh, valid_d37);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[37], tbws, tbwh, valid_bw37);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[37], tbws, tbwh, valid_bw37);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[38], tds, tdh, valid_d38);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[38], tds, tdh, valid_d38);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[38], tbws, tbwh, valid_bw38);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[38], tbws, tbwh, valid_bw38);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[39], tds, tdh, valid_d39);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[39], tds, tdh, valid_d39);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[39], tbws, tbwh, valid_bw39);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[39], tbws, tbwh, valid_bw39);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[40], tds, tdh, valid_d40);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[40], tds, tdh, valid_d40);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[40], tbws, tbwh, valid_bw40);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[40], tbws, tbwh, valid_bw40);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[41], tds, tdh, valid_d41);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[41], tds, tdh, valid_d41);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[41], tbws, tbwh, valid_bw41);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[41], tbws, tbwh, valid_bw41);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[42], tds, tdh, valid_d42);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[42], tds, tdh, valid_d42);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[42], tbws, tbwh, valid_bw42);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[42], tbws, tbwh, valid_bw42);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[43], tds, tdh, valid_d43);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[43], tds, tdh, valid_d43);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[43], tbws, tbwh, valid_bw43);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[43], tbws, tbwh, valid_bw43);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[44], tds, tdh, valid_d44);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[44], tds, tdh, valid_d44);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[44], tbws, tbwh, valid_bw44);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[44], tbws, tbwh, valid_bw44);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[45], tds, tdh, valid_d45);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[45], tds, tdh, valid_d45);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[45], tbws, tbwh, valid_bw45);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[45], tbws, tbwh, valid_bw45);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[46], tds, tdh, valid_d46);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[46], tds, tdh, valid_d46);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[46], tbws, tbwh, valid_bw46);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[46], tbws, tbwh, valid_bw46);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[47], tds, tdh, valid_d47);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[47], tds, tdh, valid_d47);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[47], tbws, tbwh, valid_bw47);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[47], tbws, tbwh, valid_bw47);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[48], tds, tdh, valid_d48);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[48], tds, tdh, valid_d48);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[48], tbws, tbwh, valid_bw48);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[48], tbws, tbwh, valid_bw48);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[49], tds, tdh, valid_d49);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[49], tds, tdh, valid_d49);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[49], tbws, tbwh, valid_bw49);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[49], tbws, tbwh, valid_bw49);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[50], tds, tdh, valid_d50);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[50], tds, tdh, valid_d50);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[50], tbws, tbwh, valid_bw50);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[50], tbws, tbwh, valid_bw50);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[51], tds, tdh, valid_d51);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[51], tds, tdh, valid_d51);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[51], tbws, tbwh, valid_bw51);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[51], tbws, tbwh, valid_bw51);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[52], tds, tdh, valid_d52);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[52], tds, tdh, valid_d52);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[52], tbws, tbwh, valid_bw52);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[52], tbws, tbwh, valid_bw52);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[53], tds, tdh, valid_d53);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[53], tds, tdh, valid_d53);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[53], tbws, tbwh, valid_bw53);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[53], tbws, tbwh, valid_bw53);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[54], tds, tdh, valid_d54);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[54], tds, tdh, valid_d54);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[54], tbws, tbwh, valid_bw54);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[54], tbws, tbwh, valid_bw54);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[55], tds, tdh, valid_d55);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[55], tds, tdh, valid_d55);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[55], tbws, tbwh, valid_bw55);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[55], tbws, tbwh, valid_bw55);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[56], tds, tdh, valid_d56);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[56], tds, tdh, valid_d56);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[56], tbws, tbwh, valid_bw56);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[56], tbws, tbwh, valid_bw56);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[57], tds, tdh, valid_d57);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[57], tds, tdh, valid_d57);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[57], tbws, tbwh, valid_bw57);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[57], tbws, tbwh, valid_bw57);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[58], tds, tdh, valid_d58);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[58], tds, tdh, valid_d58);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[58], tbws, tbwh, valid_bw58);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[58], tbws, tbwh, valid_bw58);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[59], tds, tdh, valid_d59);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[59], tds, tdh, valid_d59);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[59], tbws, tbwh, valid_bw59);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[59], tbws, tbwh, valid_bw59);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[60], tds, tdh, valid_d60);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[60], tds, tdh, valid_d60);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[60], tbws, tbwh, valid_bw60);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[60], tbws, tbwh, valid_bw60);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[61], tds, tdh, valid_d61);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[61], tds, tdh, valid_d61);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[61], tbws, tbwh, valid_bw61);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[61], tbws, tbwh, valid_bw61);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[62], tds, tdh, valid_d62);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[62], tds, tdh, valid_d62);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[62], tbws, tbwh, valid_bw62);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[62], tbws, tbwh, valid_bw62);

  $setuphold (posedge CLK &&& WE_nopd, posedge D[63], tds, tdh, valid_d63);
  $setuphold (posedge CLK &&& WE_nopd, negedge D[63], tds, tdh, valid_d63);
 
  $setuphold (posedge CLK &&& WE_nopd, posedge BWEB[63], tbws, tbwh, valid_bw63);
  $setuphold (posedge CLK &&& WE_nopd, negedge BWEB[63], tbws, tbwh, valid_bw63);

  $setuphold (posedge CLK &&& mem_nopd, posedge WEB, tws, twh, valid_wea);
  $setuphold (posedge CLK &&& mem_nopd, negedge WEB, tws, twh, valid_wea);
  $setuphold (posedge CLK &&& mem_nopd, posedge REB, trs, trh, valid_reb);
  $setuphold (posedge CLK &&& mem_nopd, negedge REB, trs, trh, valid_reb);

  $period(posedge CLK &&& check_ceb, tcyc, valid_ck);
  $period(negedge CLK &&& check_ceb, tcyc, valid_ck);
  $width(posedge CLK &&& check_ceb, tckh, 0, valid_ck);
  $width(negedge CLK &&& check_ceb, tckl, 0, valid_ck);

  



 if (!REB) (posedge CLK => (Q[0] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[1] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[2] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[3] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[4] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[5] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[6] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[7] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[8] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[9] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[10] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[11] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[12] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[13] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[14] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[15] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[16] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[17] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[18] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[19] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[20] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[21] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[22] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[23] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[24] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[25] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[26] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[27] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[28] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[29] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[30] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[31] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[32] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[33] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[34] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[35] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[36] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[37] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[38] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[39] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[40] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[41] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[42] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[43] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[44] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[45] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[46] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[47] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[48] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[49] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[50] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[51] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[52] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[53] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[54] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[55] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[56] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[57] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[58] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[59] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[60] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[61] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[62] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!REB) (posedge CLK => (Q[63] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);

endspecify
`endif

initial
begin
  assign EN = 1;
  clk_count = 0;
  sd_mode = 0;
  RDB = 1'b0;
  BWEBL =  {N{1'b1}};
  tw_ff = 0;
  tr_ff = 0;
  WEBL = 1'b1;
  REBL = 1'b1;
  awt_counter = 0;
  wk_counter = 0;
  rstb_toggle_flag = 1'b1;
  invalid_rslp = 1'b0;
  invalid_wslp = 1'b0;
  invalid_rdslp = 1'b0;
  invalid_wdslp = 1'b0;
  invalid_sd_dslp = 1'b0;
end

`ifdef TSMC_INITIALIZE_MEM_USING_DEFAULT_TASKS
initial begin
    #(INITIAL_MEM_DELAY) ;
`ifdef TSMC_MEM_LOAD_0
    zeroMemoryAll;
`else
 `ifdef TSMC_MEM_LOAD_1
    oneMemoryAll;
 `else
  `ifdef TSMC_MEM_LOAD_RANDOM
    randomMemoryAll;
  `else
    xMemoryAll;
  `endif
 `endif
`endif    
end
`endif //`ifdef TSMC_INITIALIZE_MEM_USING_DEFAULT_TASKS

`ifdef TSMC_INITIALIZE_MEM
initial
   begin 
`ifdef TSMC_INITIALIZE_FORMAT_BINARY
     #(INITIAL_MEM_DELAY)  $readmemb(cdeFileInit, MX.mem, 0, W-1);
`else
     #(INITIAL_MEM_DELAY)  $readmemh(cdeFileInit, MX.mem, 0, W-1);
`endif
   end
`endif //  `ifdef TSMC_INITIALIZE_MEM
   
`ifdef TSMC_INITIALIZE_FAULT
initial
   begin
`ifdef TSMC_INITIALIZE_FORMAT_BINARY
     #(INITIAL_FAULT_DELAY) $readmemb(cdeFileFault, MX.mem_fault, 0, W-1);
`else
     #(INITIAL_FAULT_DELAY) $readmemh(cdeFileFault, MX.mem_fault, 0, W-1);
`endif
   end
`endif //  `ifdef TSMC_INITIALIZE_FAULT


always @(RTSEL_i) begin
    if (bSLP === 1'b0 && bDSLP === 1'b0 && bSD === 1'b0) begin
        if(($realtime > 0) && (!REBL || !WEBL) && bDFTBYP === 1'b0 && bSE === 1'b0) begin
`ifdef TSMC_CM_NO_WARNING
`else
            $display("\tWarning %m : input RTSEL should not be toggled when REB/WEB is low at simulation time %t\n", $realtime);
`endif            
`ifdef TSMC_CM_UNIT_DELAY
            #(SRAM_DELAY);
`endif
            bQ = {N{1'bx}};        
            AAL <= {M{1'bx}};
            BWEBL <= {N{1'b0}};
        end
    end
end
always @(WTSEL_i) begin
    if (bSLP === 1'b0 && bDSLP === 1'b0 && bSD === 1'b0) begin
        if(($realtime > 0) && (!REBL || !WEBL) && bDFTBYP === 1'b0 && bSE === 1'b0) begin
`ifdef TSMC_CM_NO_WARNING
`else
            $display("\tWarning %m : input WTSEL should not be toggled when REB/WEB is low at simulation time %t\n", $realtime);
`endif            
`ifdef TSMC_CM_UNIT_DELAY
            #(SRAM_DELAY);
`endif
            bQ = {N{1'bx}};        
            AAL <= {M{1'bx}};
            BWEBL <= {N{1'b0}};
        end
    end
end
always @(MTSEL_i) begin
    if (bSLP === 1'b0 && bDSLP === 1'b0 && bSD === 1'b0) begin
        if(($realtime > 0) && (!REBL || !WEBL) && bDFTBYP === 1'b0 && bSE === 1'b0) begin
`ifdef TSMC_CM_NO_WARNING
`else
            $display("\tWarning %m : input MTSEL should not be toggled when REB/WEB is low at simulation time %t\n", $realtime);
`endif            
`ifdef TSMC_CM_UNIT_DELAY
            #(SRAM_DELAY);
`endif
            bQ = {N{1'bx}};        
            AAL <= {M{1'bx}};
            BWEBL <= {N{1'b0}};
        end
    end
end

`ifdef TSMC_NO_TESTPINS_DEFAULT_VALUE_CHECK
`else
always @(bCLK or RTSEL_i) begin
    if (bSLP === 1'b0 && bDSLP === 1'b0 && bSD === 1'b0) begin
        if((RTSEL_i !== 2'b01) && ($realtime > 0)) begin
            $display("\tError %m : input RTSEL should be set to 2'b01 at simulation time %t\n", $realtime);
            $display("\tError %m : Please refer the datasheet/databook for the RTSEL setting in the different segment and mux configuration\n");
            
            if(bDFTBYP === 1'b0 && bSE === 1'b0) begin
                AAL <= {M{1'bx}};
                BWEBL <= {N{1'b0}};
                bQ = #0.01 {N{1'bx}};
            end
        end
    end
end
always @(bCLK or WTSEL_i) begin
    if (bSLP === 1'b0 && bDSLP === 1'b0 && bSD === 1'b0) begin
        if((WTSEL_i !== 2'b00) && ($realtime > 0)) begin
            $display("\tError %m : input WTSEL should be set to 2'b00 at simulation time %t\n", $realtime);
            $display("\tError %m : Please refer the datasheet/databook for the WTSEL setting in the different segment and mux configuration\n");
            
            if(bDFTBYP === 1'b0 && bSE === 1'b0) begin
                AAL <= {M{1'bx}};
                BWEBL <= {N{1'b0}};
                bQ = #0.01 {N{1'bx}};
            end
        end
    end
end
always @(bCLK or MTSEL_i) begin
    if (bSLP === 1'b0 && bDSLP === 1'b0 && bSD === 1'b0) begin
        if((MTSEL_i !== 2'b00) && ($realtime > 0)) begin
            $display("\tError %m : input MTSEL should be set to 2'b00 at simulation time %t\n", $realtime);
            $display("\tError %m : Please refer the datasheet/databook for the MTSEL setting in the different segment and mux configuration\n");
            
            if(bDFTBYP === 1'b0 && bSE === 1'b0) begin
                AAL <= {M{1'bx}};
                BWEBL <= {N{1'b0}};
                bQ = #0.01 {N{1'bx}};
            end
        end
    end
end
`endif





always @(bCLK) begin
    if (bSLP === 1'b0 && bDSLP === 1'b0 && bSD === 1'b0 && bDFTBYP === 1'b0 && bSE === 1'b0) begin
    if (bCLK === 1'b1 && RCLK === 1'b0 && clk_count == 0) begin
        WEBL = bWEB;
        REBL = bREB;
        bBWEBL = bBWEB;
        bAAL = bAA;
        bABL = bAB;
        bDL = bD;
        bSLPL = bSLP;
        bDSLPL = bDSLP;
        bSDL = bSD;
    end    

   if (bCLK === 1'bx && bSLPL === 1'b0 && bDSLPL === 1'b0 && bSDL === 1'b0 && clk_count == 0) begin
      if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m CLK unknown at %t.>>", $realtime);
      
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
      bQ = #0.01 {N{1'bx}};
   end
   else if (bCLK === 1'b1 && RCLK === 1'b0 && bSLPL === 1'b0 && bDSLPL === 1'b0 && bSDL === 1'b0 && clk_count === 1'b0)
   begin

// read operation
      if (REBL === 1'bx) begin
           if( MES_ALL=="ON" && $realtime != 0)
              $display("\nWarning %m REB unknown at %t.>>", $realtime);
           bQ = #0.01 {N{1'bx}};
      end
      else if (^bABL === 1'bx && REBL === 1'b0 && bSLPL === 1'b0 && bDSLPL === 1'b0 && bSDL === 1'b0 && clk_count == 0) begin
           `ifndef TSMC_CM_NO_XADDR_WARNING
           if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m READ AB unknown at %t. >>", $realtime);
	   `endif
           
           bQ = #0.01 {N{1'bx}};
           //xMemoryAll;
      end
      else begin
         if (rstb_toggle_flag == 1'b1 && REBL === 1'b0 && bSLPL === 1'b0 && bDSLPL === 1'b0 && bSDL === 1'b0 && clk_count == 0) begin
           ABL = bABL;
           RDB = ~RDB;
         end
      end //end else

// write operation
      AAL = bAAL;

      if (WEBL === 1'bx) begin
          if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m WEB unknown at %t. >>", $realtime);
          xMemoryAll;
      end
        
      if (^bAAL === 1'bx && WEBL === 1'b0 && bSLPL === 1'b0 && bDSLPL === 1'b0 && bSDL === 1'b0 && clk_count == 0) begin
          if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m WRITE AA unknown at %t. >>", $realtime);
          
          AAL <= {M{1'bx}};
          BWEBL <= {N{1'b0}};
          xMemoryAll;
      end
      else begin
          if (WEBL !== 1'b1 && bSLPL === 1'b0 && bDSLPL === 1'b0 && bSDL === 1'b0 && clk_count === 1'b0) DL = bDL;
          if (WEBL !== 1'b1 && bSLPL === 1'b0 && bDSLPL === 1'b0 && bSDL === 1'b0 && clk_count === 1'b0) begin                         // begin if (bWEB !== 1'b1) 
              if (^bBWEBL === 1'bx) begin
                  if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m BWEB unknown at %t. >>", $realtime);
              end
              #0.001;
              for (i = 0; i < N; i = i + 1) 
              begin                      // begin for...
                  if (!bBWEBL[i] && !WEBL) BWEBL[i] = 1'b0;
                  if ((WEBL===1'bx) || (bBWEBL[i] ===1'bx))
                  begin
                      BWEBL[i] = 1'b0; 
                      DL[i] = 1'bx;
                  end                     // end if (((...
             end                        // end for (
          end
      end
    end
    end
    RCLK = bCLK;
end

always @(RDB or QL) 
begin : CLKOPREAD
    if (bSLP === 1'b0 && bDSLP === 1'b0 && bSD === 1'b0) begin
`ifdef TSMC_CM_UNIT_DELAY
        #(SRAM_DELAY);
`else
        bQ = {N{1'bx}};
        #0.01; 
`endif
        bQ = QL;
    end
end // always @ (RDB or QL)





always @(BWEBL) begin
    BWEBL = #0.01 {N{1'b1}};
end


 
`ifdef TSMC_CM_UNIT_DELAY
`else
always @(valid_aa)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
  end
   end

always @(valid_ab)
begin
    if(bDFTBYP === 1'b0 && bSE === 1'b0) begin
        AAL = {M{1'bx}};
        BWEBL = {N{1'b0}};
        #0.01; 
            bQ = {N{1'bx}};
    end
    else if(bDFTBYP === 1'b0) begin
            bQ = #0.01 {N{1'bx}};
    end
end

always @(valid_ck)
begin
    if (bDFTBYP === 1'b0 && bSE === 1'b0) begin
        AAL = {M{1'bx}};
        BWEBL = {N{1'b0}};
        #0.01
            bQ = {N{1'bx}};
    end
    else if(bDFTBYP === 1'b0) begin     
            bQ = #0.01 {N{1'bx}};
    end
end

always @(valid_d0)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[0] = 1'bx;
      BWEBL[0] = 1'b0;
  end 
   end

always @(valid_bw0)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[0] = 1'bx;
      BWEBL[0] = 1'b0;
  end
   end

always @(valid_d1)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[1] = 1'bx;
      BWEBL[1] = 1'b0;
  end 
   end

always @(valid_bw1)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[1] = 1'bx;
      BWEBL[1] = 1'b0;
  end
   end

always @(valid_d2)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[2] = 1'bx;
      BWEBL[2] = 1'b0;
  end 
   end

always @(valid_bw2)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[2] = 1'bx;
      BWEBL[2] = 1'b0;
  end
   end

always @(valid_d3)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[3] = 1'bx;
      BWEBL[3] = 1'b0;
  end 
   end

always @(valid_bw3)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[3] = 1'bx;
      BWEBL[3] = 1'b0;
  end
   end

always @(valid_d4)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[4] = 1'bx;
      BWEBL[4] = 1'b0;
  end 
   end

always @(valid_bw4)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[4] = 1'bx;
      BWEBL[4] = 1'b0;
  end
   end

always @(valid_d5)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[5] = 1'bx;
      BWEBL[5] = 1'b0;
  end 
   end

always @(valid_bw5)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[5] = 1'bx;
      BWEBL[5] = 1'b0;
  end
   end

always @(valid_d6)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[6] = 1'bx;
      BWEBL[6] = 1'b0;
  end 
   end

always @(valid_bw6)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[6] = 1'bx;
      BWEBL[6] = 1'b0;
  end
   end

always @(valid_d7)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[7] = 1'bx;
      BWEBL[7] = 1'b0;
  end 
   end

always @(valid_bw7)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[7] = 1'bx;
      BWEBL[7] = 1'b0;
  end
   end

always @(valid_d8)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[8] = 1'bx;
      BWEBL[8] = 1'b0;
  end 
   end

always @(valid_bw8)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[8] = 1'bx;
      BWEBL[8] = 1'b0;
  end
   end

always @(valid_d9)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[9] = 1'bx;
      BWEBL[9] = 1'b0;
  end 
   end

always @(valid_bw9)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[9] = 1'bx;
      BWEBL[9] = 1'b0;
  end
   end

always @(valid_d10)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[10] = 1'bx;
      BWEBL[10] = 1'b0;
  end 
   end

always @(valid_bw10)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[10] = 1'bx;
      BWEBL[10] = 1'b0;
  end
   end

always @(valid_d11)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[11] = 1'bx;
      BWEBL[11] = 1'b0;
  end 
   end

always @(valid_bw11)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[11] = 1'bx;
      BWEBL[11] = 1'b0;
  end
   end

always @(valid_d12)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[12] = 1'bx;
      BWEBL[12] = 1'b0;
  end 
   end

always @(valid_bw12)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[12] = 1'bx;
      BWEBL[12] = 1'b0;
  end
   end

always @(valid_d13)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[13] = 1'bx;
      BWEBL[13] = 1'b0;
  end 
   end

always @(valid_bw13)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[13] = 1'bx;
      BWEBL[13] = 1'b0;
  end
   end

always @(valid_d14)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[14] = 1'bx;
      BWEBL[14] = 1'b0;
  end 
   end

always @(valid_bw14)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[14] = 1'bx;
      BWEBL[14] = 1'b0;
  end
   end

always @(valid_d15)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[15] = 1'bx;
      BWEBL[15] = 1'b0;
  end 
   end

always @(valid_bw15)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[15] = 1'bx;
      BWEBL[15] = 1'b0;
  end
   end

always @(valid_d16)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[16] = 1'bx;
      BWEBL[16] = 1'b0;
  end 
   end

always @(valid_bw16)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[16] = 1'bx;
      BWEBL[16] = 1'b0;
  end
   end

always @(valid_d17)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[17] = 1'bx;
      BWEBL[17] = 1'b0;
  end 
   end

always @(valid_bw17)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[17] = 1'bx;
      BWEBL[17] = 1'b0;
  end
   end

always @(valid_d18)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[18] = 1'bx;
      BWEBL[18] = 1'b0;
  end 
   end

always @(valid_bw18)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[18] = 1'bx;
      BWEBL[18] = 1'b0;
  end
   end

always @(valid_d19)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[19] = 1'bx;
      BWEBL[19] = 1'b0;
  end 
   end

always @(valid_bw19)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[19] = 1'bx;
      BWEBL[19] = 1'b0;
  end
   end

always @(valid_d20)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[20] = 1'bx;
      BWEBL[20] = 1'b0;
  end 
   end

always @(valid_bw20)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[20] = 1'bx;
      BWEBL[20] = 1'b0;
  end
   end

always @(valid_d21)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[21] = 1'bx;
      BWEBL[21] = 1'b0;
  end 
   end

always @(valid_bw21)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[21] = 1'bx;
      BWEBL[21] = 1'b0;
  end
   end

always @(valid_d22)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[22] = 1'bx;
      BWEBL[22] = 1'b0;
  end 
   end

always @(valid_bw22)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[22] = 1'bx;
      BWEBL[22] = 1'b0;
  end
   end

always @(valid_d23)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[23] = 1'bx;
      BWEBL[23] = 1'b0;
  end 
   end

always @(valid_bw23)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[23] = 1'bx;
      BWEBL[23] = 1'b0;
  end
   end

always @(valid_d24)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[24] = 1'bx;
      BWEBL[24] = 1'b0;
  end 
   end

always @(valid_bw24)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[24] = 1'bx;
      BWEBL[24] = 1'b0;
  end
   end

always @(valid_d25)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[25] = 1'bx;
      BWEBL[25] = 1'b0;
  end 
   end

always @(valid_bw25)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[25] = 1'bx;
      BWEBL[25] = 1'b0;
  end
   end

always @(valid_d26)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[26] = 1'bx;
      BWEBL[26] = 1'b0;
  end 
   end

always @(valid_bw26)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[26] = 1'bx;
      BWEBL[26] = 1'b0;
  end
   end

always @(valid_d27)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[27] = 1'bx;
      BWEBL[27] = 1'b0;
  end 
   end

always @(valid_bw27)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[27] = 1'bx;
      BWEBL[27] = 1'b0;
  end
   end

always @(valid_d28)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[28] = 1'bx;
      BWEBL[28] = 1'b0;
  end 
   end

always @(valid_bw28)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[28] = 1'bx;
      BWEBL[28] = 1'b0;
  end
   end

always @(valid_d29)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[29] = 1'bx;
      BWEBL[29] = 1'b0;
  end 
   end

always @(valid_bw29)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[29] = 1'bx;
      BWEBL[29] = 1'b0;
  end
   end

always @(valid_d30)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[30] = 1'bx;
      BWEBL[30] = 1'b0;
  end 
   end

always @(valid_bw30)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[30] = 1'bx;
      BWEBL[30] = 1'b0;
  end
   end

always @(valid_d31)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[31] = 1'bx;
      BWEBL[31] = 1'b0;
  end 
   end

always @(valid_bw31)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[31] = 1'bx;
      BWEBL[31] = 1'b0;
  end
   end

always @(valid_d32)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[32] = 1'bx;
      BWEBL[32] = 1'b0;
  end 
   end

always @(valid_bw32)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[32] = 1'bx;
      BWEBL[32] = 1'b0;
  end
   end

always @(valid_d33)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[33] = 1'bx;
      BWEBL[33] = 1'b0;
  end 
   end

always @(valid_bw33)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[33] = 1'bx;
      BWEBL[33] = 1'b0;
  end
   end

always @(valid_d34)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[34] = 1'bx;
      BWEBL[34] = 1'b0;
  end 
   end

always @(valid_bw34)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[34] = 1'bx;
      BWEBL[34] = 1'b0;
  end
   end

always @(valid_d35)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[35] = 1'bx;
      BWEBL[35] = 1'b0;
  end 
   end

always @(valid_bw35)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[35] = 1'bx;
      BWEBL[35] = 1'b0;
  end
   end

always @(valid_d36)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[36] = 1'bx;
      BWEBL[36] = 1'b0;
  end 
   end

always @(valid_bw36)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[36] = 1'bx;
      BWEBL[36] = 1'b0;
  end
   end

always @(valid_d37)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[37] = 1'bx;
      BWEBL[37] = 1'b0;
  end 
   end

always @(valid_bw37)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[37] = 1'bx;
      BWEBL[37] = 1'b0;
  end
   end

always @(valid_d38)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[38] = 1'bx;
      BWEBL[38] = 1'b0;
  end 
   end

always @(valid_bw38)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[38] = 1'bx;
      BWEBL[38] = 1'b0;
  end
   end

always @(valid_d39)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[39] = 1'bx;
      BWEBL[39] = 1'b0;
  end 
   end

always @(valid_bw39)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[39] = 1'bx;
      BWEBL[39] = 1'b0;
  end
   end

always @(valid_d40)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[40] = 1'bx;
      BWEBL[40] = 1'b0;
  end 
   end

always @(valid_bw40)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[40] = 1'bx;
      BWEBL[40] = 1'b0;
  end
   end

always @(valid_d41)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[41] = 1'bx;
      BWEBL[41] = 1'b0;
  end 
   end

always @(valid_bw41)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[41] = 1'bx;
      BWEBL[41] = 1'b0;
  end
   end

always @(valid_d42)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[42] = 1'bx;
      BWEBL[42] = 1'b0;
  end 
   end

always @(valid_bw42)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[42] = 1'bx;
      BWEBL[42] = 1'b0;
  end
   end

always @(valid_d43)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[43] = 1'bx;
      BWEBL[43] = 1'b0;
  end 
   end

always @(valid_bw43)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[43] = 1'bx;
      BWEBL[43] = 1'b0;
  end
   end

always @(valid_d44)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[44] = 1'bx;
      BWEBL[44] = 1'b0;
  end 
   end

always @(valid_bw44)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[44] = 1'bx;
      BWEBL[44] = 1'b0;
  end
   end

always @(valid_d45)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[45] = 1'bx;
      BWEBL[45] = 1'b0;
  end 
   end

always @(valid_bw45)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[45] = 1'bx;
      BWEBL[45] = 1'b0;
  end
   end

always @(valid_d46)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[46] = 1'bx;
      BWEBL[46] = 1'b0;
  end 
   end

always @(valid_bw46)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[46] = 1'bx;
      BWEBL[46] = 1'b0;
  end
   end

always @(valid_d47)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[47] = 1'bx;
      BWEBL[47] = 1'b0;
  end 
   end

always @(valid_bw47)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[47] = 1'bx;
      BWEBL[47] = 1'b0;
  end
   end

always @(valid_d48)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[48] = 1'bx;
      BWEBL[48] = 1'b0;
  end 
   end

always @(valid_bw48)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[48] = 1'bx;
      BWEBL[48] = 1'b0;
  end
   end

always @(valid_d49)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[49] = 1'bx;
      BWEBL[49] = 1'b0;
  end 
   end

always @(valid_bw49)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[49] = 1'bx;
      BWEBL[49] = 1'b0;
  end
   end

always @(valid_d50)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[50] = 1'bx;
      BWEBL[50] = 1'b0;
  end 
   end

always @(valid_bw50)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[50] = 1'bx;
      BWEBL[50] = 1'b0;
  end
   end

always @(valid_d51)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[51] = 1'bx;
      BWEBL[51] = 1'b0;
  end 
   end

always @(valid_bw51)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[51] = 1'bx;
      BWEBL[51] = 1'b0;
  end
   end

always @(valid_d52)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[52] = 1'bx;
      BWEBL[52] = 1'b0;
  end 
   end

always @(valid_bw52)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[52] = 1'bx;
      BWEBL[52] = 1'b0;
  end
   end

always @(valid_d53)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[53] = 1'bx;
      BWEBL[53] = 1'b0;
  end 
   end

always @(valid_bw53)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[53] = 1'bx;
      BWEBL[53] = 1'b0;
  end
   end

always @(valid_d54)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[54] = 1'bx;
      BWEBL[54] = 1'b0;
  end 
   end

always @(valid_bw54)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[54] = 1'bx;
      BWEBL[54] = 1'b0;
  end
   end

always @(valid_d55)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[55] = 1'bx;
      BWEBL[55] = 1'b0;
  end 
   end

always @(valid_bw55)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[55] = 1'bx;
      BWEBL[55] = 1'b0;
  end
   end

always @(valid_d56)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[56] = 1'bx;
      BWEBL[56] = 1'b0;
  end 
   end

always @(valid_bw56)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[56] = 1'bx;
      BWEBL[56] = 1'b0;
  end
   end

always @(valid_d57)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[57] = 1'bx;
      BWEBL[57] = 1'b0;
  end 
   end

always @(valid_bw57)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[57] = 1'bx;
      BWEBL[57] = 1'b0;
  end
   end

always @(valid_d58)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[58] = 1'bx;
      BWEBL[58] = 1'b0;
  end 
   end

always @(valid_bw58)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[58] = 1'bx;
      BWEBL[58] = 1'b0;
  end
   end

always @(valid_d59)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[59] = 1'bx;
      BWEBL[59] = 1'b0;
  end 
   end

always @(valid_bw59)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[59] = 1'bx;
      BWEBL[59] = 1'b0;
  end
   end

always @(valid_d60)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[60] = 1'bx;
      BWEBL[60] = 1'b0;
  end 
   end

always @(valid_bw60)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[60] = 1'bx;
      BWEBL[60] = 1'b0;
  end
   end

always @(valid_d61)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[61] = 1'bx;
      BWEBL[61] = 1'b0;
  end 
   end

always @(valid_bw61)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[61] = 1'bx;
      BWEBL[61] = 1'b0;
  end
   end

always @(valid_d62)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[62] = 1'bx;
      BWEBL[62] = 1'b0;
  end 
   end

always @(valid_bw62)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[62] = 1'bx;
      BWEBL[62] = 1'b0;
  end
   end

always @(valid_d63)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin      
      DL[63] = 1'bx;
      BWEBL[63] = 1'b0;
  end 
   end

always @(valid_bw63)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin    
      DL[63] = 1'bx;
      BWEBL[63] = 1'b0;
  end
   end

 
always @(valid_wea)
   begin
  if(bDFTBYP === 1'b0 && bSE === 1'b0) begin
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
  end
   end
 
always @(valid_reb)
begin
    if(bDFTBYP === 1'b0) begin 
            bQ = #0.01 {N{1'bx}};
    end
end
`endif

always @(valid_testpin) begin
    if(bDFTBYP === 1'b0 && bSE === 1'b0) begin
      AAL <= {M{1'bx}};
      BWEBL <= {N{1'b0}};
      bQ = #0.01 {N{1'bx}};
    end
    else if(bDFTBYP === 1'b0) begin
          bQ = #0.01 {N{1'bx}};
    end     
end


// Task for printing the memory between specified addresses..
task printMemoryFromTo;     
    input [M - 1:0] from;   // memory content are printed, start from this address.
    input [M - 1:0] to;     // memory content are printed, end at this address.
    begin 
        MX.printMemoryFromTo(from, to);
    end 
endtask

// Task for printing entire memory, including normal array and redundancy array.
task printMemory;   
    begin
        MX.printMemory;
    end
endtask

task xMemoryAll;   
    begin
       MX.xMemoryAll;  
    end
endtask

task zeroMemoryAll;   
    begin
       MX.zeroMemoryAll;   
    end
endtask

task oneMemoryAll;   
    begin
       MX.oneMemoryAll;   
    end
endtask

task randomMemoryAll;   
    begin
       MX.randomMemoryAll;   
    end
endtask

// Task for Loading a perdefined set of data from an external file.
task preloadData;   
    input [256*8:1] infile;  // Max 256 character File Name
    begin
        MX.preloadData(infile);  
    end
endtask


`ifdef TSMC_STUCKAT_FAULT
task injectSA;     
    input [M - 1:0] address;
    input [6 - 1:0] index;
    input stuck_at;
    begin 
        MX.injectSA(address, index, stuck_at);
    end 
endtask
`endif

TS6N12FFCLLLVTB1024X64M4W_Int_Array #(1,1,W,N,M,MES_ALL) MX (.D({DL}),.BW({BWEBL}),
         .AW({AAL}),.EN(EN),.RDB(RDB),.AR({ABL}),.Q({QL}));




endmodule

`disable_portfaults
`nosuppress_faults
`endcelldefine

/*
   The module ports are parameterizable vectors.
*/
module TS6N12FFCLLLVTB1024X64M4W_Int_Array (D, BW, AW, EN, RDB, AR, Q);
parameter Nread = 2;   // Number of Read Ports
parameter Nwrite = 2;  // Number of Write Ports
parameter Nword = 2;   // Number of Words
parameter Ndata = 1;   // Number of Data Bits / Word
parameter Naddr = 1;   // Number of Address Bits / Word
parameter MES_ALL = "ON";
parameter dly = 0.000;
// Cannot define inputs/outputs as memories
input  [Ndata*Nwrite-1:0] D;  // Data Word(s)
input  [Ndata*Nwrite-1:0] BW; // Negative Bit Write Enable
input  [Naddr*Nwrite-1:0] AW; // Write Address(es)
input  EN;                    // Positive Write Enable
input  RDB;                   // Read Toggle
input  [Naddr*Nread-1:0] AR;  // Read Address(es)
output [Ndata*Nread-1:0] Q;   // Output Data Word(s)
reg    [Ndata*Nread-1:0] Q;
reg [Ndata-1:0] mem [Nword-1:0];
reg [Ndata-1:0] mem_fault [Nword-1:0];
reg chgmem;            // Toggled when write to mem
reg [Nwrite-1:0] wwe;  // Positive Word Write Enable for each Port
reg we;                // Positive Write Enable for all Ports
integer waddr[Nwrite-1:0]; // Write Address for each Enabled Port
integer address;       // Current address
reg [Naddr-1:0] abuf;  // Address of current port
reg [Ndata-1:0] dbuf;  // Data for current port
reg [Ndata-1:0] bwbuf; // Bit Write enable for current port
reg dup;               // Is the address a duplicate?
integer log;           // Log file descriptor
integer ip, ip2, ip_r, ib, ib_r, iw, iw_r, iwb, i; // Vector indices

// M-by-N core memory
`ifdef TSMC_STUCKAT_FAULT
reg [Ndata - 1:0] mem_sa0[Nword - 1:0];
reg [Ndata - 1:0] mem_sa1[Nword - 1:0];
`endif

initial
   begin
   if (log[0] === 1'bx)
      log = 1;
   chgmem = 1'b0;
   end
   
`ifdef TSMC_STUCKAT_FAULT
initial
begin
    #(0.001);
    for ( i = 0; i < Nword; i = i + 1) begin
        mem_sa0[i] = {Ndata{1'b1}};
        mem_sa1[i] = {Ndata{1'b0}};
    end
end
`endif

always @(D or BW or AW or EN)
   begin: WRITE //{
   if (EN !== 1'b0)
      begin //{ Possible write
      we = 1'b0;
      // Mark any write enabled ports & get write addresses
      for (ip = 0 ; ip < Nwrite ; ip = ip + 1)
         begin //{
         ib = ip * Ndata;
         iw = ib + Ndata;
         while (ib < iw && BW[ib] === 1'b1)
            ib = ib + 1;
         if (ib == iw)
            wwe[ip] = 1'b0;
         else
            begin //{ ip write enabled
            iw = ip * Naddr;
            for (ib = 0 ; ib < Naddr ; ib = ib + 1)
               begin //{
               abuf[ib] = AW[iw+ib];
               if (abuf[ib] !== 1'b0 && abuf[ib] !== 1'b1)
                  ib = Naddr;
               end //}
            if (ib == Naddr)
               begin //{
               if (abuf < Nword)
                  begin //{ Valid address
                  waddr[ip] = abuf;
                  wwe[ip] = 1'b1;
                  if (we == 1'b0)
                     begin
                     chgmem = ~chgmem;
                     we = EN;
                     end
                  end //}
               else
                  begin //{ Out of range address
                  wwe[ip] = 1'b0;
                  if( MES_ALL=="ON" && $realtime != 0)
                       $fdisplay (log,
                             "\nWarning! Int_Array instance, %m:",
                             "\n\t Port %0d", ip,
                             " write address x'%0h'", abuf,
                             " out of range at time %t.", $realtime,
                             "\n\t Port %0d data not written to memory.", ip);
                  end //}
               end //}
            else
               begin //{ unknown write address

               for (ib = 0 ; ib < Ndata ; ib = ib + 1)
                  dbuf[ib] = 1'bx;
               for (iw = 0 ; iw < Nword ; iw = iw + 1)
                  mem[iw] = dbuf;
               chgmem = ~chgmem;
               disable WRITE;
               end //}
            end //} ip write enabled
         end //} for ip
      if (we === 1'b1)
         begin //{ active write enable
         for (ip = 0 ; ip < Nwrite ; ip = ip + 1)
            begin //{
            if (wwe[ip])
               begin //{ write enabled bits of write port ip
               address = waddr[ip];
               dbuf = mem[address];
               iw = ip * Ndata;
               for (ib = 0 ; ib < Ndata ; ib = ib + 1)
                  begin //{
                  iwb = iw + ib;
                  if (BW[iwb] === 1'b0)
                     dbuf[ib] = D[iwb];
                  else if (BW[iwb] !== 1'b1)
                     dbuf[ib] = 1'bx;
                  end //}
               // Check other ports for same address &
               // common write enable bits active
               dup = 0;
               for (ip2 = ip + 1 ; ip2 < Nwrite ; ip2 = ip2 + 1)
                  begin //{
                  if (wwe[ip2] && address == waddr[ip2])
                     begin //{
                     // initialize bwbuf if first dup
                     if (!dup)
                        begin
                        for (ib = 0 ; ib < Ndata ; ib = ib + 1)
                           bwbuf[ib] = BW[iw+ib];
                        dup = 1;
                        end
                     iw = ip2 * Ndata;
                     for (ib = 0 ; ib < Ndata ; ib = ib + 1)
                        begin //{
                        iwb = iw + ib;
                        // New: Always set X if BW X
                        if (BW[iwb] === 1'b0)
                           begin //{
                           if (bwbuf[ib] !== 1'b1)
                              begin
                              if (D[iwb] !== dbuf[ib])
                                 dbuf[ib] = 1'bx;
                              end
                           else
                              begin
                              dbuf[ib] = D[iwb];
                              bwbuf[ib] = 1'b0;
                              end
                           end //}
                        else if (BW[iwb] !== 1'b1)
                           begin
                           dbuf[ib] = 1'bx;
                           bwbuf[ib] = 1'bx;
                           end
                        end //} for each bit
                        wwe[ip2] = 1'b0;
                     end //} Port ip2 address matches port ip
                  end //} for each port beyond ip (ip2=ip+1)
               // Write dbuf to memory
               mem[address] = dbuf;
               end //} wwe[ip] - write port ip enabled
            end //} for each write port ip
         end //} active write enable
      else if (we !== 1'b0)
         begin //{ unknown write enable
         for (ip = 0 ; ip < Nwrite ; ip = ip + 1)
            begin //{
            if (wwe[ip])
               begin //{ write X to enabled bits of write port ip
               address = waddr[ip];
               dbuf = mem[address];
               iw = ip * Ndata;
               for (ib = 0 ; ib < Ndata ; ib = ib + 1)
                  begin //{ 
                 if (BW[iw+ib] !== 1'b1)
                     dbuf[ib] = 1'bx;
                  end //} 
               mem[address] = dbuf;
               if( MES_ALL=="ON" && $realtime != 0)
                    $fdisplay (log,
                          "\nWarning! Int_Array instance, %m:",
                          "\n\t Enable pin unknown at time %t.", $realtime,
                          "\n\t Enabled bits at port %0d", ip,
                          " write address x'%0h' set unknown.", address);
               end //} wwe[ip] - write port ip enabled
            end //} for each write port ip
         end //} unknown write enable
      end //} possible write (EN != 0)
   end //} always @(D or BW or AW or EN)


// Read memory
always @(RDB or AR)
   begin //{
   for (ip_r = 0 ; ip_r < Nread ; ip_r = ip_r + 1)
      begin //{
      iw_r = ip_r * Naddr;
      for (ib_r = 0 ; ib_r < Naddr ; ib_r = ib_r + 1)
         begin
         abuf[ib_r] = AR[iw_r+ib_r];
         if (abuf[ib_r] !== 0 && abuf[ib_r] !== 1)
            ib_r = Naddr;
         end
      iw_r = ip_r * Ndata;
      if (ib_r == Naddr && abuf < Nword)
         begin //{ Read valid address
`ifdef TSMC_INITIALIZE_FAULT
         dbuf = mem[abuf]  ^ mem_fault[abuf];
`else
         `ifdef TSMC_STUCKAT_FAULT
         dbuf = (mem[abuf] & mem_sa0[abuf] | mem_sa1[abuf]);
         `else
         dbuf = mem[abuf];
         `endif
`endif
         for (ib_r = 0 ; ib_r < Ndata ; ib_r = ib_r + 1)
            begin
            if (Q[iw_r+ib_r] == dbuf[ib_r])
                Q[iw_r+ib_r] <= #(dly) dbuf[ib_r];
            else
                begin
                Q[iw_r+ib_r] <= #(dly) dbuf[ib_r];
//                Q[iw_r+ib_r] <= dbuf[ib_r];
                end // else
            end // for
         end //} valid address
      else
         begin //{ Invalid address
         if( MES_ALL=="ON" && $realtime != 0)
               $fwrite (log, "\nWarning! Int_Array instance, %m:",
                       "\n\t Port %0d read address", ip_r);
         if (ib_r > Naddr)
         begin
         if( MES_ALL=="ON" && $realtime != 0)
            $fwrite (log, " unknown");
         end
         else
         begin
         if( MES_ALL=="ON" && $realtime != 0)
            $fwrite (log, " x'%0h' out of range", abuf);
         end
         if( MES_ALL=="ON" && $realtime != 0)
            $fdisplay (log,
                    " at time %t.", $realtime,
                    "\n\t Port %0d outputs set to unknown.", ip_r);
         for (ib_r = 0 ; ib_r < Ndata ; ib_r = ib_r + 1)
            Q[iw_r+ib_r] <= #(dly) 1'bx;
         end //} invalid address
      end //} for each read port ip_r
   end //} always @(chgmem or AR)

// Task for printing the memory between specified addresses..
task printMemoryFromTo;     
    input [Naddr - 1:0] from;   // memory content are printed, start from this address.
    input [Naddr - 1:0] to;     // memory content are printed, end at this address.
    integer i;
    begin 
        $display ("Dumping register file...");
        $display("@    Address, content-----");
        for (i = from; i <= to; i = i + 1) begin
`ifdef TSMC_STUCKAT_FAULT
            $display("@%d, %b", i, (mem[i] & mem_sa0[i]) | mem_sa1[i]);
`else
            $display("@%d, %b", i, mem[i]);
`endif
        end 
    end
endtask

// Task for printing entire memory, including normal array and redundancy array.
task printMemory;   
    integer i;
    begin
        $display ("Dumping register file...");
        $display("@    Address, content-----");
        for (i = 0; i < Nword; i = i + 1) begin
`ifdef TSMC_STUCKAT_FAULT
            $display("@%d, %b", i, (mem[i] & mem_sa0[i]) | mem_sa1[i]);
`else
            $display("@%d, %b", i, mem[i]);
`endif
        end 
    end
endtask

task xMemoryAll;   
    begin
       for (ib = 0 ; ib < Ndata ; ib = ib + 1)
          dbuf[ib] = 1'bx;
       for (iw = 0 ; iw < Nword ; iw = iw + 1)
          mem[iw] = dbuf; 
       if( MES_ALL=="ON" && $realtime != 0) $display("\nInfo : Set Memory Content to all x at %t.>>", $realtime);
    end
endtask

task zeroMemoryAll;   
    begin
       for (ib = 0 ; ib < Ndata ; ib = ib + 1)
          dbuf[ib] = 1'b0;
       for (iw = 0 ; iw < Nword ; iw = iw + 1)
          mem[iw] = dbuf; 
       if( MES_ALL=="ON" && $realtime != 0) $display("\nInfo : Set Memory Content to all 0 at %t.>>", $realtime);
    end
endtask

task oneMemoryAll;   
    begin
       for (ib = 0 ; ib < Ndata ; ib = ib + 1)
          dbuf[ib] = 1'b1;
       for (iw = 0 ; iw < Nword ; iw = iw + 1)
          mem[iw] = dbuf;
       if( MES_ALL=="ON" && $realtime != 0) $display("\nInfo : Set Memory Content to all 1 at %t.>>", $realtime); 
    end
endtask

task randomMemoryAll;   
    begin
       for (ib = 0 ; ib < Ndata ; ib = ib + 1)
          dbuf[ib] = $random;
       for (iw = 0 ; iw < Nword ; iw = iw + 1)
          mem[iw] = dbuf;
       if( MES_ALL=="ON" && $realtime != 0) $display("\nInfo : Set Memory Content to random patterns at %t.>>", $realtime); 
    end
endtask

// Task for Loading a perdefined set of data from an external file.
task preloadData;   
    input [256*8:1] infile;  // Max 256 character File Name
    begin
        $display ("%m: Reading file, %0s, into the register file", infile);
`ifdef TSMC_INITIALIZE_FORMAT_BINARY
        $readmemb (infile, mem, 0, Nword-1);
`else
        $readmemh (infile, mem, 0, Nword-1);
`endif
    end
endtask

`ifdef TSMC_STUCKAT_FAULT
task injectSA;     

    input [Naddr - 1:0] address;
    input [6 - 1:0] index;
    input stuck_at;
    integer sum;
    integer i;
    reg sa1;
    reg sa0;
    begin 
        
            if (stuck_at === 1'b0) begin
                mem_sa0[address][index] = 1'b0;
                mem_sa1[address][index] = 1'b0;
                sum = 0;
                for (i = 0; i < Nword; i = i + 1) begin
                    sa0 = ~mem_sa0[address][i];
                    sa1 = mem_sa1[address][i];
                    sum = sa0 + sa1 + sum;
                end
                $display ("A s-a-0 error injected at address location %d = %b, current SA errors in this address is %d", address, ({Ndata{1'bx}} &
                mem_sa0[address]) | mem_sa1[address], sum);
            end 
            else if (stuck_at === 1'b1) begin
                mem_sa1[address][index] = 1'b1;
                mem_sa0[address][index] = 1'b1;
                sum = 0;
                for (i = 0; i < Nword; i = i + 1) begin
                    sa0 = ~mem_sa0[address][i];
                    sa1 = mem_sa1[address][i];
                    sum = sa0 + sa1 + sum;
                end
                $display ("A s-a-1 error injected at address location %d = %b, current SA errors in this address is %d", address, ({Ndata{1'bx}} &
                mem_sa0[address]) | mem_sa1[address], sum);
            end
        
    end 
endtask
`endif

endmodule


