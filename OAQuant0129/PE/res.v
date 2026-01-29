module res(
    input wire clk,
    input wire rst_n,
    input wire start,      // 复位写地址计数器和乒乓状态
    // input wire pingpang, // [修改] 移除外部输入
    
    // 来自脉动阵列的输入
    input wire [511:0] array_data_in, 
    input wire array_valid_in,

    // SRAM 写端口
    output reg bce0, bce1, bce2, bce3, bce4, bce5, bce6, bce7,
    output reg [14:0] bwaddr0, bwaddr1, bwaddr2, bwaddr3, bwaddr4, bwaddr5, bwaddr6, bwaddr7,
    output reg [127:0] bwdata0, bwdata1, bwdata2, bwdata3, bwdata4, bwdata5, bwdata6, bwdata7
);

    // 参数定义
    parameter COL_NUM    = 32;
    parameter DATA_WIDTH = 16;
    parameter SKEW_DELAY = COL_NUM - 1; // 31
    
    // [修改] 新增 Bank 深度定义
    parameter BANK_DEPTH = 2048; // 2k

    // ============================================================
    // 1. 反向三角形延时 (De-skew Unit)
    // ============================================================
    
    wire [511:0] aligned_data; // 对齐后的一整行数据
    wire aligned_valid;        
    
    genvar i;
    generate
        for (i = 0; i < COL_NUM; i = i + 1) begin : deskew_logic
            // 提取当前列的数据
            wire [DATA_WIDTH-1:0] col_in_data;
            assign col_in_data = array_data_in[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH];

            // 计算需要的延时深度
            localparam DELAY_DEPTH = SKEW_DELAY - i;

            if (DELAY_DEPTH == 0) begin
                assign aligned_data[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH] = col_in_data;
            end else begin
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
                assign aligned_data[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH] = delay_regs[DELAY_DEPTH-1];
            end
        end
    endgenerate

    // ============================================================
    // Valid 信号同步延时
    // ============================================================
    reg [SKEW_DELAY-1:0] valid_pipe; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_pipe <= 0;
        end else begin
            // 移位逻辑
            valid_pipe[SKEW_DELAY-1:1] <= valid_pipe[SKEW_DELAY-2:0];
            valid_pipe[0] <= array_valid_in;
        end
    end

    assign aligned_valid = valid_pipe[SKEW_DELAY-1] && array_valid_in;

    // ============================================================
    // 2. 地址产生与数据分发 (SRAM Writer)
    // ============================================================
    
    reg [10:0] write_cnt; 
    reg pingpang; // [修改] 内部定义乒乓寄存器

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_cnt <= 0;
            pingpang  <= 0;
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
                pingpang  <= 0; // [修改] Start 信号复位 PingPang 状态 (默认先写 Bank0-3)
            end
            
            if (aligned_valid) begin
                
                // [修改] 地址与 PingPang 翻转逻辑
                if (write_cnt == BANK_DEPTH - 1) begin // 到达 2047
                    write_cnt <= 0;        // 归零
                    pingpang  <= ~pingpang; // 翻转
                end else begin
                    write_cnt <= write_cnt + 1'b1;
                end

                // 写操作 (注意：这里使用的是当前拍尚未更新的 pingpang 和 write_cnt)
                // 例如：当 write_cnt=2047 时，这里依然用 2047 写当前 Bank，下一拍才会翻转
                if (!pingpang) begin
                    // ---- 写 Ping 区 (Bank 0-3) ----
                    bce0 <= 1; bce1 <= 1; bce2 <= 1; bce3 <= 1;
                    
                    bwaddr0 <= {write_cnt, 4'b0000};
                    bwaddr1 <= {write_cnt, 4'b0000};
                    bwaddr2 <= {write_cnt, 4'b0000};
                    bwaddr3 <= {write_cnt, 4'b0000};
                    
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