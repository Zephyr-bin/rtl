module top_compute_core (
    input wire clk,
    input wire rst_n,
    
    // --- 全局控制 ---
    input wire start_calc,       // 这是一个脉冲，指示计算开始 (用于复位 Res 模块的写地址)
    input wire pingpang,         // 0: 写 Bank0-3; 1: 写 Bank4-7
    input wire [15:0] global_scale, // 量化缩放因子 (FP16)

    // --- 数据输入 ---
    // 激活输入 (来自 Act 模块/SRAM)
    input wire [127:0] act_data_in,   // 32行 * 4bit
    input wire act_pe_valid,        // 指示当前输入的激活数据有效 (关键信号!)

    // // 权重/部分和输入 (来自 Weight 模块/SRAM)
    // input wire [1023:0] weight_in,    // 32列 * 32bit

    input wire brvalid_4,
    input wire brvalid_5,
    input wire brvalid_6,
    input wire brvalid_7,
    input wire [63:0] brdata_4,
    input wire [63:0] brdata_5,
    input wire [63:0] brdata_6,
    input wire [63:0] brdata_7,


    // --- SRAM 写回接口 (连接到 SRAM Wrapper) ---
    output wire bce_8, bce_9, bce_10, bce_11, bce_12, bce_13, bce_14, bce_15,
    // output wire [1:0] bwren_8, bwren_9, bwren_10, bwren_11, bwren_12, bwren_13, bwren_14, bwren_15,
    output wire [14:0] bwaddr_8, bwaddr_9, bwaddr_10, bwaddr_11, bwaddr_12, bwaddr_13, bwaddr_14, bwaddr_15,
    output wire [127:0] bwdata_8, bwdata_9, bwdata_10, bwdata_11, bwdata_12, bwdata_13, bwdata_14, bwdata_15
);




    // ============================================================
    // 0. 权重多路选择器 (Weight MUX) - 负责处理离群点
    // ============================================================
    wire [255:0] array_col;
    wire [63:0] weight_data0;
    wire [63:0] weight_data1;
    wire w_brvalid;
    reg w_brvalid_ff1;
    reg [3:0] outlier_sel;
    reg [23:0] outlier_addr;
    reg load_weight_en;

    assign weight_data0 = brvalid_4 ? brdata_4 : (brvalid_6 ? brdata_6 : 64'd0);
    assign weight_data1 = brvalid_5 ? brdata_5 : (brvalid_7 ? brdata_7 : 64'd0);
    assign w_brvalid = brvalid_4 | brvalid_6;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_brvalid_ff1 <= 1'b0;
            load_weight_en <= 1'b0;
        end else begin
            w_brvalid_ff1 <= w_brvalid;
            load_weight_en <= w_brvalid_ff1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            outlier_sel <= 4'd0;
            outlier_addr <= 24'd0;
        end else begin
            outlier_sel <= 4'b1001;
            outlier_addr <= 24'b111001_000000_000000_010101;
        end
    end

    weight_mux u_weight_mux_0 (
        .clk(clk),
        .rst_n(rst_n),
        .weight_0 (weight_data0[3:0]),
        .weight_1 (weight_data0[7:4]),
        .weight_2 (weight_data0[11:8]),
        .weight_3 (weight_data0[15:12]),
        .weight_4 (weight_data0[19:16]),
        .weight_5 (weight_data0[23:20]),
        .weight_6 (weight_data0[27:24]),
        .weight_7 (weight_data0[31:28]),
        .sel      (outlier_sel[0]),
        .addr     (outlier_addr[5:0]),
        .weight_o0(array_col[7:0]),
        .weight_o1(array_col[15:8]),
        .weight_o2(array_col[23:16]),
        .weight_o3(array_col[31:24]),
        .weight_o4(array_col[39:32]),
        .weight_o5(array_col[47:40]),
        .weight_o6(array_col[55:48]),
        .weight_o7(array_col[63:56])        
    );

    weight_mux u_weight_mux_1 (
        .clk(clk),
        .rst_n(rst_n),
        .weight_0 (weight_data0[35:32]),
        .weight_1 (weight_data0[39:36]),
        .weight_2 (weight_data0[43:40]),
        .weight_3 (weight_data0[47:44]),
        .weight_4 (weight_data0[51:48]),
        .weight_5 (weight_data0[55:52]),
        .weight_6 (weight_data0[59:56]),
        .weight_7 (weight_data0[63:60]),
        .sel      (outlier_sel[1]),
        .addr     (outlier_addr[11:6]),
        .weight_o0(array_col[71:64]),
        .weight_o1(array_col[79:72]),
        .weight_o2(array_col[87:80]),
        .weight_o3(array_col[95:88]),
        .weight_o4(array_col[103:96]),
        .weight_o5(array_col[111:104]),
        .weight_o6(array_col[119:112]),
        .weight_o7(array_col[127:120])        
    );

    weight_mux u_weight_mux_2 (
        .clk(clk),
        .rst_n(rst_n),
        .weight_0 (weight_data1[3:0]),
        .weight_1 (weight_data1[7:4]),
        .weight_2 (weight_data1[11:8]),
        .weight_3 (weight_data1[15:12]),
        .weight_4 (weight_data1[19:16]),
        .weight_5 (weight_data1[23:20]),
        .weight_6 (weight_data1[27:24]),
        .weight_7 (weight_data1[31:28]),
        .sel      (outlier_sel[2]),
        .addr     (outlier_addr[17:12]),
        .weight_o0(array_col[135:128]),
        .weight_o1(array_col[143:136]),
        .weight_o2(array_col[151:144]),
        .weight_o3(array_col[159:152]),
        .weight_o4(array_col[167:160]),
        .weight_o5(array_col[175:168]),
        .weight_o6(array_col[183:176]),
        .weight_o7(array_col[191:184])        
    );

    weight_mux u_weight_mux_3 (
        .clk(clk),
        .rst_n(rst_n),
        .weight_0 (weight_data1[35:32]),
        .weight_1 (weight_data1[39:36]),
        .weight_2 (weight_data1[43:40]),
        .weight_3 (weight_data1[47:44]),
        .weight_4 (weight_data1[51:48]),
        .weight_5 (weight_data1[55:52]),
        .weight_6 (weight_data1[59:56]),
        .weight_7 (weight_data1[63:60]),
        .sel      (outlier_sel[3]),
        .addr     (outlier_addr[23:18]),
        .weight_o0(array_col[199:192]),
        .weight_o1(array_col[207:200]),
        .weight_o2(array_col[215:208]),
        .weight_o3(array_col[223:216]),
        .weight_o4(array_col[231:224]),
        .weight_o5(array_col[239:232]),
        .weight_o6(array_col[247:240]),
        .weight_o7(array_col[255:248])        
    );


    // =======================================================
    // 1. 生成阵列输出的 Valid 信号 (Latency Compensation)
    // =======================================================
    // 脉动阵列高度为 32。部分和从顶部流到底部需要 32 个周期。
    // 如果 T0 时刻激活数据有效，那么 T32 时刻阵列底部的输出才有效。
    
    reg [31:0] valid_shift_reg;
    wire array_out_valid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_shift_reg <= 32'd0;
        end else begin
            // 移位寄存器：输入进 [0]，输出取 [31]
            // 注意：只有在非权重加载模式(计算模式)下，激活数据的 valid 才有意义
            if (!load_weight_en)
                valid_shift_reg <= {valid_shift_reg[30:0], act_pe_valid};
            else
                valid_shift_reg <= 32'd0; // 加载权重时不产生计算 valid
        end
    end
    
    // 延迟 32 拍后的 Valid 信号
    assign array_out_valid = valid_shift_reg[31];


    // =======================================================
    // 2. 实例化脉动阵列 (The Core)
    // =======================================================
    wire [1023:0] sys_out_int32; // 32*32 bit 原始输出

    systolic_array_32x32 u_array (
        .clk            (clk),
        .rst_n          (rst_n),
        .load_weight_en (load_weight_en),
        
        // 激活输入 (32行 x 4bit)
        .row_in_flat    (act_data_in), 
        
        // 权重输入 (32列 x 32bit)
        .col_in_flat    (array_col),
        
        // 结果输出 (32列 x 32bit) - 此时是斜的
        .col_out_flat   (sys_out_int32)
    );


    // =======================================================
    // 3. 实例化后处理模块 (Quantization / Scaling)
    // =======================================================
    // 功能：INT32 (斜) -> FP16 (斜)
    // 延迟：3 级流水线
    
    wire [511:0] post_out_fp16; // 32*16 bit 缩放后输出
    wire post_out_valid;        // 经过流水线延迟后的 valid

    row_post_process u_post_process (
        .clk                 (clk),
        .rst_n               (rst_n),
        
        // 数据通路
        .sys_array_out_32b   (sys_out_int32),
        .array_out_valid     (array_out_valid), // 使用我们手动延迟 32 拍的信号
        
        // 配置
        .global_scale_factor (global_scale),
        
        // 输出
        .fp16_out_diagonal   (post_out_fp16),
        .fp16_valid_diagonal (post_out_valid)   // 这是自动再延时 3 拍后的信号
    );


    // =======================================================
    // 4. 实例化写回模块 (De-skew / Res)
    // =======================================================
    // 功能：FP16 (斜) -> FP16 (齐) -> SRAM
    // 延迟：反向三角形延时 (0~31拍)
    
    res u_res (
        .clk            (clk),
        .rst_n          (rst_n),
        .start          (start_calc), // 用于复位写地址计数器
        .pingpang       (pingpang),
        
        // 接收缩放后的数据和 Valid
        .array_data_in  (post_out_fp16),
        .array_valid_in (post_out_valid), // 完美衔接
        
        // SRAM 写接口
        .bce0(bce_8), .bce1(bce_9), .bce2(bce_10), .bce3(bce_11),
        .bce4(bce_12), .bce5(bce_13), .bce6(bce_14), .bce7(bce_15),
        
        .bwaddr0(bwaddr_8), .bwaddr1(bwaddr_9), .bwaddr2(bwaddr_10), .bwaddr3(bwaddr_11),
        .bwaddr4(bwaddr_12), .bwaddr5(bwaddr_13), .bwaddr6(bwaddr_14), .bwaddr7(bwaddr_15),
        
        .bwdata0(bwdata_8), .bwdata1(bwdata_9), .bwdata2(bwdata_10), .bwdata3(bwdata_11),
        .bwdata4(bwdata_12), .bwdata5(bwdata_13), .bwdata6(bwdata_14), .bwdata7(bwdata_15)
    );

endmodule