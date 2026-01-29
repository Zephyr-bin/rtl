`timescale 1ns/1ps

module tb_res;

    // =======================================================
    // 1. 参数定义
    // =======================================================
    parameter COL_NUM    = 32;
    parameter DATA_WIDTH = 16;
    parameter SKEW_DELAY = 31;
    parameter BANK_DEPTH = 2048;

    // =======================================================
    // 2. 信号声明
    // =======================================================
    reg clk;
    reg rst_n;
    reg start;
    
    // 输入
    reg [511:0] array_data_in;
    reg array_valid_in;

    // 输出
    wire bce0, bce1, bce2, bce3, bce4, bce5, bce6, bce7;
    wire [14:0] bwaddr0, bwaddr1, bwaddr2, bwaddr3, bwaddr4, bwaddr5, bwaddr6, bwaddr7;
    wire [127:0] bwdata0, bwdata1, bwdata2, bwdata3, bwdata4, bwdata5, bwdata6, bwdata7;

    integer i;

    // =======================================================
    // 3. DUT 例化
    // =======================================================
    res #(
        .COL_NUM(COL_NUM),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_DEPTH(BANK_DEPTH)
    ) u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .array_data_in(array_data_in),
        .array_valid_in(array_valid_in),
        
        .bce0(bce0), .bce1(bce1), .bce2(bce2), .bce3(bce3),
        .bce4(bce4), .bce5(bce5), .bce6(bce6), .bce7(bce7),
        
        .bwaddr0(bwaddr0), .bwaddr1(bwaddr1), .bwaddr2(bwaddr2), .bwaddr3(bwaddr3),
        .bwaddr4(bwaddr4), .bwaddr5(bwaddr5), .bwaddr6(bwaddr6), .bwaddr7(bwaddr7),
        
        .bwdata0(bwdata0), .bwdata1(bwdata1), .bwdata2(bwdata2), .bwdata3(bwdata3),
        .bwdata4(bwdata4), .bwdata5(bwdata5), .bwdata6(bwdata6), .bwdata7(bwdata7)
    );

    // =======================================================
    // 4. 时钟生成
    // =======================================================
    initial clk = 0;
    always #5 clk = ~clk;

    // =======================================================
    // 5. 核心任务：模拟脉动阵列的波浪输出
    // =======================================================
    // num_rows: 要发送的总行数 (例如 8 行)
    task drive_systolic_wave;
        input integer num_rows;
        integer t_step;
        integer row_idx;
        begin
            $display("Starting Systolic Wave Drive for %0d rows...", num_rows);
            
            // 在任务开始时，先同步到下一个时钟上升沿，确保从干净的状态开始
            @(posedge clk);
            
            // 脉动阵列的总活动时间 = 行数 + Skew时间 (31)
            // 我们多跑几拍以确保波形完整
            for (t_step = 0; t_step < num_rows + SKEW_DELAY + 5; t_step = t_step + 1) begin
                
                // --- 1. 生成 Valid 信号 ---
                // 使用非阻塞赋值 (<=)，信号会在当前时钟沿后更新，并保持到下一个时钟沿
                if (t_step < num_rows + SKEW_DELAY) 
                    array_valid_in <= 1'b1;
                else 
                    array_valid_in <= 1'b0;

                // --- 2. 生成 Skewed Data ---
                for (i = 0; i < COL_NUM; i = i + 1) begin
                    row_idx = t_step - i;

                    if (row_idx >= 0 && row_idx < num_rows) begin
                        array_data_in[i*DATA_WIDTH +: DATA_WIDTH] <= row_idx + 1;
                    end else begin
                        array_data_in[i*DATA_WIDTH +: DATA_WIDTH] <= 16'd0;
                    end
                end

                // [关键] 等待这一个时钟周期结束，迈向下一个周期
                @(posedge clk); 
            end
            
            // 结束后清零 (再过一拍)
            array_data_in <= 0;
            array_valid_in <= 0;
            @(posedge clk);
        end
    endtask

    // =======================================================
    // 6. 主测试流程
    // =======================================================
    initial begin
        $dumpfile("res.vcd");
        $dumpvars(0, tb_res);

        // 初始化
        rst_n = 0;
        start = 0;
        array_data_in = 0;
        array_valid_in = 0;

        // 复位释放
        #20 rst_n = 1;
        #10 start = 1; // 复位内部计数器和PingPang
        #10 start = 0;

        // --- 发送 8 行数据 ---
        // 期望结果：
        // 在大概 T=32 左右，SRAM 写入端口开始动作
        // 第一拍写入全 1
        // 第二拍写入全 2
        // ... 直到全 8
        drive_systolic_wave(8);

        #100;
        $finish;
    end
    
    // =======================================================
    // 7. 自动监控与打印
    // =======================================================
    // 监控 Bank0 的写入数据，看是否对齐
    always @(posedge clk) begin
        if (u_dut.aligned_valid) begin // 只有当模块认为对齐有效时才打印
            $display("[Time %0t] SRAM Write! Bank0 Data (Low 16b): %0d | Bank7 Data (Low 16b): %0d", 
                     $time, u_dut.bwdata0[15:0], u_dut.bwdata7[15:0]);
            
            // 检查对齐：Bank0 和 Bank7 的数据必须相等
            if (u_dut.bwdata0[15:0] !== u_dut.bwdata7[15:0]) begin
                $display("    ERROR: Mismatch! De-skew failed. Col 0 and Col 31 are not aligned.");
            end else begin
                $display("    OK: Data aligned.");
            end
        end
    end

endmodule