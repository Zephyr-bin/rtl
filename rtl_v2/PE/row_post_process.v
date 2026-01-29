module row_post_process (
    input wire clk,
    input wire rst_n,
    
    // 输入：来自脉动阵列的原始输出 (32路 x 32bit)
    // 数据状态：Diagonal (斜的，波浪状)
    input wire [32*32-1:0] sys_array_out_32b, 
    
    // 输入：阵列输出有效指示 (通常指示第0列第0行出数了)
    input wire array_out_valid, 
    
    // 配置：缩放因子
    input wire [15:0] global_scale_factor,
    
    // 输出：缩放后的数据 (32路 x 16bit)
    // 数据状态：仍然是 Diagonal (斜的)，只是位宽变了
    output wire [32*16-1:0] fp16_out_diagonal,
    
    // 输出：经过3拍流水线延时后的 Valid 信号
    // 用这个信号去驱动 Res 模块！
    output reg fp16_valid_diagonal
);

    parameter COL_NUM = 32;

    // 1. Valid 信号打 3 拍 (匹配 Scale Unit 的 3 级流水线)
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

    // 2. 实例化 32 个 Scaling Unit
    // 它们并行工作，互不干扰，所以数据是斜的也没关系
    genvar i;
    generate
        for (i = 0; i < COL_NUM; i = i + 1) begin : scale_row
            scale_unit u_scaler (
                .clk        (clk),
                .rst_n      (rst_n),
                .int_in     (sys_array_out_32b[(i+1)*32-1 : i*32]),
                .fp16_scale (global_scale_factor),
                .fp16_out   (fp16_out_diagonal[(i+1)*16-1 : i*16])
            );
        end
    endgenerate

endmodule