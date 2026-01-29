`timescale 1ns/1ps

module mac_pe (
    input wire clk,
    input wire rst_n,
    input wire load_weight_en,
    
    // 水平方向：输入数据流
    input wire signed [3:0] in_a,      
    output reg signed [3:0] out_a,     
    
    // 垂直方向：累加和流
    input wire signed [31:0] in_sum,  
    output reg signed [31:0] out_sum  
);

    reg signed [7:0] weight_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            weight_reg <= 8'd0;
            out_a <= 4'd0;
            out_sum <= 32'd0;
        end else begin
            // 权重加载模式
            if (load_weight_en) begin
                weight_reg <= in_sum[7:0]; // 从累加和输入端口加载权重
                out_sum <= in_sum;      // 传递权重
            end 
            // 计算模式
            else begin
                out_a <= in_a;
                // MAC: Sum = Sum + (A * W)
                out_sum <= in_sum + (in_a * weight_reg[3:0]) << weight_reg[7:4];
            end
        end
    end

endmodule