module weight_port(
    input wire clk,
    input wire rst_n,
    input wire weight_port_start,    // 启动本次传输
    input wire [12:0] tran_time,  // 本次传输多少拍
    input wire [255:0] data_i,    // 输入数据
    
    output reg done,              // 本次传输完成信号
    
    // SRAM 写端口
    output reg bce_0, bce_1, bce_2, bce_3,
    output reg [14:0] bwaddr_0, bwaddr_1, bwaddr_2, bwaddr_3,
    output reg [127:0] bwdata_0, bwdata_1, bwdata_2, bwdata_3
);

    // ============================================================
    // 参数定义
    // ============================================================
    // 假设 SRAM 深度对应的最大字节地址。
    // 例如：如果 Bank 存满是 32KB，这里就填 32768 - 16 (最后一个地址)
    // 或者根据你的实际逻辑填写触发翻转的阈值
    parameter PP_ADDR_LIMIT = 15'd32752; 

    // ============================================================
    // 内部状态
    // ============================================================
    reg busy;       // 忙状态
    reg [12:0] cnt; // 传输计数器
    reg pingpang;   // 0: Ping (Bank0/1), 1: Pong (Bank2/3)
    
    // 内部地址寄存器 (持久化，不会每次start都清零)
    reg [14:0] global_addr; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done     <= 1'b0;
            busy     <= 1'b0;
            cnt      <= 13'd0;
            pingpang <= 1'b0;
            global_addr <= 15'd0; // 全局地址复位
            
            {bce_0, bce_1, bce_2, bce_3} <= 4'b0000;
            bwaddr_0 <= 15'd0; bwaddr_1 <= 15'd0;
            bwaddr_2 <= 15'd0; bwaddr_3 <= 15'd0;
            bwdata_0 <= 128'd0; bwdata_1 <= 128'd0;
            bwdata_2 <= 128'd0; bwdata_3 <= 128'd0;
            
        end else begin
            done <= 1'b0; // 脉冲默认拉低

            // ===========================================
            // 状态机逻辑
            // ===========================================
            if (weight_port_start) begin
                // --- 启动 Burst 传输 ---
                busy <= 1'b1;
                cnt  <= 13'd0;
                
                // 【关键修改1】启动时不要清零 global_addr，接着上次的写

                // 1. 设置 BCE (根据当前的 pingpang)
                if (pingpang == 1'b0) begin
                    bce_0 <= 1'b1; bce_1 <= 1'b1;
                    bce_2 <= 1'b0; bce_3 <= 1'b0;
                end else begin
                    bce_0 <= 1'b0; bce_1 <= 1'b0;
                    bce_2 <= 1'b1; bce_3 <= 1'b1;
                end

                // 2. 输出当前地址
                bwaddr_0 <= global_addr; bwaddr_1 <= global_addr;
                bwaddr_2 <= global_addr; bwaddr_3 <= global_addr;

                // 3. 锁存第一拍数据
                bwdata_0 <= data_i[127:0];
                bwdata_1 <= data_i[255:128];
                bwdata_2 <= data_i[127:0];
                bwdata_3 <= data_i[255:128];

            end else if (busy) begin
                // --- 传输中 ---
                
                // 检查 Burst 是否结束
                if (cnt == tran_time - 13'd1) begin
                    busy <= 1'b0;
                    done <= 1'b1; // 本次 Burst 完成
                    
                    // 停止写使能
                    {bce_0, bce_1, bce_2, bce_3} <= 4'b0000;
                    
                    // 【关键修改2】Burst 结束时，检查 Bank 是否满了
                    // 此时 global_addr 已经是本轮最后一个写入地址了
                    // 或者是：在每次地址增加时检查
                    
                end else begin
                    cnt <= cnt + 1'b1;
                end

                // --- 地址更新与乒乓翻转逻辑 ---
                // 注意：只有在 busy 状态下才更新地址
                
                // 如果当前地址已经达到上限，说明写满了 -> 翻转 pingpang 并 清零地址
                if (global_addr >= PP_ADDR_LIMIT) begin
                    pingpang    <= ~pingpang; // 翻转
                    global_addr <= 15'd0;     // 归零，准备写对面 Bank 的 0 地址
                    
                    // 注意：如果是 Burst 的中间满了怎么办？
                    // 通常设计要求 burst 长度能被整除，这里假设刚写完最后一个数
                end else begin
                    // 没满，正常累加
                    global_addr <= global_addr + 15'd16;
                end

                // 同步更新输出端口的地址
                // 注意：如果上面刚清零，这里输出的就是 0
                // 如果上面累加了，这里输出的就是累加后的值 (为下一拍写入做准备)
                if (cnt != tran_time - 13'd1) begin
                   // 只有在 Burst 没结束时，才更新输出地址给下一拍用
                   // 如果 Burst 结束了，地址停留在最后或者归零都行，反正 bce 拉低了
                   // 但为了逻辑一致性，我们让 output 跟随 internal
                    if (global_addr >= PP_ADDR_LIMIT) begin
                        // 这一拍写到了最后一个地址，下一拍地址变为0
                        bwaddr_0 <= 15'd0; bwaddr_1 <= 15'd0;
                        bwaddr_2 <= 15'd0; bwaddr_3 <= 15'd0;
                    end else begin
                        bwaddr_0 <= global_addr + 15'd16;
                        bwaddr_1 <= global_addr + 15'd16;
                        bwaddr_2 <= global_addr + 15'd16;
                        bwaddr_3 <= global_addr + 15'd16;
                    end
                end

                // 数据更新
                bwdata_0 <= data_i[127:0];
                bwdata_1 <= data_i[255:128];
                bwdata_2 <= data_i[127:0];
                bwdata_3 <= data_i[255:128];
            end else begin
                // --- IDLE ---
                {bce_0, bce_1, bce_2, bce_3} <= 4'b0000;
            end
        end
    end

endmodule