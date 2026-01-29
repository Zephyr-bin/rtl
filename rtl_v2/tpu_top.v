module tpu_top(
    input wire clk,
    input wire rst_n,
    input wire start,           // 全局启动
    input wire [255:0] data_in  // 全局数据输入
);

    // ============================================================
    // 1. 全局控制状态机 (FSM)
    // ============================================================
    // IDLE -> LOAD (Act -> Weight) -> COMPUTE
    
    localparam S_IDLE    = 2'd0;
    localparam S_LOAD    = 2'd1;
    localparam S_COMPUTE = 2'd2;

    reg [1:0] state, next_state;
    
    // 握手信号
    wire act_load_done;    // Act 搬完
    wire weight_load_done; // Weight 搬完

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= S_IDLE;
        else        state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (start) next_state = S_LOAD;
            end
            S_LOAD: begin
                // [修改点 1] FSM 跳转条件
                // 因为是串行搬运，Act 搬完会触发 Weight，
                // 所以我们只需要等最后一步(Weight) 搬完即可。
                if (weight_load_done) next_state = S_COMPUTE;
            end
            S_COMPUTE: begin
                next_state = S_COMPUTE; // 保持计算状态
            end
            default: next_state = S_IDLE;
        endcase
    end

    // [修改点 2] 启动脉冲生成
    reg act_start_pulse;     // 仅用于启动 Act
    reg compute_start_pulse; // 用于启动计算

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            act_start_pulse     <= 0;
            compute_start_pulse <= 0;
        end else begin
            // 进入 LOAD 状态的第一拍，只启动 Act
            act_start_pulse     <= (state == S_IDLE && next_state == S_LOAD);
            // 进入 COMPUTE 状态的第一拍，启动计算核
            compute_start_pulse <= (state == S_LOAD && next_state == S_COMPUTE);
        end
    end

    // ============================================================
    // 2. 中间连线定义 (保持不变)
    // ============================================================
    // ... (Wrapper 信号定义省略，与之前一致) ...
    // ... (Port/Sto/Core 信号定义省略，与之前一致) ...
    
    // 为了代码完整性，这里补充关键连线声明
    wire        w_bce   [0:15];
    wire [2:0]  w_bwmod [0:15];
    wire [1:0]  w_bwren [0:15];
    wire [14:0] w_bwaddr[0:15];
    wire [255:0] w_bwdata[0:15];
    wire [2:0]  w_brmod [0:15];
    wire [14:0] w_braddr[0:15];
    wire [255:0] w_brdata [0:15];
    wire        w_brvalid[0:15];

    wire p_bce [0:7];
    wire [14:0] p_bwaddr [0:7];
    wire [127:0] p_bwdata [0:7];

    wire s_bce [0:7];
    wire [14:0] s_braddr [0:7];
    wire [127:0] sto_act_data;
    wire         sto_act_valid;

    wire c_bce [8:15];
    wire [14:0] c_bwaddr [8:15];
    wire [127:0] c_bwdata [8:15];

    // ============================================================
    // 3. 例化 Port (DMA Writer) - 串行加载逻辑
    // ============================================================
    // [修改点 3] 链式启动逻辑
    // 1. FSM 触发 act_port_start
    // 2. act_port 跑完拉高 act_port_done
    // 3. act_port_done 直接连到 weight_port_start
    
    port u_dma_port (
        .clk              (clk),
        .rst_n            (rst_n),
        
        // --- 启动控制 ---
        .act_port_start   (act_start_pulse),  // 步骤1：先由 FSM 启动 Act
        .weight_port_start(act_load_done),    // 步骤2：Act 做完后，自动启动 Weight
        .res_port_start   (1'b0),

        // --- 参数 ---
        .tran_time        (13'd64), 
        .data_i           (data_in),          // 共享数据总线

        // --- 状态反馈 ---
        .act_port_done    (act_load_done),    // 这个信号回环去启动 Weight
        .weight_port_done (weight_load_done), // 这个信号告诉 FSM 全部搞定

        // Bank 0-3 (Act) Write
        .bce_0(p_bce[0]), .bce_1(p_bce[1]), .bce_2(p_bce[2]), .bce_3(p_bce[3]),
        .bwaddr_0(p_bwaddr[0]), .bwaddr_1(p_bwaddr[1]), .bwaddr_2(p_bwaddr[2]), .bwaddr_3(p_bwaddr[3]),
        .bwdata_0(p_bwdata[0]), .bwdata_1(p_bwdata[1]), .bwdata_2(p_bwdata[2]), .bwdata_3(p_bwdata[3]),

        // Bank 4-7 (Weight) Write
        .bce_4(p_bce[4]), .bce_5(p_bce[5]), .bce_6(p_bce[6]), .bce_7(p_bce[7]),
        .bwaddr_4(p_bwaddr[4]), .bwaddr_5(p_bwaddr[5]), .bwaddr_6(p_bwaddr[6]), .bwaddr_7(p_bwaddr[7]),
        .bwdata_4(p_bwdata[4]), .bwdata_5(p_bwdata[5]), .bwdata_6(p_bwdata[6]), .bwdata_7(p_bwdata[7])
    );

    // ============================================================
    // 4. 例化 Sto (Scheduler) 
    // ============================================================
    sto u_sto (
        .clk     (clk),
        .rst_n   (rst_n),
        .start   (compute_start_pulse), // Weight 搬完后 FSM 进 COMPUTE，触发此脉冲
        
        .act_pe_valid (sto_act_valid),
        .act_pe_o     (sto_act_data),

        .bce_0(s_bce[0]), .bce_1(s_bce[1]), .bce_2(s_bce[2]), .bce_3(s_bce[3]),
        .braddr_0(s_braddr[0]), .braddr_1(s_braddr[1]), .braddr_2(s_braddr[2]), .braddr_3(s_braddr[3]),
        .bce_4(s_bce[4]), .bce_5(s_bce[5]), .bce_6(s_bce[6]), .bce_7(s_bce[7]),
        .braddr_4(s_braddr[4]), .braddr_5(s_braddr[5]), .braddr_6(s_braddr[6]), .braddr_7(s_braddr[7]),

        .brdata_0(w_brdata[0][63:0]), .brdata_1(w_brdata[1][63:0]), 
        .brdata_2(w_brdata[2][63:0]), .brdata_3(w_brdata[3][63:0]),
        .brvalid_0(w_brvalid[0]), .brvalid_1(w_brvalid[1]),
        .brvalid_2(w_brvalid[2]), .brvalid_3(w_brvalid[3])
    );

    // ============================================================
    // 5. 例化 Compute Core
    // ============================================================
    // 假设 Global Scale 和 PingPong 这里先给固定值或寄存器值
    reg core_pingpang;
    always @(posedge clk or negedge rst_n) if(!rst_n) core_pingpang <= 0;

    top_compute_core u_core (
        .clk        (clk),
        .rst_n      (rst_n),
        .start_calc (compute_start_pulse), // 与 Sto 同步启动
        .pingpang   (core_pingpang),
        .global_scale (16'h3C00), 

        .act_data_in  (sto_act_data),
        .act_pe_valid (sto_act_valid),

        .brvalid_4 (w_brvalid[4]), .brdata_4 (w_brdata[4][63:0]),
        .brvalid_5 (w_brvalid[5]), .brdata_5 (w_brdata[5][63:0]),
        .brvalid_6 (w_brvalid[6]), .brdata_6 (w_brdata[6][63:0]),
        .brvalid_7 (w_brvalid[7]), .brdata_7 (w_brdata[7][63:0]),

        .bce_8 (c_bce[8]),  .bce_9 (c_bce[9]),  .bce_10(c_bce[10]), .bce_11(c_bce[11]),
        .bce_12(c_bce[12]), .bce_13(c_bce[13]), .bce_14(c_bce[14]), .bce_15(c_bce[15]),
        .bwaddr_8 (c_bwaddr[8]),  .bwaddr_9 (c_bwaddr[9]),  .bwaddr_10(c_bwaddr[10]), .bwaddr_11(c_bwaddr[11]),
        .bwaddr_12(c_bwaddr[12]), .bwaddr_13(c_bwaddr[13]), .bwaddr_14(c_bwaddr[14]), .bwaddr_15(c_bwaddr[15]),
        .bwdata_8 (c_bwdata[8]),  .bwdata_9 (c_bwdata[9]),  .bwdata_10(c_bwdata[10]), .bwdata_11(c_bwdata[11]),
        .bwdata_12(c_bwdata[12]), .bwdata_13(c_bwdata[13]), .bwdata_14(c_bwdata[14]), .bwdata_15(c_bwdata[15])
    );

    // ============================================================
    // 6. Wrapper 信号仲裁 (保持不变)
    // ============================================================
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : mux_bank0_7
            assign w_bce[i] = p_bce[i] | s_bce[i];
            assign w_bwren[i] = (p_bce[i]) ? 2'b10 : (s_bce[i]) ? 2'b01 : 2'b00;
            assign w_bwaddr[i] = p_bwaddr[i];
            assign w_bwdata[i] = {128'd0, p_bwdata[i]};
            assign w_bwmod[i]  = 3'b100;
            assign w_braddr[i] = s_braddr[i];
            assign w_brmod[i]  = 3'b011; 
        end
        for (i = 8; i < 16; i = i + 1) begin : map_bank8_15
            assign w_bce[i] = c_bce[i];
            assign w_bwren[i] = (c_bce[i]) ? 2'b10 : 2'b00;
            assign w_bwaddr[i] = c_bwaddr[i];
            assign w_bwdata[i] = {128'd0, c_bwdata[i]};
            assign w_bwmod[i]  = 3'b100;
            assign w_braddr[i] = 15'd0;
            assign w_brmod[i]  = 3'b100;
        end
    endgenerate

    // ============================================================
    // 7. 例化 Wrapper (保持不变)
    // ============================================================
    


    wrapper_16banks u_sram_wrapper (
        .clk(clk), .rst_n(rst_n),
        // ... (连接同上个版本) ...
        .bce0_i (w_bce[0]), .bwren0_i (w_bwren[0]), .bwaddr0_i (w_bwaddr[0]), .bwdata0_i (w_bwdata[0]), .bwmod0_i(w_bwmod[0]),
        .bce1_i (w_bce[1]), .bwren1_i (w_bwren[1]), .bwaddr1_i (w_bwaddr[1]), .bwdata1_i (w_bwdata[1]), .bwmod1_i(w_bwmod[1]),
        .bce2_i (w_bce[2]), .bwren2_i (w_bwren[2]), .bwaddr2_i (w_bwaddr[2]), .bwdata2_i (w_bwdata[2]), .bwmod2_i(w_bwmod[2]),
        .bce3_i (w_bce[3]), .bwren3_i (w_bwren[3]), .bwaddr3_i (w_bwaddr[3]), .bwdata3_i (w_bwdata[3]), .bwmod3_i(w_bwmod[3]),
        .bce4_i (w_bce[4]), .bwren4_i (w_bwren[4]), .bwaddr4_i (w_bwaddr[4]), .bwdata4_i (w_bwdata[4]), .bwmod4_i(w_bwmod[4]),
        .bce5_i (w_bce[5]), .bwren5_i (w_bwren[5]), .bwaddr5_i (w_bwaddr[5]), .bwdata5_i (w_bwdata[5]), .bwmod5_i(w_bwmod[5]),
        .bce6_i (w_bce[6]), .bwren6_i (w_bwren[6]), .bwaddr6_i (w_bwaddr[6]), .bwdata6_i (w_bwdata[6]), .bwmod6_i(w_bwmod[6]),
        .bce7_i (w_bce[7]), .bwren7_i (w_bwren[7]), .bwaddr7_i (w_bwaddr[7]), .bwdata7_i (w_bwdata[7]), .bwmod7_i(w_bwmod[7]),
        
        .bce8_i (w_bce[8]), .bwren8_i (w_bwren[8]), .bwaddr8_i (w_bwaddr[8]), .bwdata8_i (w_bwdata[8]), .bwmod8_i(w_bwmod[8]),
        .bce9_i (w_bce[9]), .bwren9_i (w_bwren[9]), .bwaddr9_i (w_bwaddr[9]), .bwdata9_i (w_bwdata[9]), .bwmod9_i(w_bwmod[9]),
        .bce10_i(w_bce[10]),.bwren10_i(w_bwren[10]),.bwaddr10_i(w_bwaddr[10]),.bwdata10_i(w_bwdata[10]),.bwmod10_i(w_bwmod[10]),
        .bce11_i(w_bce[11]),.bwren11_i(w_bwren[11]),.bwaddr11_i(w_bwaddr[11]),.bwdata11_i(w_bwdata[11]),.bwmod11_i(w_bwmod[11]),
        .bce12_i(w_bce[12]),.bwren12_i(w_bwren[12]),.bwaddr12_i(w_bwaddr[12]),.bwdata12_i(w_bwdata[12]),.bwmod12_i(w_bwmod[12]),
        .bce13_i(w_bce[13]),.bwren13_i(w_bwren[13]),.bwaddr13_i(w_bwaddr[13]),.bwdata13_i(w_bwdata[13]),.bwmod13_i(w_bwmod[13]),
        .bce14_i(w_bce[14]),.bwren14_i(w_bwren[14]),.bwaddr14_i(w_bwaddr[14]),.bwdata14_i(w_bwdata[14]),.bwmod14_i(w_bwmod[14]),
        .bce15_i(w_bce[15]),.bwren15_i(w_bwren[15]),.bwaddr15_i(w_bwaddr[15]),.bwdata15_i(w_bwdata[15]),.bwmod15_i(w_bwmod[15]),

        .brmod0_i(w_brmod[0]), .braddr0_i(w_braddr[0]), .brmod1_i(w_brmod[1]), .braddr1_i(w_braddr[1]),
        .brmod2_i(w_brmod[2]), .braddr2_i(w_braddr[2]), .brmod3_i(w_brmod[3]), .braddr3_i(w_braddr[3]),
        .brmod4_i(w_brmod[4]), .braddr4_i(w_braddr[4]), .brmod5_i(w_brmod[5]), .braddr5_i(w_braddr[5]),
        .brmod6_i(w_brmod[6]), .braddr6_i(w_braddr[6]), .brmod7_i(w_brmod[7]), .braddr7_i(w_braddr[7]),
        .brmod8_i(w_brmod[8]), .braddr8_i(w_braddr[8]), .brmod9_i(w_brmod[9]), .braddr9_i(w_braddr[9]),
        .brmod10_i(w_brmod[10]),.braddr10_i(w_braddr[10]),.brmod11_i(w_brmod[11]),.braddr11_i(w_braddr[11]),
        .brmod12_i(w_brmod[12]),.braddr12_i(w_braddr[12]),.brmod13_i(w_brmod[13]),.braddr13_i(w_braddr[13]),
        .brmod14_i(w_brmod[14]),.braddr14_i(w_braddr[14]),.brmod15_i(w_brmod[15]),.braddr15_i(w_braddr[15]),

        .brdata0_o(w_brdata[0]), .brvalid0_o(w_brvalid[0]), .brdata1_o(w_brdata[1]), .brvalid1_o(w_brvalid[1]),
        .brdata2_o(w_brdata[2]), .brvalid2_o(w_brvalid[2]), .brdata3_o(w_brdata[3]), .brvalid3_o(w_brvalid[3]),
        .brdata4_o(w_brdata[4]), .brvalid4_o(w_brvalid[4]), .brdata5_o(w_brdata[5]), .brvalid5_o(w_brvalid[5]),
        .brdata6_o(w_brdata[6]), .brvalid6_o(w_brvalid[6]), .brdata7_o(w_brdata[7]), .brvalid7_o(w_brvalid[7]),
        .brdata8_o(w_brdata[8]), .brvalid8_o(w_brvalid[8]), .brdata9_o(w_brdata[9]), .brvalid9_o(w_brvalid[9]),
        .brdata10_o(w_brdata[10]), .brvalid10_o(w_brvalid[10]), .brdata11_o(w_brdata[11]), .brvalid11_o(w_brvalid[11]),
        .brdata12_o(w_brdata[12]), .brvalid12_o(w_brvalid[12]), .brdata13_o(w_brdata[13]), .brvalid13_o(w_brvalid[13]),
        .brdata14_o(w_brdata[14]), .brvalid14_o(w_brvalid[14]), .brdata15_o(w_brdata[15]), .brvalid15_o(w_brvalid[15])
    );

endmodule