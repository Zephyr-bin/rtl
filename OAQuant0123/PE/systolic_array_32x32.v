module systolic_array_32x32 (
    input wire clk,
    input wire rst_n,
    input wire load_weight_en, // 1: 加载权重, 0: 计算

    // --- 输入端口 ---
    // 32行 x 4bit 数据 (Activation)
    // data_in[3:0] 是第0行输入, data_in[7:4] 是第1行输入...
    input wire [32*4-1:0] row_in_flat,

    // 32列 x 32bit 部分和/权重输入 (Partial Sum / Weight Input)
    // 通常计算开始时这里输入0；加载权重时这里输入权重数据
    input wire [32*8-1:0] col_in_flat,

    // --- 输出端口 ---
    // 32列 x 32bit 计算结果
    output wire [32*32-1:0] col_out_flat
);

    // 定义阵列规模参数
    parameter ROW_NUM = 32;
    parameter COL_NUM = 32;

    // =======================================================
    // 1. 内部连线定义 (二维数组)
    // =======================================================
    
    // 水平方向连线 (Activation): [行][列+1]
    // h_wire[i][0] 是输入，h_wire[i][32] 是这一行的最终输出(通常悬空)
    wire signed [3:0] h_wire [0:ROW_NUM-1][0:COL_NUM];

    // 垂直方向连线 (Sum/Weight): [行+1][列]
    // v_wire[0][j] 是输入，v_wire[32][j] 是这一列的最终输出
    wire signed [31:0] v_wire [0:ROW_NUM][0:COL_NUM-1];

    // =======================================================
    // 2. 端口解包与映射 (Unpacking)
    // =======================================================
    genvar i, j;
    
    generate
        // 连接最左侧输入 (Row Input -> h_wire[i][0])
        for (i = 0; i < ROW_NUM; i = i + 1) begin : row_io_map
            assign h_wire[i][0] = row_in_flat[4*i +: 4];
        end

        // 连接最顶层输入 (Col Input -> v_wire[0][j])
        for (j = 0; j < COL_NUM; j = j + 1) begin : col_input_map
            assign v_wire[0][j] = {24'd0, col_in_flat[8*j +: 8]};
        end

        // 连接最底层输出 (v_wire[32][j] -> Col Output)
        for (j = 0; j < COL_NUM; j = j + 1) begin : col_output_map
            assign col_out_flat[32*j +: 32] = v_wire[ROW_NUM][j];
        end
    endgenerate

    // =======================================================
    // 3. PE 阵列生成 (Systolic Grid Generation)
    // =======================================================
    

    generate
        for (i = 0; i < ROW_NUM; i = i + 1) begin : row_gen
            for (j = 0; j < COL_NUM; j = j + 1) begin : col_gen
                
                mac_pe u_pe (
                    .clk            (clk),
                    .rst_n          (rst_n),
                    .load_weight_en (load_weight_en),

                    // 水平连接：左进右出
                    .in_a           (h_wire[i][j]),
                    .out_a          (h_wire[i][j+1]),

                    // 垂直连接：上进下出
                    .in_sum         (v_wire[i][j]),
                    .out_sum        (v_wire[i+1][j])
                );
                
            end
        end
    endgenerate

endmodule