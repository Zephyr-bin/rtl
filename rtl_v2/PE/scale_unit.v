module scale_unit (
    input wire clk,
    input wire rst_n,
    input wire signed [31:0] int_in,    // 来自脉动阵列的累加和
    input wire [15:0] fp16_scale,       // 缩放因子
    output reg [15:0] fp16_out          // 最终结果
);

    // ============================================================
    // Stage 1: 解析与乘法 (Prepare & Multiply)
    // ============================================================
    reg s1_sign_final;
    reg [42:0] s1_product;
    reg [4:0]  s1_scale_exp;
    reg s1_is_zero;
    
    // 【修复1】abs_int 改为 wire (组合逻辑)，确保乘法能立即用到当前值
    wire [31:0] abs_int;
    wire [10:0] scale_mant;

    // 组合逻辑计算绝对值
    assign abs_int = int_in[31] ? (~int_in + 1) : int_in;
    // 组合逻辑提取尾数
    assign scale_mant = {1'b1, fp16_scale[9:0]};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1_sign_final <= 0;
            s1_product    <= 0;
            s1_scale_exp  <= 0;
            s1_is_zero    <= 1;
        end else begin
            // 1. 符号处理
            s1_sign_final <= int_in[31] ^ fp16_scale[15];
            
            // 2. 核心乘法 (现在 abs_int 是 wire，乘法会正确使用当前拍的绝对值)
            s1_product <= abs_int * scale_mant;
            
            // 3. 保存指数
            s1_scale_exp <= fp16_scale[14:10];
            
            // 4. 零检查
            if (int_in == 0 || fp16_scale[14:0] == 0) 
                s1_is_zero <= 1;
            else 
                s1_is_zero <= 0;
        end
    end

    // ============================================================
    // Stage 2: 归一化 (Normalize - Find MSB)
    // ============================================================
    reg [5:0] s2_msb_idx;
    reg [42:0] s2_product;
    reg s2_sign;
    reg [4:0] s2_scale_exp;
    reg s2_is_zero;
    
    integer i;
    reg [5:0] msb_temp;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            s2_msb_idx <= 0;
            s2_product <= 0;
            s2_sign    <= 0;
            s2_scale_exp <= 0;
            s2_is_zero <= 0;
        end else begin
            msb_temp = 0;
            // 寻找最高位 (Priority Encoder)
            for (i = 0; i < 43; i = i + 1) begin
                if (s1_product[i]) msb_temp = i[5:0];
            end
            s2_msb_idx <= msb_temp;
            
            s2_product <= s1_product;
            s2_sign    <= s1_sign_final;
            s2_scale_exp <= s1_scale_exp;
            s2_is_zero <= s1_is_zero;
        end
    end

    // ============================================================
    // Stage 3: 组包 (Pack Result)
    // ============================================================
    
    // 【修复2】将中间变量定义为 reg，但在 always @(*) 块中计算
    // 这告诉综合器：这些是纯组合逻辑连线
    reg signed [9:0] final_exp_comb;
    reg [9:0] final_mant_comb;

    // --- 组合逻辑块：计算指数和尾数 ---
    always @(*) begin
        // 默认值防止锁存器 (Latch)
        final_exp_comb = 0;
        final_mant_comb = 0;

        // 计算指数
        final_exp_comb = s2_scale_exp + s2_msb_idx - 10;
        
        // 提取尾数
        if (s2_msb_idx >= 10)
            final_mant_comb = s2_product[s2_msb_idx-1 -: 10]; 
        else
            final_mant_comb = s2_product << (10 - s2_msb_idx); 
    end

    // --- 时序逻辑块：只负责更新寄存器 fp16_out ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fp16_out <= 16'd0;
            // 注意：不要在这里复位 final_exp_comb，因为它是组合逻辑
        end else begin
            if (s2_is_zero) begin
                fp16_out <= 16'd0;
            end else begin
                // 使用组合逻辑计算出的结果进行判断和赋值
                
                // 溢出与下溢处理
                if (final_exp_comb >= 31) begin 
                    // 溢出 -> Infinity
                    fp16_out <= {s2_sign, 5'b11111, 10'b0}; 
                end else if (final_exp_comb <= 0) begin
                    // 下溢 -> Zero
                    fp16_out <= {s2_sign, 15'b0};
                end else begin
                    // 正常值
                    fp16_out <= {s2_sign, final_exp_comb[4:0], final_mant_comb};
                end
            end
        end
    end

endmodule