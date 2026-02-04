module sto(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [11:0] tran_time,
    output wire act_pe_valid,
    output wire [127:0] act_pe_o,
    // output reg load_weight_en,
    output wire bce_0,
    output wire bce_1,
    output wire bce_2,
    output wire bce_3,
    output wire bce_4,
    output wire bce_5,
    output wire bce_6,
    output wire bce_7,
    output wire [14:0] braddr_0,
    output wire [14:0] braddr_1,
    output wire [14:0] braddr_2,
    output wire [14:0] braddr_3,
    output wire [14:0] braddr_4,
    output wire [14:0] braddr_5,
    output wire [14:0] braddr_6,
    output wire [14:0] braddr_7,
    input wire [63:0] brdata_0,
    input wire [63:0] brdata_1,
    input wire [63:0] brdata_2,
    input wire [63:0] brdata_3,
    input wire brvalid_0,
    input wire brvalid_1,
    input wire brvalid_2,
    input wire brvalid_3
);


reg weight_start;
reg act_start;
wire weight_load_done;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        weight_start <= 1'b0;
        act_start <= 1'b0;
    end else begin
        if (start) begin
            weight_start <= 1'b1;
        end else if(weight_start) begin
            weight_start <= 1'b0;
        end else if(act_start) begin
            act_start <= 1'b0;
        end else if(weight_load_done)begin
            act_start <= 1'b1;
        end
    end
end


act u_act (
    .clk(clk),
    .rst_n(rst_n),
    .start(act_start),
    .tran_time(tran_time),
    .bce0(bce_0),
    .bce1(bce_1),
    .bce2(bce_2),
    .bce3(bce_3),
    .braddr0(braddr_0),
    .braddr1(braddr_1),
    .braddr2(braddr_2),
    .braddr3(braddr_3),
    .brdata0(brdata_0),
    .brdata1(brdata_1),
    .brdata2(brdata_2),
    .brdata3(brdata_3),
    .brvalid0(brvalid_0),
    .brvalid1(brvalid_1),
    .brvalid2(brvalid_2),
    .brvalid3(brvalid_3),
    .act_out_skewed(act_pe_o),
    .act_out_valid(act_pe_valid)
);

weight u_weight (
    .clk(clk),
    .rst_n(rst_n),
    .start(weight_start),
    .bce0(bce_4),
    .bce1(bce_5),
    .bce2(bce_6),
    .bce3(bce_7),
    .braddr0(braddr_4),
    .braddr1(braddr_5),
    .braddr2(braddr_6),
    .braddr3(braddr_7),
    .weight_load_done(weight_load_done)
);



endmodule