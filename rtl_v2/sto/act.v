module act(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire pingpang,
    input wire [12:0] trantime, // 总节拍数 = 矩阵行数(64) + Skew深度(31)
    
    // Request Side: SRAM Address & Control
    output reg bce0, bce1, bce2, bce3,
    output reg [14:0] braddr0, braddr1, braddr2, braddr3,
    
    // Response Side: SRAM Data & Valid
    input wire [63:0] brdata0, brdata1, brdata2, brdata3,
    input wire brvalid0, brvalid1, brvalid2, brvalid3,

    // Output to Systolic Array
    output wire [127:0] act_out_skewed,
    output reg act_out_valid // [新增] 指示阵列这一拍数据有效
);

    parameter ROW_NUM    = 32;
    parameter DATA_WIDTH = 4;
    parameter SKEW_DELAY = ROW_NUM - 1; // 31

    // 计算纯数据行数减1：trantime(95) - skew(32) = 63
    wire [12:0] matrix_rows = trantime - ROW_NUM;

    // ============================================================
    // PART 1: 请求域 (Request Domain) - 负责发地址
    // ============================================================
    reg [12:0] req_cnt;
    reg req_busy;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            req_busy <= 1'b0;
            req_cnt <= 13'd0;
            {bce0, bce1, bce2, bce3} <= 4'b0;
            braddr0 <= 15'd0; braddr1 <= 15'd0;
            braddr2 <= 15'd0; braddr3 <= 15'd0;
        end else begin
            // 默认拉低
            {bce0, bce1, bce2, bce3} <= 4'b0;

            if (start) begin
                req_busy <= 1'b1;
                req_cnt <= 13'd0;
            end else if (req_busy) begin
                // 发送请求
                if (req_cnt != matrix_rows) begin // 只发 64 次请求
                    // 地址逻辑
                    if (!pingpang) begin
                        bce0 <= 1'b1; bce1 <= 1'b1;
                        braddr0 <= {req_cnt[11:0], 3'b000}; 
                        braddr1 <= {req_cnt[11:0], 3'b000};
                    end else begin
                        bce2 <= 1'b1; bce3 <= 1'b1;
                        braddr2 <= {req_cnt[11:0], 3'b000};
                        braddr3 <= {req_cnt[11:0], 3'b000};
                    end
                    req_cnt <= req_cnt + 1'b1;
                end else begin
                    // 64次请求发完了，请求域任务结束
                    req_busy <= 1'b0; 
                end
            end
        end
    end

    // ============================================================
    // PART 2: 响应域 (Response Domain) - 负责收数据 & 补零
    // ============================================================
    
    // 2.1 产生统一的 valid 信号
    wire current_sram_valid;
    assign current_sram_valid = brvalid0 | brvalid2;

    // 2.2 接收计数器 & 状态机
    reg [12:0] recv_cnt;  // 记录收到了多少个真实数据 (0~64)
    reg [4:0] drain_cnt; // 记录补了多少个零 (0~31)
    reg draining;         // 状态标志：是否处于补零阶段

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            recv_cnt <= 13'd0;
            drain_cnt <= 5'd0;
            draining <= 1'b0;
            act_out_valid <= 1'b0;
        end else begin
            if (start) begin
                recv_cnt <= 13'd0;
                drain_cnt <= 5'd0;
                draining <= 1'b0;
                act_out_valid <= 1'b0;
            end else begin
                // 逻辑优先级：
                // 1. 如果有 SRAM 数据回来 -> 接收并输出
                // 2. 如果 SRAM 数据收齐了 (recv_cnt == 64) -> 进入 Drain 模式输出 0
                // 3. 如果 Drain 也完了 -> 停止输出
                
                if (current_sram_valid && (recv_cnt < matrix_rows)) begin
                    // 收到真实数据
                    recv_cnt <= recv_cnt + 1'b1;
                    act_out_valid <= 1'b1; 
                end 
                else if (recv_cnt >= matrix_rows && drain_cnt < SKEW_DELAY) begin
                    // 真实数据收够了，开始 Drain (补零阶段)
                    draining <= 1'b1;
                    drain_cnt <= drain_cnt + 1'b1;
                    act_out_valid <= 1'b1; // 虽然数据是0，但对阵列来说是有效的推进
                end 
                else begin
                    // 既没有数据，也不需要补零 (或者还没开始)
                    act_out_valid <= 1'b0;
                    draining <= 1'b0; // Drain 结束
                end
            end
        end
    end

    // 2.3 数据选择逻辑 (Mux)
    reg [127:0] data_to_skew;

    always @(*) begin
        if (current_sram_valid) begin
            // 有真实数据回来，直接选 SRAM 数据
            if (!pingpang) data_to_skew = {brdata1, brdata0};
            else           data_to_skew = {brdata3, brdata2};
        end else if (draining) begin
            // 补零阶段，强制为 0
            data_to_skew = 128'd0;
        end else begin
            // IDLE 状态，保持 0 或保持不变均可
            data_to_skew = 128'd0;
        end
    end

    // ============================================================
    // PART 3: Skew Unit (三角形延时)
    // ============================================================
    // 注意：Skew Unit 只有在 act_out_valid 为高时才应该更新？
    // 还是说脉动阵列是自由运行的？
    // 通常设计：Skew Unit 是纯移位寄存器，只要时钟在跑，它就移位。
    // 我们通过 data_to_skew 里的 "0" 来清空流水线。
    
    genvar i;
    generate
        for (i = 0; i < ROW_NUM; i = i + 1) begin : skew_logic
            wire [DATA_WIDTH-1:0] row_in_data;
            assign row_in_data = data_to_skew[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH];

            if (i == 0) begin
                assign act_out_skewed[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH] = row_in_data;
            end else begin
                reg [DATA_WIDTH-1:0] delay_regs [0:i-1];
                integer j;
                
                // 这里加了一个简单的门控：只有 act_out_valid 有效时才移位
                // *或者* 你可以让它一直移位，反正输入是0。
                // 为了保险（防止 SRAM 中间有 bubble 导致 shift 了无效数据），
                // 建议只有 valid 时才移位，或者阵列本身有 enable 信号。
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        for (j = 0; j < i; j = j + 1) delay_regs[j] <= 0;
                    end else if (act_out_valid) begin 
                        // 只有当有数据(无论是真数据还是补的0)进入时，链条才流动
                        delay_regs[0] <= row_in_data;
                        for (j = 1; j < i; j = j + 1) delay_regs[j] <= delay_regs[j-1];
                    end
                end
                assign act_out_skewed[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH] = delay_regs[i-1];
            end
        end
    endgenerate

endmodule