`timescale 1ns/1ps

module tb_sto;

    // =======================================================
    // 1. 参数与信号定义
    // =======================================================
    reg clk;
    reg rst_n;
    reg start;
    reg [11:0] tran_time; // 设置为 32

    // 激活数据读取接口 (Bank 0-3) - 假设位宽是 64bit (根据你的 sto 代码)
    reg [63:0] brdata_0, brdata_1, brdata_2, brdata_3;
    reg brvalid_0, brvalid_1, brvalid_2, brvalid_3;

    // 输出观测 - 假设 act_pe_o 是 128bit (根据你的 sto 代码)
    wire act_pe_valid;
    wire [127:0] act_pe_o;
    
    // Act Bank 控制信号
    wire bce_0, bce_1, bce_2, bce_3;
    wire [14:0] braddr_0, braddr_1, braddr_2, braddr_3;
    
    // Weight Bank 控制信号
    wire bce_4, bce_5, bce_6, bce_7;
    wire [14:0] braddr_4, braddr_5, braddr_6, braddr_7;

    // =======================================================
    // 2. DUT (Device Under Test) 例化
    // =======================================================
    sto u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .tran_time(tran_time),
        
        // Output to Array
        .act_pe_valid(act_pe_valid),
        .act_pe_o(act_pe_o),
        
        // SRAM Act Banks (0-3)
        .bce_0(bce_0), .bce_1(bce_1), .bce_2(bce_2), .bce_3(bce_3),
        .braddr_0(braddr_0), .braddr_1(braddr_1), .braddr_2(braddr_2), .braddr_3(braddr_3),
        .brdata_0(brdata_0), .brdata_1(brdata_1), .brdata_2(brdata_2), .brdata_3(brdata_3),
        .brvalid_0(brvalid_0), .brvalid_1(brvalid_1), .brvalid_2(brvalid_2), .brvalid_3(brvalid_3),
        
        // SRAM Weight Banks (4-7)
        .bce_4(bce_4), .bce_5(bce_5), .bce_6(bce_6), .bce_7(bce_7),
        .braddr_4(braddr_4), .braddr_5(braddr_5), .braddr_6(braddr_6), .braddr_7(braddr_7)
    );

    // =======================================================
    // 3. 时钟生成
    // =======================================================
    initial clk = 0;
    always #5 clk = ~clk; // 10ns 周期

    // =======================================================
    // 4. 模拟 SRAM 行为 (Mock SRAM)
    // =======================================================
    // 简单的行为模型：收到地址后，延迟 1 拍返回数据
    // 返回的数据只是简单的 {地址} 拼接，方便波形观察
    
    always @(posedge clk) begin
        // --- Bank 0 (Act) ---
        if (bce_0) begin
            brvalid_0 <= 1'b1;
            // 拼凑 64bit 数据：高位放Bank号，低位放地址
            brdata_0  <= {16'hB000, 32'd0, 1'b0, braddr_0}; 
        end else begin
            brvalid_0 <= 1'b0;
            brdata_0  <= 64'd0;
        end

        // --- Bank 1 (Act) ---
        if (bce_1) begin
            brvalid_1 <= 1'b1;
            brdata_1  <= {16'hB001, 32'd0, 1'b0, braddr_1};
        end else begin
            brvalid_1 <= 1'b0;
            brdata_1  <= 64'd0;
        end

        // --- Bank 2 (Act) ---
        if (bce_2) begin
            brvalid_2 <= 1'b1;
            brdata_2  <= {16'hB002, 32'd0, 1'b0, braddr_2};
        end else begin
            brvalid_2 <= 1'b0;
            brdata_2  <= 64'd0;
        end

        // --- Bank 3 (Act) ---
        if (bce_3) begin
            brvalid_3 <= 1'b1;
            brdata_3  <= {16'hB003, 32'd0, 1'b0, braddr_3};
        end else begin
            brvalid_3 <= 1'b0;
            brdata_3  <= 64'd0;
        end
    end

    // =======================================================
    // 5. 主测试流程
    // =======================================================
    initial begin
        $dumpfile("sto_32x32.vcd");
        $dumpvars(0, tb_sto);

        // 初始化
        rst_n = 0;
        start = 0;
        tran_time = 12'd32; // 设置传输时间为 32
        
        brdata_0 = 0; brvalid_0 = 0;
        brdata_1 = 0; brvalid_1 = 0;
        brdata_2 = 0; brvalid_2 = 0;
        brdata_3 = 0; brvalid_3 = 0;

        // 1. 复位
        #20 rst_n = 1;
        #20;

        // 2. 启动 STO (Weight Phase -> Act Phase)
        $display("Time %t: Asserting START", $time);
        start = 1;
        #10 start = 0;

        // 3. 观察权重加载阶段 (Weight Phase)
        // 你的 u_weight 模块应该会先工作，拉高 bce_4 ~ bce_7
        $display("Time %t: Waiting for Weight Loading to finish...", $time);
        
        // 等待内部信号 weight_load_done 拉高 (这需要你的 u_weight 逻辑正确)
        // 如果 u_weight 还没接好，这里可能会卡住，或者你需要手动 force
        // 假设正常流程：
        wait(u_dut.weight_load_done == 1);
        $display("Time %t: Weight Loading Done detected!", $time);

        // 4. 观察激活传输阶段 (Act Phase)
        // 此时 u_act 应该开始工作，bce_0 ~ bce_3 跳变
        // 并且 SRAM 会返回 brvalid，最终 act_pe_valid 拉高
        $display("Time %t: Watching Act Phase...", $time);
        
        // 等待第一次输出有效
        wait(act_pe_valid);
        $display("Time %t: ACT_PE_VALID detected! First Data Output.", $time);

        // 让它跑完设定的 tran_time (32) + Skew (31) 
        // 稍微给多一点时间
        #1000;
        
        $display("Time %t: Simulation Finished", $time);
        $finish;
    end

    // 简单的监控
    always @(posedge clk) begin
        if (act_pe_valid) begin
            // 打印部分输出数据验证
            // $display("Time %t: Output Valid. Data[31:0]=%h", $time, act_pe_o[31:0]);
        end
    end

endmodule