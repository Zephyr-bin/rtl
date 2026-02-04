module weight_mux(
    input wire clk,
    input wire rst_n,
    // 将分散的端口打包处理更方便，实际使用中建议直接定义 input [31:0] flat_weights
    input wire [3:0] weight_0, weight_1, weight_2, weight_3,
    input wire [3:0] weight_4, weight_5, weight_6, weight_7,
    input wire sel,
    input wire [5:0] addr,
    // 输出端口
    output reg [7:0] weight_o0, weight_o1, weight_o2, weight_o3,
    output reg [7:0] weight_o4, weight_o5, weight_o6, weight_o7
);

    // 1. 输入信号打包 (Pack inputs into array for indexing)
    wire [3:0] w_in [0:7];
    assign w_in[0] = weight_0; assign w_in[1] = weight_1;
    assign w_in[2] = weight_2; assign w_in[3] = weight_3;
    assign w_in[4] = weight_4; assign w_in[5] = weight_5;
    assign w_in[6] = weight_6; assign w_in[7] = weight_7;

    // 内部存储与逻辑信号
    reg [3:0] weight_mem [0:7]; // 替代原来的 weight0...weight7
    reg [3:0] cut;
    reg [2:0] outlier_addr_r;
    reg sel_r;
    
    integer i;

    // --------------------------------------------------------
    // Stage 1: 提取 Outlier 并 清零对应位置
    // --------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cut <= 4'd0;
            for (i=0; i<8; i=i+1) weight_mem[i] <= 4'd0;
        end else begin
            // 提取逻辑：如果 sel 有效，提取 addr 指向的数据
            if (sel) 
                cut <= w_in[addr[2:0]];
            
            // 更新逻辑：遍历所有通道
            for (i=0; i<8; i=i+1) begin
                if (sel && (i == addr[2:0])) 
                    // 如果是被选中的 Outlier，存 0
                    weight_mem[i] <= 4'd0; 
                else 
                    // 否则正常通过输入数据
                    weight_mem[i] <= w_in[i]; 
            end
        end
    end

    // --------------------------------------------------------
    // Control Path Pipeline (打拍对齐)
    // --------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            outlier_addr_r <= 3'd0;
            sel_r <= 1'b0;
        end else begin
            outlier_addr_r <= addr[5:3]; // 注意：你原代码这里用的是高3位 [5:3] 而不是 [2:0]，请确认是否符合设计预期？
            sel_r <= sel;
        end
    end

    // --------------------------------------------------------
    // Stage 2: 输出拼装
    // --------------------------------------------------------
    // 为了方便赋值输出端口，定义一个中间数组
    reg [7:0] weight_out_arr [0:7];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i=0; i<8; i=i+1) weight_out_arr[i] <= 8'd0;
        end else begin
            for (i=0; i<8; i=i+1) begin
                // 如果是上一拍选中的 outlier 地址，高4位放 cut，否则放 0
                // 低4位永远放 weight_mem (注意：如果是 outlier，weight_mem 此时已经是0了)
                if (sel_r && (i == outlier_addr_r))
                    weight_out_arr[i] <= {cut, weight_mem[i]};
                else
                    weight_out_arr[i] <= {4'd0, weight_mem[i]};
            end
        end
    end

    // 将数组拆解回独立端口 (Unpack to output ports)
    always @(*) begin
        weight_o0 = weight_out_arr[0]; weight_o1 = weight_out_arr[1];
        weight_o2 = weight_out_arr[2]; weight_o3 = weight_out_arr[3];
        weight_o4 = weight_out_arr[4]; weight_o5 = weight_out_arr[5];
        weight_o6 = weight_out_arr[6]; weight_o7 = weight_out_arr[7];
    end

endmodule