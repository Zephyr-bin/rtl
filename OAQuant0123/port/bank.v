// **************************************************************
//Company : 
//
// File name :bank.v
// Module name : bank
// Full name : bank
//
// Author : Heng Zhang
// Email : 652022230022@smail.nju.edu.cn
// Data : 20231224
// Version : V 1.0
//
//Abstract :
// Called by : sram.v
//
// Modification history
// ------------------------------------------------------------------------------------------------------
//
`timescale 1ns/1ps

module bank(
	clk    ,
	rst_n  ,
    //INPUT
	bce_i    ,
	bwren_i  ,
	bwmod_i  ,
	bwaddr_i ,
	bwdata_i ,
	brmod_i  ,
	braddr_i ,
    //OUTPUT
	brdata_r ,
	brvalid_r
    );//1K*64bit*4

// ******************************
// DEFINE INPUT
// ******************************
input         clk      ;//clock signal
input         rst_n    ;//reset,active low
input         bce_i    ;//bank_enable
input [1:0]   bwren_i  ;//bank_write_read_enable
input [2:0]   bwmod_i  ;//bank_write_mode:3'b000(8bit) //3'b001(16bit)//3'b010(32bit)//3'b011(64bit)//3'b100(128bit)//3'b101(256bit) 
input [14:0]  bwaddr_i ;//bank_write_address  -32K
input [255:0] bwdata_i ;//bank_write_data
input [2:0]   brmod_i  ;//bank_read_mode:3'b000(8bit) //3'b001(16bit)//3'b010(32bit)//3'b011(64bit)//3'b100(128bit)//3'b101(256bit) 
input [14:0]  braddr_i ;//bank_read_address  -32K

// ******************************
// DEFINE OUTPUT
// ******************************
output reg [255:0] brdata_r ;//bank_read_data
output reg         brvalid_r;//bank_read_valid

// ******************************
// OUTPUT ATRRIBUTE //
// ******************************
// REGS
reg        ce_wen1  ;  //memory write enable(for first IP)
reg        ce_wen2  ;  //memory write enable(for second IP)
reg        ce_wen3  ;  //memory write enable(for third IP)
reg        ce_wen4  ;  //memory write enable(for forth IP)
reg        ce_ren   ;  //memory read enable(for all four IP)
reg [9:0]  waddr    ;  //write address(for all four IP)   -4K per IP
reg [63:0] wdata1   ;  //write data(for first IP)
reg [63:0] wdata2   ;  //write data(for second IP)
reg [63:0] wdata3   ;  //write data(for third IP)
reg [63:0] wdata4   ;  //write data(for forth IP)
reg [63:0] wbitmask1;  //write bitmask(for first IP)
reg [63:0] wbitmask2;  //write bitmask(for second IP)
reg [63:0] wbitmask3;  //write bitmask(for third IP)
reg [63:0] wbitmask4;  //write bitmask(for forth IP)
reg [9:0]  raddr    ;  //read address(for all four IP)   -4K per IP

//these regs are needed because:read valid is got 3 periods after bce/bren 
reg        bce_r1;
reg        bce_r2_1_copy;
reg        bce_r2_2_copy;
reg        bce_r2_3_copy;
reg        bce_r2_4_copy;
reg        bce_r2_5_copy;


reg        bren_r1; 
reg        bren_r2_1_copy;
reg        bren_r2_2_copy;
reg        bren_r2_3_copy;
reg        bren_r2_4_copy;
reg        bren_r2_5_copy;



reg [2:0]  brmod_r1;
reg [2:0]  brmod_r2_1_copy;
reg [2:0]  brmod_r2_2_copy;
reg [2:0]  brmod_r2_3_copy;
reg [2:0]  brmod_r2_4_copy;
reg [2:0]  brmod_r2_5_copy;

reg [14:0] braddr_r1;
reg [14:0] braddr_r2_1_copy;
reg [14:0] braddr_r2_2_copy;
reg [14:0] braddr_r2_3_copy;
reg [14:0] braddr_r2_4_copy;
reg [14:0] braddr_r2_5_copy;

reg     [255:0]       brdata_r1;
reg     [255:0]       brdata_r2;
reg     [255:0]       brdata_r3;
reg     [255:0]       brdata_r4;
reg     [255:0]       brdata_r5;

//WIRES
wire [63:0] rdata1;  //read data(for first IP)
wire [63:0] rdata2;  //read data(for second IP)
wire [63:0] rdata3;  //read data(for third IP)
wire [63:0] rdata4;  //read data(for forth IP)

// ******************************
//MAIN CODE //
// ******************************

//wire   bwen;//input write enable
wire   bwen_1_copy;//input write enable
wire   bwen_2_copy;//input write enable
wire   bwen_3_copy;//input write enable
wire   bwen_4_copy;//input write enable
wire   bwen_5_copy;//input write enable
wire   bwen_6_copy;//input write enable
wire   bwen_7_copy;//input write enable
wire   bwen_8_copy;//input write enable
wire   bwen_9_copy;//input write enable


wire   bren;//input read enable


wire   bce_1_copy;
wire   bce_2_copy;
wire   bce_3_copy;
wire   bce_4_copy;
wire   bce_5_copy;
wire   bce_6_copy;
wire   bce_7_copy;
wire   bce_8_copy;
wire   bce_9_copy;
wire   bce_10_copy;

wire  [2:0]     bwmod_1_copy;
wire  [2:0]     bwmod_2_copy;
wire  [2:0]     bwmod_3_copy;
wire  [2:0]     bwmod_4_copy;
wire  [2:0]     bwmod_5_copy;
wire  [2:0]     bwmod_6_copy;
wire  [2:0]     bwmod_7_copy;
wire  [2:0]     bwmod_8_copy;
wire  [2:0]     bwmod_9_copy;


wire  [14:0]   bwaddr_1_copy;
wire  [14:0]   bwaddr_2_copy;
wire  [14:0]   bwaddr_3_copy;
wire  [14:0]   bwaddr_4_copy;
wire  [14:0]   bwaddr_5_copy;
wire  [14:0]   bwaddr_6_copy;
wire  [14:0]   bwaddr_7_copy;
wire  [14:0]   bwaddr_8_copy;
wire  [14:0]   bwaddr_9_copy;
wire  [14:0]   bwaddr_10_copy;
wire  [14:0]   bwaddr_11_copy;


reg [63:0]    wbitmask1_1;
reg [63:0]    wbitmask1_2;
reg [63:0]    wbitmask2_1;
reg [63:0]    wbitmask2_2;
reg [63:0]    wbitmask3_1;
reg [63:0]    wbitmask3_2;
reg [63:0]    wbitmask4_1;
reg [63:0]    wbitmask4_2;


//assign bwen = bwren_i[1];
assign bwen_1_copy = bwren_i[1];
assign bwen_2_copy = bwren_i[1];
assign bwen_3_copy = bwren_i[1];
assign bwen_4_copy = bwren_i[1];
assign bwen_5_copy = bwren_i[1];
assign bwen_6_copy = bwren_i[1];
assign bwen_7_copy = bwren_i[1];
assign bwen_8_copy = bwren_i[1];
assign bwen_9_copy = bwren_i[1];

assign bce_1_copy = bce_i;
assign bce_2_copy = bce_i;
assign bce_3_copy = bce_i;
assign bce_4_copy = bce_i;
assign bce_5_copy = bce_i;
assign bce_6_copy = bce_i;
assign bce_7_copy = bce_i;
assign bce_8_copy = bce_i;
assign bce_9_copy = bce_i;
assign bce_10_copy = bce_i;

assign bwmod_1_copy = bwmod_i;
assign bwmod_2_copy = bwmod_i;
assign bwmod_3_copy = bwmod_i;
assign bwmod_4_copy = bwmod_i;
assign bwmod_5_copy = bwmod_i;
assign bwmod_6_copy = bwmod_i;
assign bwmod_7_copy = bwmod_i;
assign bwmod_8_copy = bwmod_i;
assign bwmod_9_copy = bwmod_i;

assign bwaddr_1_copy = bwaddr_i;
assign bwaddr_2_copy = bwaddr_i;
assign bwaddr_3_copy = bwaddr_i;
assign bwaddr_4_copy = bwaddr_i;
assign bwaddr_5_copy = bwaddr_i;
assign bwaddr_6_copy = bwaddr_i;
assign bwaddr_7_copy = bwaddr_i;
assign bwaddr_8_copy = bwaddr_i;
assign bwaddr_9_copy = bwaddr_i;
assign bwaddr_10_copy = bwaddr_i;
assign bwaddr_11_copy = bwaddr_i;

assign bren = bwren_i[0];

//****** bank write ctrl ******//
//[14:0] bwaddr_i:[14:5]->write address for IP  [4:0]->IP_select and bitmask
//ce_wen: 1.256bit_mode->four IP all needed  2.not 256bit_mode->select by bwaddr_i
//ce_wen1  
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        ce_wen1 <= 1'b0;
    else if (bce_1_copy && bwen_1_copy && (bwaddr_1_copy[4:3]==2'b00|| bwmod_1_copy==3'b101))
        ce_wen1 <= 1'b1;
    else 
        ce_wen1 <= 1'b0;
end
//ce_wen2
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        ce_wen2 <= 1'b0;
    else if (bce_1_copy && bwen_1_copy && (bwaddr_1_copy[4:3]==2'b01|| (bwaddr_1_copy[4:3]==2'b00 && bwmod_1_copy==3'b100)|| bwmod_1_copy==3'b101))
        ce_wen2 <= 1'b1;
    else
        ce_wen2 <= 1'b0;
end
//ce_wen3
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        ce_wen3 <= 1'b0;
    else if (bce_1_copy && bwen_1_copy && (bwaddr_2_copy[4:3]==2'b10|| bwmod_1_copy==3'b101))
        ce_wen3 <= 1'b1;
    else
        ce_wen3 <= 1'b0;
end
//ce_wen4
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        ce_wen4 <= 1'b0;
    else if (bce_1_copy && bwen_1_copy && (bwaddr_2_copy[4:3]==2'b11|| (bwaddr_2_copy[4:3]==2'b10 && bwmod_1_copy==3'b100)|| bwmod_1_copy==3'b101))
        ce_wen4 <= 1'b1;
    else
        ce_wen4 <= 1'b0;
end
//waddr
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        waddr <= 10'b0;
    else if ( bce_1_copy && bwen_1_copy )
        waddr <= bwaddr_3_copy[14:5];//write address to IP,depth:1K
//    else
//        waddr <= waddr;
end
//wdata1
//devided from [255:0] bwdata_i  selected by bitmask(bwaddr_i[2:0])
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n)
    begin
        wdata1 <=  64'b0;
    end

    else if ( bce_2_copy && bwen_2_copy && bwmod_2_copy == 3'b000 )  	//write by 8bits
    begin
        case (bwaddr_4_copy[2:0])//bitmask for 8bits
            3'b000:   wdata1[7:0]     <=  bwdata_i[7:0];
            3'b001:   wdata1[15:8]    <=  bwdata_i[7:0];
            3'b010:   wdata1[23:16]   <=  bwdata_i[7:0];
            3'b011:   wdata1[31:24]   <=  bwdata_i[7:0];
            3'b100:   wdata1[39:32]   <=  bwdata_i[7:0];
            3'b101:   wdata1[47:40]   <=  bwdata_i[7:0];
            3'b110:   wdata1[55:48]   <=  bwdata_i[7:0];
            3'b111:   wdata1[63:56]   <=  bwdata_i[7:0];
            default:  wdata1 <=   64'b0;  
        endcase
    end

    else if ( bce_2_copy && bwen_2_copy && bwmod_2_copy == 3'b001 )  	//write by 16bits
    begin
        case (bwaddr_4_copy[2:0])//bitmask for 16bits
            3'b000:   wdata1[15:0]    <=  bwdata_i[15:0];
            3'b010:   wdata1[31:16]   <=  bwdata_i[15:0];
            3'b100:   wdata1[47:32]   <=  bwdata_i[15:0];
            3'b110:   wdata1[63:48]   <=  bwdata_i[15:0];
            default:  wdata1 <=   64'b0;  
        endcase
    end

    else if (bce_2_copy && bwen_2_copy && bwmod_2_copy == 3'b010 )  //write by 32bits
    begin
         if (bwaddr_4_copy[2:0]==3'b000)//bitmask for 32bit
             wdata1[31:0]   <=  bwdata_i[31:0];
         else if (bwaddr_4_copy[2:0]==3'b100)
             wdata1[63:32]  <=  bwdata_i[31:0];
         else
             wdata1 <=  64'b0;
    end 

    else if (bce_2_copy && bwen_2_copy && ((bwmod_2_copy==3'b011) | (bwmod_2_copy==3'b100) | (bwmod_2_copy == 3'b101)))  	//write by 64bits
    begin
        wdata1[63:0] <=  bwdata_i[63:0];
    end
    //else if (bce_2_copy && bwen && bwmod_2_copy==3'b100 )  		//write by 128bits
        //wdata1[63:0] <=  bwdata_i[63:0];
    //else if (bce_2_copy && bwen && bwmod_2_copy == 3'b101)  		//write by 256bits
        //wdata1[63:0] <=  bwdata_i[63:0];
//    else
//        wdata1 <= wdata1;
end










//wdata2
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        wdata2 <=  64'b0;
    else if ( bce_3_copy && bwen_3_copy && bwmod_3_copy == 3'b000 )  	//write by 8bits
        case (bwaddr_5_copy[2:0])//bitmask for 8bits
            3'b000:   wdata2[7:0]     <=  bwdata_i[7:0];
            3'b001:   wdata2[15:8]    <=  bwdata_i[7:0];
            3'b010:   wdata2[23:16]   <=  bwdata_i[7:0];
            3'b011:   wdata2[31:24]   <=  bwdata_i[7:0];
            3'b100:   wdata2[39:32]   <=  bwdata_i[7:0];
            3'b101:   wdata2[47:40]   <=  bwdata_i[7:0];
            3'b110:   wdata2[55:48]   <=  bwdata_i[7:0];
            3'b111:   wdata2[63:56]   <=  bwdata_i[7:0];
            default:  wdata2 <=   64'b0;  
        endcase
    else if ( bce_3_copy && bwen_3_copy && bwmod_3_copy == 3'b001 )  	//write by 16bits
        case (bwaddr_5_copy[2:0])//bitmask for 16bits
            3'b000:   wdata2[15:0]    <=  bwdata_i[15:0];
            3'b010:   wdata2[31:16]   <=  bwdata_i[15:0];
            3'b100:   wdata2[47:32]   <=  bwdata_i[15:0];
            3'b110:   wdata2[63:48]   <=  bwdata_i[15:0];
            default:  wdata2 <=   64'b0;  
        endcase
    else if (bce_3_copy && bwen_3_copy && bwmod_3_copy == 3'b010 ) begin //write by 32bits
        if (bwaddr_5_copy[2:0]==3'b000)//bitmask for 32bits
            wdata2[31:0]   <=  bwdata_i[31:0];
        else if (bwaddr_5_copy[2:0]==3'b100)
            wdata2[63:32]  <=  bwdata_i[31:0];
        else
            wdata2 <=  64'b0;
    end 
    else if (bce_3_copy && bwen_3_copy && bwmod_3_copy==3'b011 ) 	//write by 64bits
        wdata2[63:0] <=  bwdata_i[63:0];
    else if (bce_3_copy && bwen_3_copy && bwmod_3_copy==3'b100 )  		//write by 128bits
        wdata2[63:0] <=  bwdata_i[127:64];
    else if (bce_3_copy && bwen_3_copy && bwmod_3_copy == 3'b101)  		//write by 256bits
        wdata2[63:0] <=  bwdata_i[127:64];
//    else
//        wdata2 <= wdata2;
end
//wdata3
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        wdata3 <=  64'b0;
    else if ( bce_4_copy && bwen_4_copy && bwmod_4_copy == 3'b000 )  	//write by 8bits
        case (bwaddr_6_copy[2:0])//bitmask for 8bits
            3'b000:   wdata3[7:0]     <=  bwdata_i[7:0];
            3'b001:   wdata3[15:8]    <=  bwdata_i[7:0];
            3'b010:   wdata3[23:16]   <=  bwdata_i[7:0];
            3'b011:   wdata3[31:24]   <=  bwdata_i[7:0];
            3'b100:   wdata3[39:32]   <=  bwdata_i[7:0];
            3'b101:   wdata3[47:40]   <=  bwdata_i[7:0];
            3'b110:   wdata3[55:48]   <=  bwdata_i[7:0];
            3'b111:   wdata3[63:56]   <=  bwdata_i[7:0];
            default:  wdata3 <=   64'b0;  
        endcase
    else if ( bce_4_copy && bwen_4_copy && bwmod_4_copy == 3'b001 )  	//write by 16bits
        case (bwaddr_6_copy[2:0])//bitmask for 16bits
            3'b000:   wdata3[15:0]    <=  bwdata_i[15:0];
            3'b010:   wdata3[31:16]   <=  bwdata_i[15:0];
            3'b100:   wdata3[47:32]   <=  bwdata_i[15:0];
            3'b110:   wdata3[63:48]   <=  bwdata_i[15:0];
            default:  wdata3 <=   64'b0;  
        endcase
    else if (bce_4_copy && bwen_4_copy && bwmod_4_copy == 3'b010 ) begin //write by 32bits
        if (bwaddr_6_copy[2:0]==3'b000)//bitmask for 32bits
            wdata3[31:0]   <=  bwdata_i[31:0];
        else if (bwaddr_6_copy[2:0]==3'b100)
            wdata3[63:32]  <=  bwdata_i[31:0];
        else
            wdata3 <=  64'b0;
    end 
    else if (bce_4_copy && bwen_4_copy && bwmod_4_copy==3'b011 )  	//write by 64bits
        wdata3[63:0] <=  bwdata_i[63:0];
    else if (bce_4_copy && bwen_4_copy && bwmod_4_copy==3'b100 )  		//write by 128bits
        wdata3[63:0] <=  bwdata_i[63:0];
    else if (bce_4_copy && bwen_4_copy && bwmod_4_copy == 3'b101)  		//write by 256bits
        wdata3[63:0] <=  bwdata_i[191:128];
//    else
//        wdata3 <= wdata3;
end
//wdata4
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        wdata4 <=  64'b0;
    else if ( bce_5_copy && bwen_5_copy && bwmod_5_copy == 3'b000 )  	//write by 8bits
        case (bwaddr_7_copy[2:0])//bitmask for 8bits
            3'b000:   wdata4[7:0]     <=  bwdata_i[7:0];
            3'b001:   wdata4[15:8]    <=  bwdata_i[7:0];
            3'b010:   wdata4[23:16]   <=  bwdata_i[7:0];
            3'b011:   wdata4[31:24]   <=  bwdata_i[7:0];
            3'b100:   wdata4[39:32]   <=  bwdata_i[7:0];
            3'b101:   wdata4[47:40]   <=  bwdata_i[7:0];
            3'b110:   wdata4[55:48]   <=  bwdata_i[7:0];
            3'b111:   wdata4[63:56]   <=  bwdata_i[7:0];
            default:  wdata4 <=   64'b0;  
        endcase
    else if ( bce_5_copy && bwen_5_copy && bwmod_5_copy == 3'b001 )  	//write by 16bits
        case (bwaddr_7_copy[2:0])//bitmask for 16bits
            3'b000:   wdata4[15:0]    <=  bwdata_i[15:0];
            3'b010:   wdata4[31:16]   <=  bwdata_i[15:0];
            3'b100:   wdata4[47:32]   <=  bwdata_i[15:0];
            3'b110:   wdata4[63:48]   <=  bwdata_i[15:0];
            default:  wdata4 <=   64'b0;  
        endcase
    else if (bce_5_copy && bwen_5_copy && bwmod_5_copy == 3'b010 ) begin	//write by 32bits
        if (bwaddr_7_copy[2:0]==3'b000)//bitmask for 32bits
            wdata4[31:0]   <=  bwdata_i[31:0];
        else if (bwaddr_7_copy[2:0]==3'b100)
            wdata4[63:32]  <=  bwdata_i[31:0];
        else
            wdata4 <=  64'b0;
    end 
    else if (bce_5_copy && bwen_5_copy && bwmod_5_copy==3'b011 )  	//write by 64bits
        wdata4[63:0] <=  bwdata_i[63:0];
    else if (bce_5_copy && bwen_5_copy && bwmod_5_copy==3'b100 )  		//write by 128bits
        wdata4[63:0] <=  bwdata_i[127:64];
    else if (bce_5_copy && bwen_5_copy && bwmod_5_copy == 3'b101)  		//write by 256bits
        wdata4[63:0] <=  bwdata_i[255:192];
//    else
//        wdata4 <= wdata4;
end






//wbitmask1(write bitmask to first IP)
//desided by bwaddr_i[2:0]
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        wbitmask1 <= 64'b0;
    else if (bce_6_copy && bwen_6_copy && bwmod_6_copy == 3'b000)  		//write by 8bits
    begin
        wbitmask1 <= wbitmask1_1;
    end

    else if (bce_6_copy && bwen_6_copy && bwmod_6_copy == 3'b001)  		//write by 16bits
    begin
        wbitmask1 <= wbitmask1_2;
    end

    else if (bce_6_copy && bwen_6_copy && bwmod_6_copy == 3'b010)   //write by 32bits
    begin
        if (bwaddr_8_copy[2:0]==3'b000)//write 32bits-> 32/4=8 ->8 positions 0
            wbitmask1 <=  64'hFFFF_FFFF_0000_0000;
        else if (bwaddr_8_copy[2:0]==3'b100)
            wbitmask1 <=  64'h0000_0000_FFFF_FFFF;
        else
            wbitmask1 <=  64'hFFFF_FFFF_FFFF_FFFF;
    end 

    else if (bce_6_copy && bwen_6_copy && (bwmod_6_copy[2]==1 || bwmod_6_copy==3'b011))  //write by 64bits/128bit/256bits
        wbitmask1 <=  64'h0000_0000_0000_0000;//write >= 64bits-> all positions 0
//    else
//        wbitmask1<=wbitmask1;
end


always @(*) 
begin
    case (bwaddr_8_copy[2:0])//write 8bits-> 8/4=2 ->2 positions 0
        3'b000:    wbitmask1_1   <=  64'hFFFF_FFFF_FFFF_FF00;//0 position:write    F position:not write
        3'b001:    wbitmask1_1   <=  64'hFFFF_FFFF_FFFF_00FF;
        3'b010:    wbitmask1_1   <=  64'hFFFF_FFFF_FF00_FFFF;
        3'b011:    wbitmask1_1   <=  64'hFFFF_FFFF_00FF_FFFF;
        3'b100:    wbitmask1_1   <=  64'hFFFF_FF00_FFFF_FFFF;
	3'b101:    wbitmask1_1   <=  64'hFFFF_00FF_FFFF_FFFF;
	3'b110:    wbitmask1_1   <=  64'hFF00_FFFF_FFFF_FFFF;
	3'b111:    wbitmask1_1   <=  64'h00FF_FFFF_FFFF_FFFF;
	default:   wbitmask1_1   <=  64'hFFFF_FFFF_FFFF_FFFF;
    endcase
end


always @(*) 
begin
    case (bwaddr_8_copy[2:0])//write 16bits-> 16/4=4 ->4 positions 0
        3'b000:    wbitmask1_2   <=  64'hFFFF_FFFF_FFFF_0000;
        3'b010:    wbitmask1_2   <=  64'hFFFF_FFFF_0000_FFFF;
        3'b100:    wbitmask1_2   <=  64'hFFFF_0000_FFFF_FFFF;
        3'b110:    wbitmask1_2   <=  64'h0000_FFFF_FFFF_FFFF;
        default:   wbitmask1_2   <=  64'hFFFF_FFFF_FFFF_FFFF;
    endcase
end



//wbitmask2
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
    begin
        wbitmask2 <= 64'b0;
    end

    else if (bce_7_copy && bwen_7_copy && bwmod_7_copy == 3'b000)  		//write by 8bits
    begin
        wbitmask2   <=  wbitmask2_1;
    end

    else if (bce_7_copy && bwen_7_copy && bwmod_7_copy == 3'b001)  		//write by 16bits
    begin
        wbitmask2   <=  wbitmask2_2;
    end

    else if (bce_7_copy && bwen_7_copy && bwmod_7_copy == 3'b010)   //write by 32bits
    begin
        if (bwaddr_9_copy[2:0]==3'b000)//write 32bits-> 32/4=8 ->8 positions 0
            wbitmask2 <=  64'hFFFF_FFFF_0000_0000;
        else if (bwaddr_9_copy[2:0]==3'b100)
            wbitmask2 <=  64'h0000_0000_FFFF_FFFF;
        else
            wbitmask2 <=  64'hFFFF_FFFF_FFFF_FFFF;
    end 

    else if (bce_7_copy && bwen_7_copy && (bwmod_7_copy[2]==1 || bwmod_7_copy==3'b011))  //write by 64bits/128bit/256bits
        wbitmask2 <=  64'h0000_0000_0000_0000;//write >= 64bits-> all positions 0
//    else
//        wbitmask2<=wbitmask2;
end



always @(*) 
begin
    case (bwaddr_9_copy[2:0])//write 8bits-> 8/4('h)=2 ->2 positions 0
        3'b000:    wbitmask2_1   <=  64'hFFFF_FFFF_FFFF_FF00;
        3'b001:    wbitmask2_1   <=  64'hFFFF_FFFF_FFFF_00FF;
        3'b010:    wbitmask2_1   <=  64'hFFFF_FFFF_FF00_FFFF;
        3'b011:    wbitmask2_1   <=  64'hFFFF_FFFF_00FF_FFFF;
        3'b100:    wbitmask2_1   <=  64'hFFFF_FF00_FFFF_FFFF;
	3'b101:    wbitmask2_1   <=  64'hFFFF_00FF_FFFF_FFFF;
	3'b110:    wbitmask2_1   <=  64'hFF00_FFFF_FFFF_FFFF;
	3'b111:    wbitmask2_1   <=  64'h00FF_FFFF_FFFF_FFFF;
	default:   wbitmask2_1   <=  64'hFFFF_FFFF_FFFF_FFFF;
    endcase
end


always @(*) 
begin
    case (bwaddr_9_copy[2:0])//write 16bits-> 16/4=4 ->4 positions 0
        3'b000:    wbitmask2_2   <=  64'hFFFF_FFFF_FFFF_0000;
        3'b010:    wbitmask2_2   <=  64'hFFFF_FFFF_0000_FFFF;
        3'b100:    wbitmask2_2   <=  64'hFFFF_0000_FFFF_FFFF;
        3'b110:    wbitmask2_2   <=  64'h0000_FFFF_FFFF_FFFF;
        default:   wbitmask2_2   <=  64'hFFFF_FFFF_FFFF_FFFF;
    endcase
end


//wbitmask3
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
    begin
        wbitmask3 <= 64'b0;
    end

    else if (bce_8_copy && bwen_8_copy && bwmod_8_copy == 3'b000)  		//write by 8bits
    begin
        wbitmask3 <= wbitmask3_1;
    end

    else if (bce_8_copy && bwen_8_copy && bwmod_8_copy == 3'b001)  		//write by 16bits
    begin
        wbitmask3 <= wbitmask3_2;
    end

    else if (bce_8_copy && bwen_8_copy && bwmod_8_copy == 3'b010)   //write by 32bits
    begin
        if (bwaddr_10_copy[2:0]==3'b000)//write 32bits-> 32/4=8 ->8 positions 0
            wbitmask3 <=  64'hFFFF_FFFF_0000_0000;
        else if (bwaddr_10_copy[2:0]==3'b100)
            wbitmask3 <=  64'h0000_0000_FFFF_FFFF;
        else
            wbitmask3 <=  64'hFFFF_FFFF_FFFF_FFFF;
    end 

    else if (bce_8_copy && bwen_8_copy && (bwmod_8_copy[2]==1 || bwmod_8_copy==3'b011))  //write by 64bits/128bit/256bits
        wbitmask3 <=  64'h0000_0000_0000_0000;//write >= 64bits   ->  all positions 0
//    else
//        wbitmask3<=wbitmask3;
end


always @(*) 
begin
    case (bwaddr_10_copy[2:0])//write 8bits-> 8/4=2 ->2 positions 0
        3'b000:    wbitmask3_1   <=  64'hFFFF_FFFF_FFFF_FF00;
        3'b001:    wbitmask3_1   <=  64'hFFFF_FFFF_FFFF_00FF;
        3'b010:    wbitmask3_1   <=  64'hFFFF_FFFF_FF00_FFFF;
        3'b011:    wbitmask3_1   <=  64'hFFFF_FFFF_00FF_FFFF;
        3'b100:    wbitmask3_1   <=  64'hFFFF_FF00_FFFF_FFFF;
	3'b101:    wbitmask3_1   <=  64'hFFFF_00FF_FFFF_FFFF;
	3'b110:    wbitmask3_1   <=  64'hFF00_FFFF_FFFF_FFFF;
	3'b111:    wbitmask3_1   <=  64'h00FF_FFFF_FFFF_FFFF;
	default:   wbitmask3_1   <=  64'hFFFF_FFFF_FFFF_FFFF;
    endcase
end


always @(*) 
begin
    case (bwaddr_10_copy[2:0])//write 16bits-> 16/4=4 ->4 positions 0
        3'b000:    wbitmask3_2   <=  64'hFFFF_FFFF_FFFF_0000;
        3'b010:    wbitmask3_2   <=  64'hFFFF_FFFF_0000_FFFF;
        3'b100:    wbitmask3_2   <=  64'hFFFF_0000_FFFF_FFFF;
        3'b110:    wbitmask3_2   <=  64'h0000_FFFF_FFFF_FFFF;
        default:   wbitmask3_2   <=  64'hFFFF_FFFF_FFFF_FFFF;
    endcase
end


//wbitmask4
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
    begin
        wbitmask4 <= 64'b0;
    end

    else if (bce_9_copy && bwen_9_copy && bwmod_9_copy == 3'b000)  		//write by 8bits
    begin
        wbitmask4 <=  wbitmask4_1;
    end

    else if (bce_9_copy && bwen_9_copy && bwmod_9_copy == 3'b001)  		//write by 16bits
    begin
        wbitmask4 <=  wbitmask4_2;
    end

    else if (bce_9_copy && bwen_9_copy && bwmod_9_copy == 3'b010)   //write by 32bits
    begin
        if (bwaddr_11_copy[2:0]==3'b000)//write 32bits-> 32/4=8 ->8 positions 0
            wbitmask4 <=  64'hFFFF_FFFF_0000_0000;
        else if (bwaddr_11_copy[2:0]==3'b100)
            wbitmask4 <=  64'h0000_0000_FFFF_FFFF;
        else
            wbitmask4 <=  64'hFFFF_FFFF_FFFF_FFFF;
    end 

    else if (bce_9_copy && bwen_9_copy && (bwmod_9_copy[2]==1 || bwmod_9_copy==3'b011))  //write by 64bits/128bit/256bits
    begin
        wbitmask4 <=  64'h0000_0000_0000_0000;//write >= 64bits-> all positions 0
    end
//    else
//        wbitmask4<=wbitmask4;
end


always @(*) 
begin
    case (bwaddr_11_copy[2:0])//write 8bits-> 8/4=2 ->2 positions 0
        3'b000:    wbitmask4_1   <=  64'hFFFF_FFFF_FFFF_FF00;
        3'b001:    wbitmask4_1   <=  64'hFFFF_FFFF_FFFF_00FF;
        3'b010:    wbitmask4_1   <=  64'hFFFF_FFFF_FF00_FFFF;
        3'b011:    wbitmask4_1   <=  64'hFFFF_FFFF_00FF_FFFF;
        3'b100:    wbitmask4_1   <=  64'hFFFF_FF00_FFFF_FFFF;
        3'b101:    wbitmask4_1   <=  64'hFFFF_00FF_FFFF_FFFF;
        3'b110:    wbitmask4_1   <=  64'hFF00_FFFF_FFFF_FFFF;
        3'b111:    wbitmask4_1   <=  64'h00FF_FFFF_FFFF_FFFF;
        default:   wbitmask4_1   <=  64'hFFFF_FFFF_FFFF_FFFF;
    endcase
end


always @(*) 
begin
    case (bwaddr_11_copy[2:0])//write 16bits-> 16/4=4 ->4 positions 0
        3'b000:    wbitmask4_2   <=  64'hFFFF_FFFF_FFFF_0000;
        3'b010:    wbitmask4_2   <=  64'hFFFF_FFFF_0000_FFFF;
        3'b100:    wbitmask4_2   <=  64'hFFFF_0000_FFFF_FFFF;
        3'b110:    wbitmask4_2   <=  64'h0000_FFFF_FFFF_FFFF;
        default:   wbitmask4_2   <=  64'hFFFF_FFFF_FFFF_FFFF;
    endcase
end


//***bank read ctrl ******//
//bce_r1,r2
always @(posedge clk or negedge rst_n) 
begin
    if(!rst_n) 
    begin
        bce_r1 <= 1'b0;
        bce_r2_1_copy <= 1'b0;
        bce_r2_2_copy <= 1'b0;
        bce_r2_3_copy <= 1'b0;
        bce_r2_4_copy <= 1'b0;
        bce_r2_5_copy <= 1'b0;
    end 
    
    else begin
        bce_r1 <= bce_i;
        bce_r2_1_copy <= bce_r1;
        bce_r2_2_copy <= bce_r1;
        bce_r2_3_copy <= bce_r1;
        bce_r2_4_copy <= bce_r1;
        bce_r2_5_copy <= bce_r1;
    end
end

//bren_r1,r2
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) 
    begin
        bren_r1 <= 1'b0;
        bren_r2_1_copy <= 1'b0;
        bren_r2_2_copy <= 1'b0;
        bren_r2_3_copy <= 1'b0;
        bren_r2_4_copy <= 1'b0;
        bren_r2_5_copy <= 1'b0;
    end 

    else 
    begin
        bren_r1 <= bren;
        bren_r2_1_copy <= bren_r1;
        bren_r2_2_copy <= bren_r1;
        bren_r2_3_copy <= bren_r1;
        bren_r2_4_copy <= bren_r1;
        bren_r2_5_copy <= bren_r1;
    end
end

//brmod_r1,r2
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        brmod_r1 <= 3'b000;
        brmod_r2_1_copy <= 3'b000;
        brmod_r2_2_copy <= 3'b000;
        brmod_r2_3_copy <= 3'b000;
        brmod_r2_4_copy <= 3'b000;
        brmod_r2_5_copy <= 3'b000;
    end 
 
    else 
    begin
        brmod_r1 <= brmod_i;
        brmod_r2_1_copy <= brmod_r1;
        brmod_r2_2_copy <= brmod_r1;
        brmod_r2_3_copy <= brmod_r1;
        brmod_r2_4_copy <= brmod_r1;
        brmod_r2_5_copy <= brmod_r1;
    end
end

//braddr_r1,r2
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        braddr_r1 <= 15'b0;
        braddr_r2_1_copy <= 15'b0;
        braddr_r2_2_copy <= 15'b0;
        braddr_r2_3_copy <= 15'b0;
        braddr_r2_4_copy <= 15'b0;
        braddr_r2_5_copy <= 15'b0;
    end 

    else 
    begin
        braddr_r1 <= braddr_i;
        braddr_r2_1_copy <= braddr_r1;
        braddr_r2_2_copy <= braddr_r1;
        braddr_r2_3_copy <= braddr_r1;
        braddr_r2_4_copy <= braddr_r1;
        braddr_r2_5_copy <= braddr_r1;
    end
end

//ce_ren
//[14:0] braddr_i:[14:5]->read address for IP  [4:0]->IP_select and bitmask
//ce_ren: different from ce_wen  (4 IP all read if needed)
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        ce_ren  <=  1'b0;
    else if ( bce_10_copy && bren)
        ce_ren  <=  1'b1;
    else
        ce_ren  <=  1'b0;
end

//raddr
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        raddr <= 10'b0;
    else if (bce_10_copy && bren)
        raddr <=  braddr_i[14:5];
    else
        raddr <= raddr;
end

//brvalid_r
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        brvalid_r <= 1'b0;
    else if (bce_r2_1_copy && bren_r2_1_copy)//read valid 3 periods after bce/bren
        brvalid_r <= 1'b1;
    else
        brvalid_r <= 1'b0;
end

/*
//brdata_r
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        brdata_r <= 256'b0;
	else if ( bce_r2 && bren_r2 && brmod_r2 == 3'b000 ) //read by 8 bits
        case (braddr_r2[4:0])//braddr_r2[4:3]:decide which IP  braddr_r2[2:0] read bitmask 
            5'b00000:    brdata_r  <= { 248'b0, rdata1[7:0]    };//braddr_r2[4:3]=2'b00 -> first IP
			5'b00001:    brdata_r  <= { 248'b0, rdata1[15:8]   };
            5'b00010:    brdata_r  <= { 248'b0, rdata1[23:16]  };
			5'b00011:    brdata_r  <= { 248'b0, rdata1[31:24]  };
            5'b00100:    brdata_r  <= { 248'b0, rdata1[39:32]  };
			5'b00101:    brdata_r  <= { 248'b0, rdata1[47:40]  };
            5'b00110:    brdata_r  <= { 248'b0, rdata1[55:48]  };
			5'b00111:    brdata_r  <= { 248'b0, rdata1[63:56]  };
            5'b01000:    brdata_r  <= { 248'b0, rdata2[7:0]    };//braddr_r2[4:3]=2'b01 -> second IP
			5'b01001:    brdata_r  <= { 248'b0, rdata2[15:8]   };
            5'b01010:    brdata_r  <= { 248'b0, rdata2[23:16]  };
			5'b01011:    brdata_r  <= { 248'b0, rdata2[31:24]  };
            5'b01100:    brdata_r  <= { 248'b0, rdata2[39:32]  };
			5'b01101:    brdata_r  <= { 248'b0, rdata2[47:40]  };
            5'b01110:    brdata_r  <= { 248'b0, rdata2[55:48]  };
			5'b01111:    brdata_r  <= { 248'b0, rdata2[63:56]  };
            5'b10000:    brdata_r  <= { 248'b0, rdata3[7:0]    };//braddr_r2[4:3]=2'b10 -> third IP
			5'b10001:    brdata_r  <= { 248'b0, rdata3[15:8]   };
            5'b10010:    brdata_r  <= { 248'b0, rdata3[23:16]  };
			5'b10011:    brdata_r  <= { 248'b0, rdata3[31:24]  };
            5'b10100:    brdata_r  <= { 248'b0, rdata3[39:32]  };
			5'b10101:    brdata_r  <= { 248'b0, rdata3[47:40]  };
            5'b10110:    brdata_r  <= { 248'b0, rdata3[55:48]  };
			5'b10111:    brdata_r  <= { 248'b0, rdata3[63:56]  };
            5'b11000:    brdata_r  <= { 248'b0, rdata4[7:0]    };//braddr_r2[4:3]=2'b11 -> forth IP
			5'b11001:    brdata_r  <= { 248'b0, rdata4[15:8]   };
            5'b11010:    brdata_r  <= { 248'b0, rdata4[23:16]  };
			5'b11011:    brdata_r  <= { 248'b0, rdata4[31:24]  };
            5'b11100:    brdata_r  <= { 248'b0, rdata4[39:32]  };
			5'b11101:    brdata_r  <= { 248'b0, rdata4[47:40]  };
            5'b11110:    brdata_r  <= { 248'b0, rdata4[55:48]  };
			5'b11111:    brdata_r  <= { 248'b0, rdata4[63:56]  };			
            default:     brdata_r  <= 256'b0;         
        endcase
    else if ( bce_r2 && bren_r2 && brmod_r2 == 3'b001 ) //read by 16 bits
        case (braddr_r2[4:0])//braddr_r2[4:3]:decide which IP  braddr_r2[2:0] read bitmask 
            5'b00000:    brdata_r  <= { 240'b0, rdata1[15:0]   };//braddr_r2[4:3]=2'b00 -> first IP
            5'b00010:    brdata_r  <= { 240'b0, rdata1[31:16]  };
            5'b00100:    brdata_r  <= { 240'b0, rdata1[47:32]  };
            5'b00110:    brdata_r  <= { 240'b0, rdata1[63:48]  };
            5'b01000:    brdata_r  <= { 240'b0, rdata2[15:0]   };//braddr_r2[4:3]=2'b01 -> second IP
            5'b01010:    brdata_r  <= { 240'b0, rdata2[31:16]  };
            5'b01100:    brdata_r  <= { 240'b0, rdata2[47:32]  };
            5'b01110:    brdata_r  <= { 240'b0, rdata2[63:48]  };
            5'b10000:    brdata_r  <= { 240'b0, rdata3[15:0]   };//braddr_r2[4:3]=2'b10 -> third IP
            5'b10010:    brdata_r  <= { 240'b0, rdata3[31:16]  };
            5'b10100:    brdata_r  <= { 240'b0, rdata3[47:32]  };
            5'b10110:    brdata_r  <= { 240'b0, rdata3[63:48]  };
            5'b11000:    brdata_r  <= { 240'b0, rdata4[15:0]   };//braddr_r2[4:3]=2'b11 -> forth IP
            5'b11010:    brdata_r  <= { 240'b0, rdata4[31:16]  };
            5'b11100:    brdata_r  <= { 240'b0, rdata4[47:32]  };
            5'b11110:    brdata_r  <= { 240'b0, rdata4[63:48]  };
            default:     brdata_r  <= 256'b0;
        endcase
    else if ( bce_r2 && bren_r2 && brmod_r2 == 3'b010) //read by 32 bits
        case (braddr_r2[4:0])//braddr_r2[4:3]:decide which IP  braddr_r2[2:0] read bitmask 
            5'b00000:    brdata_r  <= { 224'b0, rdata1[31:0]   };//braddr_r2[4:3]=2'b00 -> first IP
            5'b00100:    brdata_r  <= { 224'b0, rdata1[63:32]  };
            5'b01000:    brdata_r  <= { 224'b0, rdata2[31:0]   };//braddr_r2[4:3]=2'b01 -> second IP
            5'b01100:    brdata_r  <= { 224'b0, rdata2[63:32]  };
            5'b10000:    brdata_r  <= { 224'b0, rdata3[31:0]   };//braddr_r2[4:3]=2'b10 -> third IP
            5'b10100:    brdata_r  <= { 224'b0, rdata3[63:32]  };
            5'b11000:    brdata_r  <= { 224'b0, rdata4[31:0]   };//braddr_r2[4:3]=2'b11 -> forth IP
            5'b11100:    brdata_r  <= { 224'b0, rdata4[63:32]  };
            default:     brdata_r  <= 256'b0;
        endcase
    else if ( bce_r2 && bren_r2 && brmod_r2 == 3'b011) //read by 64 bits
        case (braddr_r2[4:0])//brmod:64bit -> all four IP needed 
            5'b00000:    brdata_r  <= { 192'b0, rdata1[63:0]   };
            5'b01000:    brdata_r  <= { 192'b0, rdata2[63:0]   };
            5'b10000:    brdata_r  <= { 192'b0, rdata3[63:0]   };
            5'b11000:    brdata_r  <= { 192'b0, rdata4[63:0]   };
            default:     brdata_r  <= 256'b0;
        endcase
	else if ( bce_r2 && bren_r2 && brmod_r2 == 3'b100) //read by 128 bits
        case (braddr_r2[4:0])//brmod:64bit -> all four IP needed(128bits:two 64bits coupled)
            5'b00000:    brdata_r  <= { rdata2,rdata1   };
            5'b10000:    brdata_r  <= { rdata4,rdata3   };
            default:     brdata_r  <= 256'b0;
        endcase
    else if ( bce_r2 && brmod_r2 == 3'b101) //read by 256 bits
        brdata_r[255:0] <= { rdata4,rdata3,rdata2,rdata1 };//brmod:64bit -> all four IP needed (256bits:four 64bits coupled)
//    else
//        brdata_r <= brdata_r; 
end
*/



always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n)
    begin
        brdata_r <= 256'b0;
    end

    else if ( bce_r2_2_copy && bren_r2_2_copy && brmod_r2_1_copy == 3'b000 ) //read by 8 bits
    begin
        brdata_r  <= brdata_r1;
    end

    else if ( bce_r2_2_copy && bren_r2_3_copy && brmod_r2_2_copy == 3'b001 ) //read by 16 bits
    begin
        brdata_r  <= brdata_r2;
    end

    else if ( bce_r2_3_copy && bren_r2_4_copy && brmod_r2_3_copy == 3'b010) //read by 32 bits
    begin
        brdata_r  <= brdata_r3;
    end

    else if ( bce_r2_3_copy && bren_r2_5_copy && brmod_r2_4_copy == 3'b011) //read by 64 bits
    begin
        brdata_r  <= brdata_r4;
    end

    else if ( bce_r2_4_copy && bren_r2_5_copy && brmod_r2_5_copy == 3'b100) //read by 128 bits
    begin
        brdata_r  <= brdata_r5;
    end

    else if ( bce_r2_5_copy && brmod_r2_5_copy == 3'b101) //read by 256 bits
    begin
        brdata_r[255:0] <= { rdata4,rdata3,rdata2,rdata1 };//brmod:64bit -> all four IP needed (256bits:four 64bits coupled)
    end
//    else
//        brdata_r <= brdata_r; 
end






always @(*) 
begin
    case (braddr_r2_1_copy[4:0])//braddr_r2[4:3]:decide which IP  braddr_r2[2:0] read bitmask 
        5'b00000:    brdata_r1  <= { 248'b0, rdata1[7:0]    };//braddr_r2[4:3]=2'b00 -> first IP
        5'b00001:    brdata_r1  <= { 248'b0, rdata1[15:8]   };
        5'b00010:    brdata_r1  <= { 248'b0, rdata1[23:16]  };
        5'b00011:    brdata_r1  <= { 248'b0, rdata1[31:24]  };
        5'b00100:    brdata_r1  <= { 248'b0, rdata1[39:32]  };
        5'b00101:    brdata_r1  <= { 248'b0, rdata1[47:40]  };
        5'b00110:    brdata_r1  <= { 248'b0, rdata1[55:48]  };
        5'b00111:    brdata_r1  <= { 248'b0, rdata1[63:56]  };
        5'b01000:    brdata_r1  <= { 248'b0, rdata2[7:0]    };//braddr_r2[4:3]=2'b01 -> second IP
        5'b01001:    brdata_r1  <= { 248'b0, rdata2[15:8]   };
        5'b01010:    brdata_r1  <= { 248'b0, rdata2[23:16]  };
        5'b01011:    brdata_r1  <= { 248'b0, rdata2[31:24]  };
        5'b01100:    brdata_r1  <= { 248'b0, rdata2[39:32]  };
        5'b01101:    brdata_r1  <= { 248'b0, rdata2[47:40]  };
        5'b01110:    brdata_r1  <= { 248'b0, rdata2[55:48]  };
        5'b01111:    brdata_r1  <= { 248'b0, rdata2[63:56]  };
        5'b10000:    brdata_r1  <= { 248'b0, rdata3[7:0]    };//braddr_r2[4:3]=2'b10 -> third IP
        5'b10001:    brdata_r1  <= { 248'b0, rdata3[15:8]   };
        5'b10010:    brdata_r1  <= { 248'b0, rdata3[23:16]  };
        5'b10011:    brdata_r1  <= { 248'b0, rdata3[31:24]  };
        5'b10100:    brdata_r1  <= { 248'b0, rdata3[39:32]  };
        5'b10101:    brdata_r1  <= { 248'b0, rdata3[47:40]  };
        5'b10110:    brdata_r1  <= { 248'b0, rdata3[55:48]  };
        5'b10111:    brdata_r1  <= { 248'b0, rdata3[63:56]  };
        5'b11000:    brdata_r1  <= { 248'b0, rdata4[7:0]    };//braddr_r2[4:3]=2'b11 -> forth IP
        5'b11001:    brdata_r1  <= { 248'b0, rdata4[15:8]   };
        5'b11010:    brdata_r1  <= { 248'b0, rdata4[23:16]  };
        5'b11011:    brdata_r1  <= { 248'b0, rdata4[31:24]  };
        5'b11100:    brdata_r1  <= { 248'b0, rdata4[39:32]  };
        5'b11101:    brdata_r1  <= { 248'b0, rdata4[47:40]  };
        5'b11110:    brdata_r1  <= { 248'b0, rdata4[55:48]  };
        5'b11111:    brdata_r1  <= { 248'b0, rdata4[63:56]  };			
        default:     brdata_r1  <= 256'b0;     
    endcase
end



always @(*) 
begin
    case (braddr_r2_2_copy[4:0])//braddr_r2[4:3]:decide which IP  braddr_r2[2:0] read bitmask 
        5'b00000:    brdata_r2  <= { 240'b0, rdata1[15:0]   };//braddr_r2[4:3]=2'b00 -> first IP
        5'b00010:    brdata_r2  <= { 240'b0, rdata1[31:16]  };
        5'b00100:    brdata_r2  <= { 240'b0, rdata1[47:32]  };
        5'b00110:    brdata_r2  <= { 240'b0, rdata1[63:48]  };
        5'b01000:    brdata_r2  <= { 240'b0, rdata2[15:0]   };//braddr_r2[4:3]=2'b01 -> second IP
        5'b01010:    brdata_r2  <= { 240'b0, rdata2[31:16]  };
        5'b01100:    brdata_r2  <= { 240'b0, rdata2[47:32]  };
        5'b01110:    brdata_r2  <= { 240'b0, rdata2[63:48]  };
        5'b10000:    brdata_r2  <= { 240'b0, rdata3[15:0]   };//braddr_r2[4:3]=2'b10 -> third IP
        5'b10010:    brdata_r2  <= { 240'b0, rdata3[31:16]  };
        5'b10100:    brdata_r2  <= { 240'b0, rdata3[47:32]  };
        5'b10110:    brdata_r2  <= { 240'b0, rdata3[63:48]  };
        5'b11000:    brdata_r2  <= { 240'b0, rdata4[15:0]   };//braddr_r2[4:3]=2'b11 -> forth IP
        5'b11010:    brdata_r2  <= { 240'b0, rdata4[31:16]  };
        5'b11100:    brdata_r2  <= { 240'b0, rdata4[47:32]  };
        5'b11110:    brdata_r2  <= { 240'b0, rdata4[63:48]  };
        default:     brdata_r2  <= 256'b0;
    endcase
end



always @(*) 
begin
    case (braddr_r2_3_copy[4:0])//braddr_r2[4:3]:decide which IP  braddr_r2[2:0] read bitmask 
        5'b00000:    brdata_r3  <= { 224'b0, rdata1[31:0]   };//braddr_r2[4:3]=2'b00 -> first IP
        5'b00100:    brdata_r3  <= { 224'b0, rdata1[63:32]  };
        5'b01000:    brdata_r3  <= { 224'b0, rdata2[31:0]   };//braddr_r2[4:3]=2'b01 -> second IP
        5'b01100:    brdata_r3  <= { 224'b0, rdata2[63:32]  };
        5'b10000:    brdata_r3  <= { 224'b0, rdata3[31:0]   };//braddr_r2[4:3]=2'b10 -> third IP
        5'b10100:    brdata_r3  <= { 224'b0, rdata3[63:32]  };
        5'b11000:    brdata_r3  <= { 224'b0, rdata4[31:0]   };//braddr_r2[4:3]=2'b11 -> forth IP
        5'b11100:    brdata_r3  <= { 224'b0, rdata4[63:32]  };
        default:     brdata_r3  <= 256'b0;
    endcase
end


always @(*) 
begin
    case (braddr_r2_4_copy[4:0])//brmod:64bit -> all four IP needed 
        5'b00000:    brdata_r4  <= { 192'b0, rdata1[63:0]   };
        5'b01000:    brdata_r4  <= { 192'b0, rdata2[63:0]   };
        5'b10000:    brdata_r4  <= { 192'b0, rdata3[63:0]   };
        5'b11000:    brdata_r4  <= { 192'b0, rdata4[63:0]   };
        default:     brdata_r4  <= 256'b0;
    endcase
end


always @(*) 
begin
    case (braddr_r2_5_copy[4:0])//brmod:64bit -> all four IP needed(128bits:two 64bits coupled)
        5'b00000:    brdata_r5  <= { rdata2,rdata1   };
        5'b10000:    brdata_r5  <= { rdata4,rdata3   };
        default:     brdata_r5  <= 256'b0;
    endcase
end

// ****************************** //

// ******************************
// INSTANTIATE MODULE //
// ******************************
TS6N12FFCLLLVTB1024X64M4W  u1_TS6N12FFCLLLVTB1024X64M4W 
(                                      
    .Q           (rdata1                ),
    .AA          (waddr                 ),
    .D           (wdata1                ),
    .BWEB        (wbitmask1             ),
    .WEB         (~ce_wen1              ),
    .CLK         (clk                   ),
    .RTSEL       (2'b01                 ),
    .WTSEL       (2'b0                  ),
    .MTSEL       (2'b0                  ),
    .AB          (raddr                 ),	//read address input
    .REB         (~ce_ren               )	//memory enable input
);

TS6N12FFCLLLVTB1024X64M4W  u2_TS6N12FFCLLLVTB1024X64M4W 
(
    .Q           (rdata2                ),
    .AA          (waddr                 ),
    .D           (wdata2                ),
    .BWEB        (wbitmask2             ),
    .WEB         (~ce_wen2              ),
    .CLK         (clk                   ),
    .RTSEL       (2'b01                 ),
    .WTSEL       (2'b0                  ),
    .MTSEL       (2'b0                  ),
    .AB          (raddr                 ),	//read address input
    .REB         (~ce_ren               )	//memory enable input
);

TS6N12FFCLLLVTB1024X64M4W  u3_TS6N12FFCLLLVTB1024X64M4W 
(
    .Q           (rdata3                ),
    .AA          (waddr                 ),
    .D           (wdata3                ),
    .BWEB        (wbitmask3             ),
    .WEB         (~ce_wen3              ),
    .CLK         (clk                   ),
    .RTSEL       (2'b01                 ),
    .WTSEL       (2'b0                  ),
    .MTSEL       (2'b0                  ),
    .AB          (raddr                 ),	//read address input
    .REB         (~ce_ren               )	//memory enable input
);

TS6N12FFCLLLVTB1024X64M4W  u4_TS6N12FFCLLLVTB1024X64M4W 
(
    .Q           (rdata4                ),
    .AA          (waddr                 ),
    .D           (wdata4                ),
    .BWEB        (wbitmask4             ),
    .WEB         (~ce_wen4              ),
    .CLK         (clk                   ),
    .RTSEL       (2'b01                 ),
    .WTSEL       (2'b0                  ),
    .MTSEL       (2'b0                  ),
    .AB          (raddr                 ),	//read address input
    .REB         (~ce_ren               )	//memory enable input
);
endmodule
