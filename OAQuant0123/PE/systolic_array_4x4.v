`timescale 1ns/1ps

module systolic_array_4x4 (
    input wire clk,
    input wire rst_n,
    
    // --- 权重加载接口修改 ---
    input wire load_weight_en,      // 全局加载使能
    input wire [1:0] load_row_addr, // 行地址 (0~3)，指定当前加载哪一行
    input wire [31:0] weight_row_in,// 32位权重输入 (4个PE x 8bit)
    
    // --- 数据流接口 ---
    input wire [31:0]  in_a_row_flat,   // 4行输入
    output wire [95:0] out_sum_col_flat // 4列输出
);

    // =======================================================
    // 1. 权重加载控制逻辑 (地址译码)
    // =======================================================
    wire load_en_row0, load_en_row1, load_en_row2, load_en_row3;

    // 只有当全局使能有效，且地址匹配时，对应行的使能才拉高
    assign load_en_row0 = load_weight_en && (load_row_addr == 2'd0);
    assign load_en_row1 = load_weight_en && (load_row_addr == 2'd1);
    assign load_en_row2 = load_weight_en && (load_row_addr == 2'd2);
    assign load_en_row3 = load_weight_en && (load_row_addr == 2'd3);

    // 将32位输入权重切分为4个8位
    wire signed [7:0] w_in_0, w_in_1, w_in_2, w_in_3;
    assign w_in_0 = weight_row_in[ 7: 0];
    assign w_in_1 = weight_row_in[15: 8];
    assign w_in_2 = weight_row_in[23:16];
    assign w_in_3 = weight_row_in[31:24];


    // =======================================================
    // 2. 内部连线定义 (手动命名，代替数组)
    // Naming: h_wire_行_列 (表示该PE输出到右边的线)
    // Naming: v_wire_行_列 (表示该PE输出到下边的线)
    // =======================================================
    
    // 水平连线 (Horizontal Wires) - 传递 Input A (8-bit)
    // 输入端直接来自端口 in_a_row_flat
    wire signed [7:0] h_wire_0_0, h_wire_0_1, h_wire_0_2, h_wire_0_3;
    wire signed [7:0] h_wire_1_0, h_wire_1_1, h_wire_1_2, h_wire_1_3;
    wire signed [7:0] h_wire_2_0, h_wire_2_1, h_wire_2_2, h_wire_2_3;
    wire signed [7:0] h_wire_3_0, h_wire_3_1, h_wire_3_2, h_wire_3_3;

    // 垂直连线 (Vertical Wires) - 传递 Partial Sum (24-bit)
    // 顶层输入固定为 0，所以不需要定义 wire，直接接地
    wire signed [31:0] v_wire_0_0, v_wire_0_1, v_wire_0_2, v_wire_0_3;
    wire signed [31:0] v_wire_1_0, v_wire_1_1, v_wire_1_2, v_wire_1_3;
    wire signed [31:0] v_wire_2_0, v_wire_2_1, v_wire_2_2, v_wire_2_3;
    wire signed [31:0] v_wire_3_0, v_wire_3_1, v_wire_3_2, v_wire_3_3;

    // =======================================================
    // 3. 手动例化 16 个 PE (Physical Layout)
    // =======================================================

    // ---------------- Row 0 ----------------
    mac_pe pe00 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row0), .weight_in(w_in_0), 
                  .in_a(in_a_row_flat[7:0]), .out_a(h_wire_0_0), 
                  .in_sum(32'd0), .out_sum(v_wire_0_0) ); // 顶部输入0

    mac_pe pe01 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row0), .weight_in(w_in_1),
                  .in_a(h_wire_0_0), .out_a(h_wire_0_1),
                  .in_sum(32'd0), .out_sum(v_wire_0_1) );

    mac_pe pe02 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row0), .weight_in(w_in_2),
                  .in_a(h_wire_0_1), .out_a(h_wire_0_2),
                  .in_sum(32'd0), .out_sum(v_wire_0_2) );

    mac_pe pe03 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row0), .weight_in(w_in_3),
                  .in_a(h_wire_0_2), .out_a(h_wire_0_3),
                  .in_sum(32'd0), .out_sum(v_wire_0_3) );

    // ---------------- Row 1 ----------------
    mac_pe pe10 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row1), .weight_in(w_in_0),
                  .in_a(in_a_row_flat[15:8]), .out_a(h_wire_1_0),
                  .in_sum(v_wire_0_0), .out_sum(v_wire_1_0) ); // 接上一行输出

    mac_pe pe11 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row1), .weight_in(w_in_1),
                  .in_a(h_wire_1_0), .out_a(h_wire_1_1),
                  .in_sum(v_wire_0_1), .out_sum(v_wire_1_1) );

    mac_pe pe12 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row1), .weight_in(w_in_2),
                  .in_a(h_wire_1_1), .out_a(h_wire_1_2),
                  .in_sum(v_wire_0_2), .out_sum(v_wire_1_2) );

    mac_pe pe13 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row1), .weight_in(w_in_3),
                  .in_a(h_wire_1_2), .out_a(h_wire_1_3),
                  .in_sum(v_wire_0_3), .out_sum(v_wire_1_3) );

    // ---------------- Row 2 ----------------
    mac_pe pe20 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row2), .weight_in(w_in_0),
                  .in_a(in_a_row_flat[23:16]), .out_a(h_wire_2_0),
                  .in_sum(v_wire_1_0), .out_sum(v_wire_2_0) );

    mac_pe pe21 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row2), .weight_in(w_in_1),
                  .in_a(h_wire_2_0), .out_a(h_wire_2_1),
                  .in_sum(v_wire_1_1), .out_sum(v_wire_2_1) );

    mac_pe pe22 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row2), .weight_in(w_in_2),
                  .in_a(h_wire_2_1), .out_a(h_wire_2_2),
                  .in_sum(v_wire_1_2), .out_sum(v_wire_2_2) );

    mac_pe pe23 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row2), .weight_in(w_in_3),
                  .in_a(h_wire_2_2), .out_a(h_wire_2_3),
                  .in_sum(v_wire_1_3), .out_sum(v_wire_2_3) );

    // ---------------- Row 3 ----------------
    mac_pe pe30 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row3), .weight_in(w_in_0),
                  .in_a(in_a_row_flat[31:24]), .out_a(h_wire_3_0),
                  .in_sum(v_wire_2_0), .out_sum(v_wire_3_0) );

    mac_pe pe31 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row3), .weight_in(w_in_1),
                  .in_a(h_wire_3_0), .out_a(h_wire_3_1),
                  .in_sum(v_wire_2_1), .out_sum(v_wire_3_1) );

    mac_pe pe32 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row3), .weight_in(w_in_2),
                  .in_a(h_wire_3_1), .out_a(h_wire_3_2),
                  .in_sum(v_wire_2_2), .out_sum(v_wire_3_2) );

    mac_pe pe33 ( .clk(clk), .rst_n(rst_n), .load_weight_en(load_en_row3), .weight_in(w_in_3),
                  .in_a(h_wire_3_2), .out_a(h_wire_3_3),
                  .in_sum(v_wire_2_3), .out_sum(v_wire_3_3) );

    // =======================================================
    // 4. 输出打包
    // =======================================================
    assign out_sum_col_flat[23:0]  = v_wire_3_0;
    assign out_sum_col_flat[47:24] = v_wire_3_1;
    assign out_sum_col_flat[71:48] = v_wire_3_2;
    assign out_sum_col_flat[95:72] = v_wire_3_3;

endmodule