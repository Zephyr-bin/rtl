module row_post_process (
    input wire clk,
    input wire rst_n,
    
    // 输入：来自脉动阵列的原始输出 (32路 x 32bit)
    // 数据状态：Diagonal (斜的，波浪状)
    input wire [32*32-1:0] sys_array_out_32b, 
    
    // 输入：阵列输出有效指示
    input wire array_out_valid, 
    
    // [修改点 1] 配置：改为逐列缩放因子 (Per-Column Scale Factors)
    // 32列 x 16bit = 512 bit 总位宽
    // col_scale_factors[15:0] 对应第0列
    // col_scale_factors[31:16] 对应第1列 ... 以此类推
    input wire [32*16-1:0] col_scale_factors,
    
    // 输出：缩放后的数据 (32路 x 16bit)
    // 数据状态：仍然是 Diagonal (斜的)
    output wire [32*16-1:0] fp16_out_diagonal,
    
    // 输出：经过3拍流水线延时后的 Valid 信号
    output reg fp16_valid_diagonal
);

    parameter COL_NUM = 32;

    // ============================================================
    // 1. Valid 信号打 3 拍 (匹配 Scale Unit 的 3 级流水线)
    // ============================================================
    // 逻辑保持不变
    reg [2:0] valid_pipe;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            valid_pipe <= 0;
            fp16_valid_diagonal <= 0;
        end else begin
            valid_pipe <= {valid_pipe[1:0], array_out_valid};
            fp16_valid_diagonal <= valid_pipe[2];
        end
    end

    // ============================================================
    // 2. 实例化 32 个 Scaling Unit
    // ============================================================
    genvar i;
    generate
        for (i = 0; i < COL_NUM; i = i + 1) begin : scale_row
            // 从扁平总线中提取当前列对应的信号
            wire [31:0] current_col_in   = sys_array_out_32b[(i+1)*32-1 : i*32];
            
            // [修改点 2] 提取当前列对应的缩放因子
            wire [15:0] current_col_scale = col_scale_factors[(i+1)*16-1 : i*16];

            scale_unit u_scaler (
                .clk        (clk),
                .rst_n      (rst_n),
                .int_in     (current_col_in),
                
                // 这里传入的是当前列独有的 scale factor
                .fp16_scale (current_col_scale), 
                
                .fp16_out   (fp16_out_diagonal[(i+1)*16-1 : i*16])
            );
        end
    endgenerate

endmodule