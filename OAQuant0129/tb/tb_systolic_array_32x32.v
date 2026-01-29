`timescale 1ns/1ps

module tb_systolic_array;

    // =======================================================
    // 1. 参数定义 (32x32)
    // =======================================================
    parameter ROW_NUM = 32;
    parameter COL_NUM = 32;
    
    parameter DATA_WIDTH_A = 4;   // 激活值位宽
    parameter DATA_WIDTH_W = 8;   // 权重输入位宽
    parameter DATA_WIDTH_P = 32;  // 累加和位宽
    
    parameter CLK_PERIOD = 10;    // 10ns 时钟周期

    // =======================================================
    // 2. 信号声明
    // =======================================================
    reg clk;
    reg rst_n;
    reg load_weight_en;

    // 扁平化的输入/输出信号
    reg  [ROW_NUM*DATA_WIDTH_A-1:0] row_in_flat;
    reg  [COL_NUM*DATA_WIDTH_W-1:0] col_in_flat;
    wire [COL_NUM*DATA_WIDTH_P-1:0] col_out_flat;

    // 模拟用的二维数组 (方便生成测试数据)
    // 激活数据: 模拟输入的时间序列 [Row][Time_Step]
    reg signed [DATA_WIDTH_A-1:0] mat_A [0:ROW_NUM-1][0:COL_NUM-1];
    // 权重数据: 模拟权重矩阵 [Row][Col]
    reg signed [DATA_WIDTH_W-1:0] mat_B [0:ROW_NUM-1][0:COL_NUM-1];

    integer i, j;

    // =======================================================
    // 3. DUT 例化
    // =======================================================
    systolic_array_32x32 #(
        .ROW_NUM(ROW_NUM),
        .COL_NUM(COL_NUM)
    ) u_dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .load_weight_en (load_weight_en),
        .row_in_flat    (row_in_flat),
        .col_in_flat    (col_in_flat), 
        .col_out_flat   (col_out_flat)
    );

    // =======================================================
    // 4. 时钟生成
    // =======================================================
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // =======================================================
    // 5. 数据生成任务
    // =======================================================
    task gen_data;
        begin
            // 生成权重矩阵 B (32x32)
            // 规则：从上到下，权重值 = 行号 % 8
            // 意味着第0行权重全是0，第1行全是1... 第8行又是0
            for(i=0; i<ROW_NUM; i=i+1) begin
                for(j=0; j<COL_NUM; j=j+1) begin
                    mat_B[i][j] = i % 8; 
                end
            end

            // 生成激活矩阵 A (32x32)
            // 规则：从左到右 (时间序列)，激活值 = 列号 % 8
            // 意味着所有 PE 第0次计算都乘0，第1次都乘1...
            for(i=0; i<ROW_NUM; i=i+1) begin
                for(j=0; j<COL_NUM; j=j+1) begin
                    mat_A[i][j] = j % 8;
                end
            end
        end
    endtask

    // =======================================================
    // 6. 权重加载任务 (模拟从上到下流动)
    // =======================================================
    task load_weights;
        integer t;
        begin
            $display("=== [Time %t] Starting Weight Loading (Top -> Bottom) ===", $time);
            load_weight_en = 1;
            row_in_flat = 0; // 加载权重时，水平输入保持为0
            
            // 脉动阵列权重是从顶部流入，流到底部。
            // 必须先推入最底层的权重 (Row 31)，最后推入最顶层的权重 (Row 0)
            for (t = ROW_NUM-1; t >= 0; t = t - 1) begin
                for (j = 0; j < COL_NUM; j = j + 1) begin
                    // 拼装这一拍的一行权重向量 (32个列)
                    // 取出 mat_B 中第 t 行的数据
                    col_in_flat[j*8 +: 8] = mat_B[t][j];
                end
                
                // 简单的打印监控
                if (t==0 || t==31) 
                    $display("  Loading Row %0d: Weight Val = %0d", t, mat_B[t][0]);

                @(posedge clk); // 等待时钟上升沿
            end
            
            // 加载完成
            load_weight_en = 0;
            col_in_flat = 0; // 计算阶段，垂直输入清零
            $display("=== [Time %t] Weight Loading Finished ===", $time);
        end
    endtask

    // =======================================================
    // 7. 计算任务 (模拟从左到右流动 + Skew)
    // =======================================================
    task start_compute;
        integer cycle;
        integer r;
        integer total_cycles; 
        begin
            $display("=== [Time %t] Starting Computation (Left -> Right with Skew) ===", $time);
            load_weight_en = 0;
            col_in_flat = 0;
            
            // 计算足够长的时间，让数据流过整个阵列
            // 32(流过行) + 32(流过列) + 缓冲
            total_cycles = ROW_NUM + COL_NUM + 10; 

            for (cycle = 0; cycle < total_cycles; cycle = cycle + 1) begin
                
                // 对每一行进行处理，模拟 Skew (阶梯状输入)
                for (r = 0; r < ROW_NUM; r = r + 1) begin
                    // Skew 逻辑：
                    // 第 0 行在 Cycle 0 开始输入
                    // 第 1 行在 Cycle 1 开始输入
                    // ...
                    // 第 r 行在 Cycle r 开始输入
                    
                    // 判断当前 cycle 是否处于第 r 行的有效数据窗口内
                    if (cycle >= r && cycle < (r + COL_NUM)) begin
                        // 计算当前应该是输入序列中的第几个数
                        // data_index = cycle - r
                        row_in_flat[r*4 +: 4] = mat_A[r][cycle - r];
                    end else begin
                        // 非有效时间窗口，补0
                        row_in_flat[r*4 +: 4] = 4'd0;
                    end
                end
                
                // 打印监控：第一行的输入变化
                if (cycle < 10)
                    $display("  Cycle %0d: Row 0 Input = %0d", cycle, $signed(row_in_flat[3:0]));

                @(posedge clk); // 等待时钟
            end
            $display("=== [Time %t] Computation Finished ===", $time);
        end
    endtask

    // =======================================================
    // 8. 主流程
    // =======================================================
    initial begin
        // 配置波形输出，生成 vcd 文件
        $dumpfile("systolic_32x32.vcd");
        $dumpvars(0, tb_systolic_array);

        // 1. 初始化
        rst_n = 0;
        load_weight_en = 0;
        row_in_flat = 0;
        col_in_flat = 0;
        
        // 2. 生成测试数据
        gen_data(); 

        // 3. 复位释放
        #20 rst_n = 1;
        #20;

        // 4. 加载权重
        load_weights();
        
        // 插入一些气泡(Idle)
        #20;

        // 5. 开始计算
        start_compute();

        // 6. 结束仿真
        #100;
        $finish;
    end

endmodule