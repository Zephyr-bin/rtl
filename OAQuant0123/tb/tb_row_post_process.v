`timescale 1ns/1ps

module tb_row_post_process;

    // =======================================================
    // 1. 参数定义
    // =======================================================
    parameter COL_NUM = 32;
    parameter BIT_WIDTH_IN = 32;
    parameter BIT_WIDTH_SCALE = 16;
    parameter BIT_WIDTH_OUT = 16;

    // =======================================================
    // 2. 信号声明
    // =======================================================
    reg clk;
    reg rst_n;
    reg [COL_NUM*BIT_WIDTH_IN-1:0] sys_array_out_32b;
    reg array_out_valid;
    reg [COL_NUM*BIT_WIDTH_SCALE-1:0] col_scale_factors;
    
    wire [COL_NUM*BIT_WIDTH_OUT-1:0] fp16_out_diagonal;
    wire fp16_valid_diagonal;

    integer i, t;

    // =======================================================
    // 3. FP16 查找表 (0.0 ~ 31.0)
    // =======================================================
    reg [15:0] fp16_lut [0:31];

    initial begin
        // 预先计算好的 FP16 (IEEE 754 Half Precision) 十六进制值
        fp16_lut[0]  = 16'h0000; // 0.0
        fp16_lut[1]  = 16'h3c00; // 1.0
        fp16_lut[2]  = 16'h4000; // 2.0
        fp16_lut[3]  = 16'h4200; // 3.0
        fp16_lut[4]  = 16'h4400; // 4.0
        fp16_lut[5]  = 16'h4500; // 5.0
        fp16_lut[6]  = 16'h4600; // 6.0
        fp16_lut[7]  = 16'h4700; // 7.0
        fp16_lut[8]  = 16'h4800; // 8.0
        fp16_lut[9]  = 16'h4880; // 9.0
        fp16_lut[10] = 16'h4900; // 10.0
        fp16_lut[11] = 16'h4980; // 11.0
        fp16_lut[12] = 16'h4a00; // 12.0
        fp16_lut[13] = 16'h4a80; // 13.0
        fp16_lut[14] = 16'h4b00; // 14.0
        fp16_lut[15] = 16'h4b80; // 15.0
        fp16_lut[16] = 16'h4c00; // 16.0
        fp16_lut[17] = 16'h4c40; // 17.0
        fp16_lut[18] = 16'h4c80; // 18.0
        fp16_lut[19] = 16'h4cc0; // 19.0
        fp16_lut[20] = 16'h4d00; // 20.0
        fp16_lut[21] = 16'h4d40; // 21.0
        fp16_lut[22] = 16'h4d80; // 22.0
        fp16_lut[23] = 16'h4dc0; // 23.0
        fp16_lut[24] = 16'h4e00; // 24.0
        fp16_lut[25] = 16'h4e40; // 25.0
        fp16_lut[26] = 16'h4e80; // 26.0
        fp16_lut[27] = 16'h4ec0; // 27.0
        fp16_lut[28] = 16'h4f00; // 28.0
        fp16_lut[29] = 16'h4f40; // 29.0
        fp16_lut[30] = 16'h4f80; // 30.0
        fp16_lut[31] = 16'h4fc0; // 31.0
    end

    // =======================================================
    // 4. DUT 例化
    // =======================================================
    row_post_process #(
        .COL_NUM(COL_NUM)
    ) u_dut (
        .clk                 (clk),
        .rst_n               (rst_n),
        .sys_array_out_32b   (sys_array_out_32b),
        .array_out_valid     (array_out_valid),
        .col_scale_factors   (col_scale_factors),
        .fp16_out_diagonal   (fp16_out_diagonal),
        .fp16_valid_diagonal (fp16_valid_diagonal)
    );

    // =======================================================
    // 5. 时钟生成
    // =======================================================
    initial clk = 0;
    always #5 clk = ~clk;

    // =======================================================
    // 6. 辅助任务
    // =======================================================
    task config_scales;
        begin
            for (i = 0; i < COL_NUM; i = i + 1) begin
                // [关键修改] 从 LUT 中获取正确的 FP16 码
                // 而不是直接把整数 i 赋进去
                col_scale_factors[i*BIT_WIDTH_SCALE +: BIT_WIDTH_SCALE] = fp16_lut[i];
            end
            $display("Configuration: Scale factors set to FP16(0.0) ... FP16(31.0)");
        end
    endtask

    task drive_data;
        begin
            $display("Starting Data Driver...");
            for (t = 1; t <= 10; t = t + 1) begin
                array_out_valid = 1;
                for (i = 0; i < COL_NUM; i = i + 1) begin
                    // 输入还是整数，假设 scale_unit 内部会处理 int -> fp 的转换
                    sys_array_out_32b[i*BIT_WIDTH_IN +: BIT_WIDTH_IN] = t[31:0];
                end
                $display("  Time %0t: Input All Cols = %0d", $time, t);
                @(posedge clk);
            end
            array_out_valid = 0;
            sys_array_out_32b = 0;
            $display("Data Driver Finished.");
        end
    endtask

    // =======================================================
    // 7. 主测试流程
    // =======================================================
    initial begin
        $dumpfile("post_process.vcd");
        $dumpvars(0, tb_row_post_process);

        rst_n = 0;
        sys_array_out_32b = 0;
        array_out_valid = 0;
        col_scale_factors = 0;

        #20 rst_n = 1;
        
        config_scales();
        #10;

        drive_data();

        #100;
        $finish;
    end
    
    // =======================================================
    // 8. 输出监控
    // =======================================================
    
    wire [15:0] monitor_col_1  = fp16_out_diagonal[31:16];     // 第1列 (Scale=1.0)
    wire [15:0] monitor_col_10 = fp16_out_diagonal[175:160];   // 第10列 (Scale=10.0)

    always @(posedge clk) begin
        if (fp16_valid_diagonal) begin
            $display("    [Output Valid] Time %0t: Col_1(in*1.0)=%h, Col_10(in*10.0)=%h", 
                     $time, monitor_col_1, monitor_col_10);
        end
    end

endmodule