module act(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [11:0] tran_time, 
    
    // Request Side
    output reg bce0, bce1, bce2, bce3,
    output reg [14:0] braddr0, braddr1, braddr2, braddr3,
    
    // Response Side
    input wire [63:0] brdata0, brdata1, brdata2, brdata3,
    input wire brvalid0, brvalid1, brvalid2, brvalid3,

    // Output
    output wire [127:0] act_out_skewed,
    output reg act_out_valid
);

    parameter ROW_NUM    = 32;
    parameter DATA_WIDTH = 4;
    parameter SKEW_DELAY = ROW_NUM - 1;
    parameter BANK_DEPTH = 4096; // 4k深度

    // ============================================================
    // PART 1: 请求域 (Request Domain) - 负责发地址
    // ============================================================
    // 这里依然需要 pingpang 状态，因为我们要主动发起请求,
    // 必须知道现在轮到读哪个 buffer。
    reg pingpang;      
    reg [11:0] base_row_idx; // 基地址指针

    reg [11:0] req_cnt;
    reg req_busy;
    
    wire [11:0] current_abs_row;
    assign current_abs_row = base_row_idx + req_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            req_busy <= 1'b0;
            req_cnt <= 12'd0;
            {bce0, bce1, bce2, bce3} <= 4'b0;
            braddr0 <= 15'd0; braddr1 <= 15'd0;
            braddr2 <= 15'd0; braddr3 <= 15'd0;
            
            pingpang <= 1'b0;
            base_row_idx <= 12'd0;
        end else begin
            // 默认拉低片选
            {bce0, bce1, bce2, bce3} <= 4'b0;

            if (start) begin
                req_busy <= 1'b1;
                req_cnt <= 12'd0;
            end else if (req_busy) begin
                if (req_cnt <= tran_time) begin 
                    // 根据 pingpang 状态决定向哪一组 Bank 发地址
                    if (!pingpang) begin
                        bce0 <= 1'b1; bce1 <= 1'b1;
                        braddr0 <= {current_abs_row, 3'b000}; 
                        braddr1 <= {current_abs_row, 3'b000};
                    end else begin
                        bce2 <= 1'b1; bce3 <= 1'b1;
                        braddr2 <= {current_abs_row, 3'b000};
                        braddr3 <= {current_abs_row, 3'b000};
                    end
                    req_cnt <= req_cnt + 1'b1;
                end else begin
                    // 请求结束
                    req_busy <= 1'b0; 
                    
                    // 更新基地址和 PingPang 状态
                    if (base_row_idx + ROW_NUM >= BANK_DEPTH) begin
                        base_row_idx <= 12'd0; // 滚回 0
                        pingpang <= ~pingpang; // 切换 Bank 组
                    end else begin
                        base_row_idx <= base_row_idx + ROW_NUM;
                    end
                end
            end
        end
    end

    // ============================================================
    // PART 2: 响应域 (Response Domain) - 负责收数据
    // ============================================================
    
    // [优化] 既然不需要 run_pingpang，我们就根据 valid 信号来判断数据来源
    // 只要任意一个 valid 为高，就说明有 SRAM 数据回来
    wire current_sram_valid = brvalid0 | brvalid2;

    reg [12:0] recv_cnt; 
    reg [4:0] drain_cnt;
    reg draining; 

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
                if (current_sram_valid && (recv_cnt <= tran_time)) begin
                    recv_cnt <= recv_cnt + 1'b1;
                    act_out_valid <= 1'b1; 
                end 
                else if (recv_cnt > tran_time && drain_cnt < SKEW_DELAY) begin
                    draining <= 1'b1;
                    drain_cnt <= drain_cnt + 1'b1;
                    act_out_valid <= 1'b1; 
                end 
                else begin
                    act_out_valid <= 1'b0;
                    draining <= 1'b0;
                end
            end
        end
    end

    // ============================================================
    // [关键修改] 数据选择 MUX - 完全基于 Valid 信号
    // ============================================================
    reg [127:0] data_to_skew;

    always @(*) begin
        // 优先级逻辑：
        // 1. 如果 Group0 (Bank0/1) 有效，就选 Group0
        // 2. 如果 Group1 (Bank2/3) 有效，就选 Group1
        // 3. 都没有但处于 Draining 状态，补零
        // 4. 其他情况归零
        
        if (brvalid0) begin
            data_to_skew = {brdata1, brdata0};
        end else if (brvalid2) begin
            data_to_skew = {brdata3, brdata2};
        end else if (draining) begin
            data_to_skew = 128'd0;
        end else begin
            data_to_skew = 128'd0;
        end
    end

    // ============================================================
    // PART 3: Skew Unit (保持不变)
    // ============================================================
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
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        for (j = 0; j < i; j = j + 1) delay_regs[j] <= 0;
                    end else if (act_out_valid) begin 
                        delay_regs[0] <= row_in_data;
                        for (j = 1; j < i; j = j + 1) delay_regs[j] <= delay_regs[j-1];
                    end
                end
                assign act_out_skewed[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH] = delay_regs[i-1];
            end
        end
    endgenerate

endmodule