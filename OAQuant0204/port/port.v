module port(
    input wire clk,
    input wire rst_n,
    
    // --- 启动控制 ---
    input wire weight_port_start,
    input wire act_port_start,
    input wire res_port_start, // (暂时预留，未例化 res_port)
    
    // --- 传输参数 (新增，必须有这些才能驱动子模块) ---
    input wire [12:0] tran_time,
    input wire [255:0] data_i,

    // --- 完成状态 ---
    output wire act_port_done,
    output wire weight_port_done,

    // --- SRAM Bank 0-3 (Act) ---
    output wire bce_0, bce_1, bce_2, bce_3,
    output wire [14:0] bwaddr_0, bwaddr_1, bwaddr_2, bwaddr_3,
    // [修正] 位宽改为 128bit 以匹配 act_port 输出
    output wire [127:0] bwdata_0, bwdata_1, bwdata_2, bwdata_3,

    // --- SRAM Bank 4-7 (Weight) ---
    output wire bce_4, bce_5, bce_6, bce_7,
    output wire [14:0] bwaddr_4, bwaddr_5, bwaddr_6, bwaddr_7,
    // [修正] 位宽改为 128bit 以匹配 weight_port 输出
    output wire [127:0] bwdata_4, bwdata_5, bwdata_6, bwdata_7
);

    // ============================================================
    // 1. 实例化激活值端口 (Act Port) -> 控制 Bank 0,1,2,3
    // ============================================================
    // act_port 内部维护了 pingpang 寄存器，自动切换 Bank 0/1 和 Bank 2/3
    
    act_port u_act_port (
        .clk            (clk),
        .rst_n          (rst_n),
        .act_port_start (act_port_start),
        .tran_time      (tran_time),
        .data_i         (data_i),
        .done           (act_port_done),

        // 直接映射到顶层 Bank 0-3
        .bce_0(bce_0), .bce_1(bce_1), .bce_2(bce_2), .bce_3(bce_3),
        
        .bwaddr_0(bwaddr_0), .bwaddr_1(bwaddr_1), 
        .bwaddr_2(bwaddr_2), .bwaddr_3(bwaddr_3),
        
        .bwdata_0(bwdata_0), .bwdata_1(bwdata_1), 
        .bwdata_2(bwdata_2), .bwdata_3(bwdata_3)
    );

    // ============================================================
    // 2. 实例化权重端口 (Weight Port) -> 控制 Bank 4,5,6,7
    // ============================================================
    // weight_port 内部逻辑和 act_port 一样，认为自己控制的是 Bank 0-3。
    // 我们需要在顶层连线时，将其“重定向”到 Bank 4-7。
    
    weight_port u_weight_port (
        .clk               (clk),
        .rst_n             (rst_n),
        .weight_port_start (weight_port_start),
        .tran_time         (tran_time),
        .data_i            (data_i),
        .done              (weight_port_done),

        // --- 关键映射 (Remapping) ---
        // weight_port 的 Bank 0 -> 顶层 Bank 4
        // weight_port 的 Bank 1 -> 顶层 Bank 5
        // weight_port 的 Bank 2 -> 顶层 Bank 6
        // weight_port 的 Bank 3 -> 顶层 Bank 7
        
        .bce_0(bce_4),       .bce_1(bce_5),       
        .bce_2(bce_6),       .bce_3(bce_7),
        
        .bwaddr_0(bwaddr_4), .bwaddr_1(bwaddr_5), 
        .bwaddr_2(bwaddr_6), .bwaddr_3(bwaddr_7),
        
        .bwdata_0(bwdata_4), .bwdata_1(bwdata_5), 
        .bwdata_2(bwdata_6), .bwdata_3(bwdata_7)
    );

endmodule