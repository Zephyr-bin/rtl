////////////////////////////////////////////////////////
// 
// Version 1.0 
// Author:
// 
/////////////////////////////////////////////////////////
module wrapper_16banks(
	clk,
	rst_n,
//INPUT
	bce0_i ,
	bce1_i ,
	bce2_i ,
	bce3_i ,
	bce4_i ,
	bce5_i ,
	bce6_i ,
	bce7_i ,
	bce8_i ,
	bce9_i ,
	bce10_i,
	bce11_i,
	bce12_i,
	bce13_i,
	bce14_i,
	bce15_i,
	
	bwmod0_i ,
	bwmod1_i ,
	bwmod2_i ,
	bwmod3_i ,
	bwmod4_i ,
	bwmod5_i ,
	bwmod6_i ,
	bwmod7_i ,
	bwmod8_i ,
	bwmod9_i ,
	bwmod10_i,
	bwmod11_i,
	bwmod12_i,
	bwmod13_i,
	bwmod14_i,
	bwmod15_i,
	
	bwren0_i ,
	bwren1_i ,
	bwren2_i ,
	bwren3_i ,
	bwren4_i ,
	bwren5_i ,
	bwren6_i ,
	bwren7_i ,
	bwren8_i ,
	bwren9_i ,
	bwren10_i,
	bwren11_i,
	bwren12_i,
	bwren13_i,
	bwren14_i,
	bwren15_i,
	
	bwaddr0_i ,
	bwaddr1_i ,
	bwaddr2_i ,
	bwaddr3_i ,
	bwaddr4_i ,
	bwaddr5_i ,
	bwaddr6_i ,
	bwaddr7_i ,
	bwaddr8_i ,
	bwaddr9_i ,
	bwaddr10_i,
	bwaddr11_i,
	bwaddr12_i,
	bwaddr13_i,
	bwaddr14_i,
	bwaddr15_i,
	
	bwdata0_i ,
	bwdata1_i ,
	bwdata2_i ,
	bwdata3_i ,
	bwdata4_i ,
	bwdata5_i ,
	bwdata6_i ,
	bwdata7_i ,
	bwdata8_i ,
	bwdata9_i ,
	bwdata10_i,
	bwdata11_i,
	bwdata12_i,
	bwdata13_i,
	bwdata14_i,
	bwdata15_i,
	
	brmod0_i ,
	brmod1_i ,
	brmod2_i ,
	brmod3_i ,
	brmod4_i ,
	brmod5_i ,
	brmod6_i ,
	brmod7_i ,
	brmod8_i ,
	brmod9_i ,
	brmod10_i,
	brmod11_i,
	brmod12_i,
	brmod13_i,
	brmod14_i,
	brmod15_i,
	
	braddr0_i ,
	braddr1_i ,
	braddr2_i ,
	braddr3_i ,
	braddr4_i ,
	braddr5_i ,
	braddr6_i ,
	braddr7_i ,
	braddr8_i ,
	braddr9_i ,
	braddr10_i,
	braddr11_i,
	braddr12_i,
	braddr13_i,
	braddr14_i,
	braddr15_i,
//OUTPUT
	brdata0_o ,
	brdata1_o ,
	brdata2_o ,
	brdata3_o ,
	brdata4_o ,
	brdata5_o ,
	brdata6_o ,
	brdata7_o ,
	brdata8_o ,
	brdata9_o ,
	brdata10_o,
	brdata11_o,
	brdata12_o,
	brdata13_o,
	brdata14_o,
	brdata15_o,
	
	brvalid0_o ,
	brvalid1_o ,
	brvalid2_o ,
	brvalid3_o ,
	brvalid4_o ,
	brvalid5_o ,
	brvalid6_o ,
	brvalid7_o ,
	brvalid8_o ,
	brvalid9_o ,
	brvalid10_o,
	brvalid11_o,
	brvalid12_o,
	brvalid13_o,
	brvalid14_o,
	brvalid15_o

    );

// ******************************
// DEFINE INPUT
// ******************************
	input        clk  ;//clock signal
	input        rst_n;//reset,active low
					  
	input        bce0_i ;//bank_enable
	input        bce1_i ;
	input        bce2_i ;
	input        bce3_i ;
	input        bce4_i ;
	input        bce5_i ;
	input        bce6_i ;
	input        bce7_i ;
	input        bce8_i ;
	input        bce9_i ;
	input        bce10_i;
	input        bce11_i;
	input        bce12_i;
	input        bce13_i;
	input        bce14_i;
	input        bce15_i;
	
	input [2:0]  bwmod0_i ;//bank_write_mode:3'b000(8bit) //3'b001(16bit)//3'b010(32bit)//3'b011(64bit)//3'b100(128bit)//3'b101(256bit) 
	input [2:0]  bwmod1_i ;
	input [2:0]  bwmod2_i ;
	input [2:0]  bwmod3_i ;
	input [2:0]  bwmod4_i ;
	input [2:0]  bwmod5_i ;
	input [2:0]  bwmod6_i ;
	input [2:0]  bwmod7_i ;
	input [2:0]  bwmod8_i ;
	input [2:0]  bwmod9_i ;
	input [2:0]  bwmod10_i;
	input [2:0]  bwmod11_i;
	input [2:0]  bwmod12_i;
	input [2:0]  bwmod13_i;
	input [2:0]  bwmod14_i;
	input [2:0]  bwmod15_i;
	
	input [1:0]  bwren0_i ;//bank_write_read_enable
	input [1:0]  bwren1_i ;
	input [1:0]  bwren2_i ;
	input [1:0]  bwren3_i ;
	input [1:0]  bwren4_i ;
	input [1:0]  bwren5_i ;
	input [1:0]  bwren6_i ;
	input [1:0]  bwren7_i ;
	input [1:0]  bwren8_i ;
	input [1:0]  bwren9_i ;
	input [1:0]  bwren10_i;
	input [1:0]  bwren11_i;
	input [1:0]  bwren12_i;
	input [1:0]  bwren13_i;
	input [1:0]  bwren14_i;
	input [1:0]  bwren15_i;
	
	input [14:0] bwaddr0_i ;//bank_write_address  -32K
	input [14:0] bwaddr1_i ;
	input [14:0] bwaddr2_i ;
	input [14:0] bwaddr3_i ;
	input [14:0] bwaddr4_i ;
	input [14:0] bwaddr5_i ;
	input [14:0] bwaddr6_i ;
	input [14:0] bwaddr7_i ;
	input [14:0] bwaddr8_i ;
	input [14:0] bwaddr9_i ;
	input [14:0] bwaddr10_i;
	input [14:0] bwaddr11_i;
	input [14:0] bwaddr12_i;
	input [14:0] bwaddr13_i;
	input [14:0] bwaddr14_i;
	input [14:0] bwaddr15_i;
	
	input [255:0] bwdata0_i ;//bank_write_data
	input [255:0] bwdata1_i ;
	input [255:0] bwdata2_i ;
	input [255:0] bwdata3_i ;
	input [255:0] bwdata4_i ;
	input [255:0] bwdata5_i ;
	input [255:0] bwdata6_i ;
	input [255:0] bwdata7_i ;
	input [255:0] bwdata8_i ;
	input [255:0] bwdata9_i ;
	input [255:0] bwdata10_i;
	input [255:0] bwdata11_i;
	input [255:0] bwdata12_i;
	input [255:0] bwdata13_i;
	input [255:0] bwdata14_i;
	input [255:0] bwdata15_i;
	
	input [2:0]  brmod0_i ;//bank_read_mode:3'b000(8bit) //3'b001(16bit)//3'b010(32bit)//3'b011(64bit)//3'b100(128bit)//3'b101(256bit) 
	input [2:0]  brmod1_i ;
	input [2:0]  brmod2_i ;
	input [2:0]  brmod3_i ;
	input [2:0]  brmod4_i ;
	input [2:0]  brmod5_i ;
	input [2:0]  brmod6_i ;
	input [2:0]  brmod7_i ;
	input [2:0]  brmod8_i ;
	input [2:0]  brmod9_i ;
	input [2:0]  brmod10_i;
	input [2:0]  brmod11_i;
	input [2:0]  brmod12_i;
	input [2:0]  brmod13_i;
	input [2:0]  brmod14_i;
	input [2:0]  brmod15_i;
	
	input [14:0] braddr0_i ;//bank_read_address  -32K
	input [14:0] braddr1_i ;
	input [14:0] braddr2_i ;
	input [14:0] braddr3_i ;
	input [14:0] braddr4_i ;
	input [14:0] braddr5_i ;
	input [14:0] braddr6_i ;
	input [14:0] braddr7_i ;
	input [14:0] braddr8_i ;
	input [14:0] braddr9_i ;
	input [14:0] braddr10_i;
	input [14:0] braddr11_i;
	input [14:0] braddr12_i;
	input [14:0] braddr13_i;
	input [14:0] braddr14_i;
	input [14:0] braddr15_i;
	
// ******************************
// DEFINE OUTPUT
// ******************************
	output [255:0] brdata0_o ;//bank_read_data
	output [255:0] brdata1_o ;
	output [255:0] brdata2_o ;
	output [255:0] brdata3_o ;
	output [255:0] brdata4_o ;
	output [255:0] brdata5_o ;
	output [255:0] brdata6_o ;
	output [255:0] brdata7_o ;
	output [255:0] brdata8_o ;
	output [255:0] brdata9_o ;
	output [255:0] brdata10_o;
	output [255:0] brdata11_o;
	output [255:0] brdata12_o;
	output [255:0] brdata13_o;
	output [255:0] brdata14_o;
	output [255:0] brdata15_o;
	
	output        brvalid0_o ;//bank_read_valid
	output        brvalid1_o ;
	output        brvalid2_o ;
	output        brvalid3_o ;
	output        brvalid4_o ;
	output        brvalid5_o ;
	output        brvalid6_o ;
	output        brvalid7_o ;
	output        brvalid8_o ;
	output        brvalid9_o ;
	output        brvalid10_o;
	output        brvalid11_o;
	output        brvalid12_o;
	output        brvalid13_o;
	output        brvalid14_o;
	output        brvalid15_o; 



// ******************************
// INSTANTIATE MODULE //
// ******************************
bank bank0  (.clk(clk),//clock signal
             .rst_n(rst_n),//reset,active low
             .bce_i(bce0_i),//bank_enable
             .bwmod_i(bwmod0_i),//bank_write_mode:3'b000(8bit) //3'b001(16bit)//3'b010(32bit)//3'b011(64bit)//3'b100(128bit)//3'b101(256bit) 
             .bwren_i(bwren0_i),//bank_write_read_enable
             .bwaddr_i(bwaddr0_i),//bank_write_address  -32K
             .bwdata_i(bwdata0_i),//bank_write_data
             .brmod_i(brmod0_i),//bank_read_mode:3'b000(8bit) //3'b001(16bit)//3'b010(32bit)//3'b011(64bit)//3'b100(128bit)//3'b101(256bit) 
             .braddr_i(braddr0_i),//bank_read_address  -32K
             .brdata_r(brdata0_o),//bank_read_data
             .brvalid_r(brvalid0_o));//bank_read_valid
bank bank1  (.clk(clk),
             .rst_n(rst_n),
             .bce_i(bce1_i),
             .bwmod_i(bwmod1_i),
             .bwren_i(bwren1_i),
             .bwaddr_i(bwaddr1_i),
             .bwdata_i(bwdata1_i),
             .brmod_i(brmod1_i),
             .braddr_i(braddr1_i),
             .brdata_r(brdata1_o),
             .brvalid_r(brvalid1_o));
bank bank2  (.clk(clk),
             .rst_n(rst_n),
             .bce_i(bce2_i),
             .bwmod_i(bwmod2_i),
             .bwren_i(bwren2_i),
             .bwaddr_i(bwaddr2_i),
             .bwdata_i(bwdata2_i),
             .brmod_i(brmod2_i),
             .braddr_i(braddr2_i),
             .brdata_r(brdata2_o),
             .brvalid_r(brvalid2_o));
bank bank3  (.clk(clk),
             .rst_n(rst_n),
             .bce_i(bce3_i),
             .bwmod_i(bwmod3_i),
             .bwren_i(bwren3_i),
             .bwaddr_i(bwaddr3_i),
             .bwdata_i(bwdata3_i),
             .brmod_i(brmod3_i),
             .braddr_i(braddr3_i),
             .brdata_r(brdata3_o),
             .brvalid_r(brvalid3_o));
bank bank4  (.clk(clk),
             .rst_n(rst_n),
             .bce_i(bce4_i),
             .bwmod_i(bwmod4_i),
             .bwren_i(bwren4_i),
             .bwaddr_i(bwaddr4_i),
             .bwdata_i(bwdata4_i),
             .brmod_i(brmod4_i),
             .braddr_i(braddr4_i),
             .brdata_r(brdata4_o),
             .brvalid_r(brvalid4_o));
bank bank5  (.clk(clk),
             .rst_n(rst_n),
             .bce_i(bce5_i),
             .bwmod_i(bwmod5_i),
             .bwren_i(bwren5_i),
             .bwaddr_i(bwaddr5_i),
             .bwdata_i(bwdata5_i),
             .brmod_i(brmod5_i),
             .braddr_i(braddr5_i),
             .brdata_r(brdata5_o),
             .brvalid_r(brvalid5_o));
bank bank6  (.clk(clk),
             .rst_n(rst_n),
             .bce_i(bce6_i),
             .bwmod_i(bwmod6_i),
             .bwren_i(bwren6_i),
             .bwaddr_i(bwaddr6_i),
             .bwdata_i(bwdata6_i),
             .brmod_i(brmod6_i),
             .braddr_i(braddr6_i),
             .brdata_r(brdata6_o),
             .brvalid_r(brvalid6_o));
bank bank7  (.clk(clk),
             .rst_n(rst_n),
             .bce_i(bce7_i),
             .bwmod_i(bwmod7_i),
             .bwren_i(bwren7_i),
             .bwaddr_i(bwaddr7_i),
             .bwdata_i(bwdata7_i),
             .brmod_i(brmod7_i),
             .braddr_i(braddr7_i),
             .brdata_r(brdata7_o),
             .brvalid_r(brvalid7_o));
bank bank8  (.clk(clk),
             .rst_n(rst_n),
             .bce_i(bce8_i),
             .bwmod_i(bwmod8_i),
             .bwren_i(bwren8_i),
             .bwaddr_i(bwaddr8_i),
             .bwdata_i(bwdata8_i),
             .brmod_i(brmod8_i),
             .braddr_i(braddr8_i),
             .brdata_r(brdata8_o),
             .brvalid_r(brvalid8_o));
bank bank9  (.clk(clk),
             .rst_n(rst_n),
             .bce_i(bce9_i),
             .bwmod_i(bwmod9_i),
             .bwren_i(bwren9_i),
             .bwaddr_i(bwaddr9_i),
             .bwdata_i(bwdata9_i),
             .brmod_i(brmod9_i),
             .braddr_i(braddr9_i),
             .brdata_r(brdata9_o),
             .brvalid_r(brvalid9_o));
bank bank10  (.clk(clk),
              .rst_n(rst_n),
              .bce_i(bce10_i),
              .bwmod_i(bwmod10_i),
              .bwren_i(bwren10_i),
              .bwaddr_i(bwaddr10_i),
              .bwdata_i(bwdata10_i),
              .brmod_i(brmod10_i),
              .braddr_i(braddr10_i),
              .brdata_r(brdata10_o),
              .brvalid_r(brvalid10_o));
bank bank11  (.clk(clk),
              .rst_n(rst_n),
              .bce_i(bce11_i),
              .bwmod_i(bwmod11_i),
              .bwren_i(bwren11_i),
              .bwaddr_i(bwaddr11_i),
              .bwdata_i(bwdata11_i),
              .brmod_i(brmod11_i),
              .braddr_i(braddr11_i),
              .brdata_r(brdata11_o),
              .brvalid_r(brvalid11_o));
bank bank12  (.clk(clk),
              .rst_n(rst_n),
              .bce_i(bce12_i),
              .bwmod_i(bwmod12_i),
              .bwren_i(bwren12_i),
              .bwaddr_i(bwaddr12_i),
              .bwdata_i(bwdata12_i),
              .brmod_i(brmod12_i),
              .braddr_i(braddr12_i),
              .brdata_r(brdata12_o),
              .brvalid_r(brvalid12_o));
bank bank13  (.clk(clk),
              .rst_n(rst_n),
              .bce_i(bce13_i),
              .bwmod_i(bwmod13_i),
              .bwren_i(bwren13_i),
              .bwaddr_i(bwaddr13_i),
              .bwdata_i(bwdata13_i),
              .brmod_i(brmod13_i),
              .braddr_i(braddr13_i),
              .brdata_r(brdata13_o),
              .brvalid_r(brvalid13_o));
bank bank14  (.clk(clk),
              .rst_n(rst_n),
              .bce_i(bce14_i),
              .bwmod_i(bwmod14_i),
              .bwren_i(bwren14_i),
              .bwaddr_i(bwaddr14_i),
              .bwdata_i(bwdata14_i),
              .brmod_i(brmod14_i),
              .braddr_i(braddr14_i),
              .brdata_r(brdata14_o),
              .brvalid_r(brvalid14_o));
bank bank15  (.clk(clk),
              .rst_n(rst_n),
              .bce_i(bce15_i),
              .bwmod_i(bwmod15_i),
              .bwren_i(bwren15_i),
              .bwaddr_i(bwaddr15_i),
              .bwdata_i(bwdata15_i),
              .brmod_i(brmod15_i),
              .braddr_i(braddr15_i),
              .brdata_r(brdata15_o),
              .brvalid_r(brvalid15_o));


endmodule