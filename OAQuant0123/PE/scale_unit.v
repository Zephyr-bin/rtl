module scale_unit (
    input wire clk,
    input wire rst_n,
    input wire signed [31:0] int_in,    // 32-bit Integer
    input wire [15:0] fp16_scale,       // FP16 Scale
    output reg [15:0] fp16_out          // FP16 Result
);

    // ============================================================
    // Stage 1: 解析与乘法 (Prepare & Multiply)
    // ============================================================
    reg s1_sign_final;
    reg [42:0] s1_product; // 32bit * 11bit = 43bit
    reg [4:0]  s1_scale_exp;
    reg s1_is_zero;
    
    // [修复1] abs_int 改为 wire，确保乘法在当拍进行
    wire [31:0] abs_int;
    wire [10:0] scale_mant;
    
    // 组合逻辑计算绝对值
    assign abs_int = (int_in[31]) ? (~int_in + 1) : int_in;

    // [优化] 处理 FP16 的隐含位 (Hidden Bit)
    // 如果指数为0 (非规格化数)，隐含位为0；否则为1
    wire exp_is_zero = (fp16_scale[14:10] == 5'd0);
    assign scale_mant = { ~exp_is_zero, fp16_scale[9:0] };

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1_sign_final <= 0;
            s1_product    <= 0;
            s1_scale_exp  <= 0;
            s1_is_zero    <= 1;
        end else begin
            // 1. 符号处理
            s1_sign_final <= int_in[31] ^ fp16_scale[15];
            
            // 2. 核心乘法 (现在 abs_int 和 scale_mant 都是基于当前输入的 wire)
            s1_product <= abs_int * scale_mant;
            
            // 3. 保存指数
            // 如果是非规格化数，指数虽然码值是0，但实际权重是 2^-14 (同指数为1时)，
            // 为了简化逻辑，这里保持 0，后续计算 exp 时补偿
            s1_scale_exp <= fp16_scale[14:10];
            
            // 4. 零检查 (输入为0 或 Scale为纯0)
            if (int_in == 0 || (fp16_scale[14:0] == 0)) 
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
    
    integer k;
    reg [5:0] msb_temp;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            s2_msb_idx <= 0;
            s2_product <= 0;
            s2_sign    <= 0;
            s2_scale_exp <= 0;
            s2_is_zero <= 0;
        end else begin
            // 寻找最高有效位 (Priority Encoder)
            msb_temp = 0;
            for (k = 0; k < 43; k = k + 1) begin
                if (s1_product[k]) msb_temp = k[5:0];
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
    reg signed [9:0] final_exp;
    reg [9:0] final_mant;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fp16_out <= 16'd0;
        end else begin
            if (s2_is_zero) begin
                fp16_out <= 16'd0;
            end else begin
                // 指数计算公式推导：
                // Value = (Product) * 2^(-10) * 2^(E_scale - 15)
                // Product ~= 1.M * 2^MSB
                // Value ~= 1.M * 2^(MSB - 10 + E_scale - 15)
                // New_Exp_Biased = (MSB - 10 + E_scale - 15) + 15 = MSB + E_scale - 10
                
                // 处理非规格化输入的指数补偿 (如果 s2_scale_exp 是 0，它实际上代表 1 的权重)
                if (s2_scale_exp == 0)
                    final_exp = s2_msb_idx + 1 - 10;
                else
                    final_exp = s2_scale_exp + s2_msb_idx - 10;
                
                // 提取尾数 (截断处理)
                // 我们需要 MSB 之后的 10 位
                if (s2_msb_idx >= 10)
                    // 从 MSB-1 开始取 10 位
                    final_mant = s2_product[s2_msb_idx-1 -: 10]; 
                else
                    // 如果位数不够，左移补零
                    final_mant = s2_product << (10 - s2_msb_idx); 
                
                // 结果输出 (饱和处理)
                if (final_exp >= 31) begin 
                    // Overflow -> Infinity
                    fp16_out <= {s2_sign, 5'b11111, 10'b0}; 
                end else if (final_exp <= 0) begin
                    // Underflow -> Zero (简化处理，不生成 Denormal)
                    fp16_out <= {s2_sign, 15'b0};
                end else begin
                    // Normal
                    fp16_out <= {s2_sign, final_exp[4:0], final_mant};
                end
            end
        end
    end

endmodule