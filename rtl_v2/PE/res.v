module res(
    input wire clk,
    input wire rst_n,
    input wire start,      // 用于复位内部写地址计数器
    input wire pingpang,   // 0: 写 Bank0-3; 1: 写 Bank4-7
    
    // 来自脉动阵列的输入
    // 假设阵列输出 32路 * 16bit = 512bit
    // array_valid_in 指示 array_data_in 的第0列数据是有效的
    input wire [511:0] array_data_in, 
    input wire array_valid_in,

    // SRAM 写端口 (只管写，不回传握手信号)
    output reg bce0, bce1, bce2, bce3, bce4, bce5, bce6, bce7,
    // output reg [1:0] bwren0, bwren1, bwren2, bwren3, bwren4, bwren5, bwren6, bwren7,
    output reg [14:0] bwaddr0, bwaddr1, bwaddr2, bwaddr3, bwaddr4, bwaddr5, bwaddr6, bwaddr7,
    output reg [127:0] bwdata0, bwdata1, bwdata2, bwdata3, bwdata4, bwdata5, bwdata6, bwdata7
);

    // 参数定义
    parameter COL_NUM    = 32;
    parameter DATA_WIDTH = 16;
    parameter SKEW_DELAY = COL_NUM - 1; // 31

    // ============================================================
    // 1. 反向三角形延时 (De-skew Unit)
    // ============================================================
    // 逻辑：Col 0 最先出来，要等最久(31拍)；Col 31 最后出来，不用等(0拍)。
    
    wire [511:0] aligned_data; // 对齐后的一整行数据
    reg aligned_valid;         // 对齐后的有效信号 (内部控制用)
    
    genvar i;
    generate
        for (i = 0; i < COL_NUM; i = i + 1) begin : deskew_logic
            // 提取当前列的数据
            wire [DATA_WIDTH-1:0] col_in_data;
            assign col_in_data = array_data_in[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH];

            // 计算需要的延时深度：
            // i=0 (Col 0) -> Delay = 31
            // i=31 (Col 31) -> Delay = 0
            localparam DELAY_DEPTH = SKEW_DELAY - i;

            if (DELAY_DEPTH == 0) begin
                // 最后一列直接输出
                assign aligned_data[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH] = col_in_data;
            end else begin
                // 其他列进入移位寄存器
                reg [DATA_WIDTH-1:0] delay_regs [0:DELAY_DEPTH-1];
                integer j;

                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        for (j = 0; j < DELAY_DEPTH; j = j + 1) delay_regs[j] <= 0;
                    end else begin
                        delay_regs[0] <= col_in_data;
                        for (j = 1; j < DELAY_DEPTH; j = j + 1) begin
                            delay_regs[j] <= delay_regs[j-1];
                        end
                    end
                end
                // 输出链尾
                assign aligned_data[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH] = delay_regs[DELAY_DEPTH-1];
            end
        end
    endgenerate

    // Valid 信号同步延时 (必须跟着 Col 0 一起延时 31 拍)
    reg [SKEW_DELAY-1:0] valid_pipe;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_pipe <= 0;
            aligned_valid <= 0;
        end else begin
            // 移位逻辑
            valid_pipe <= {valid_pipe[SKEW_DELAY-2:0], array_valid_in};
            // 取出延迟了 31 拍后的信号
            aligned_valid <= valid_pipe[SKEW_DELAY-1];
        end
    end

    // ============================================================
    // 2. 地址产生与数据分发 (SRAM Writer)
    // ============================================================
    
    reg [10:0] write_cnt; // 内部地址计数器

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_cnt <= 0;
            {bce0, bce1, bce2, bce3, bce4, bce5, bce6, bce7} <= 0;
            bwaddr0 <= 0; bwaddr1 <= 0; bwaddr2 <= 0; bwaddr3 <= 0;
            bwaddr4 <= 0; bwaddr5 <= 0; bwaddr6 <= 0; bwaddr7 <= 0;
            bwdata0 <= 0; bwdata1 <= 0; bwdata2 <= 0; bwdata3 <= 0;
            bwdata4 <= 0; bwdata5 <= 0; bwdata6 <= 0; bwdata7 <= 0;
        end else begin
            // 默认拉低写使能
            {bce0, bce1, bce2, bce3, bce4, bce5, bce6, bce7} <= 0;

            if (start) begin
                write_cnt <= 0;
            end
            
            // 只有当内部对齐信号有效时，才写 SRAM
            if (aligned_valid) begin
                
                // 地址更新: 每次+1 (物理地址+16)
                write_cnt <= write_cnt + 1'b1;

                // 根据 Ping-Pong 选择写入的 Bank
                if (!pingpang) begin
                    // ---- 写 Ping 区 (Bank 0-3) ----
                    bce0 <= 1; bce1 <= 1; bce2 <= 1; bce3 <= 1;
                    
                    // 地址拼接: {cnt, 0000} = cnt * 16
                    bwaddr0 <= {write_cnt, 4'b0000};
                    bwaddr1 <= {write_cnt, 4'b0000};
                    bwaddr2 <= {write_cnt, 4'b0000};
                    bwaddr3 <= {write_cnt, 4'b0000};
                    
                    // 数据分配 (512bit -> 4x128bit)
                    bwdata0 <= aligned_data[127:0];
                    bwdata1 <= aligned_data[255:128];
                    bwdata2 <= aligned_data[383:256];
                    bwdata3 <= aligned_data[511:384];
                end else begin
                    // ---- 写 Pong 区 (Bank 4-7) ----
                    bce4 <= 1; bce5 <= 1; bce6 <= 1; bce7 <= 1;

                    bwaddr4 <= {write_cnt, 4'b0000};
                    bwaddr5 <= {write_cnt, 4'b0000};
                    bwaddr6 <= {write_cnt, 4'b0000};
                    bwaddr7 <= {write_cnt, 4'b0000};

                    bwdata4 <= aligned_data[127:0];
                    bwdata5 <= aligned_data[255:128];
                    bwdata6 <= aligned_data[383:256];
                    bwdata7 <= aligned_data[511:384];
                end
            end
        end
    end

endmodule