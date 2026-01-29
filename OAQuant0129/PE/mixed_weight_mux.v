module weight_mux(
    input wire clk,
    input wire rst_n,
    input wire [3:0] weight_0,
    input wire [3:0] weight_1,
    input wire [3:0] weight_2,
    input wire [3:0] weight_3,
    input wire [3:0] weight_4,
    input wire [3:0] weight_5,
    input wire [3:0] weight_6,
    input wire [3:0] weight_7,
    input wire sel,
    input wire       mod,
    input wire [5:0] addr,
    output reg [7:0] weight_o0,
    output reg [7:0] weight_o1,
    output reg [7:0] weight_o2,
    output reg [7:0] weight_o3,
    output reg [7:0] weight_o4,
    output reg [7:0] weight_o5,
    output reg [7:0] weight_o6,
    output reg [7:0] weight_o7

);

reg [3:0] weight0;
reg [3:0] weight1;
reg [3:0] weight2;
reg [3:0] weight3;
reg [3:0] weight4;
reg [3:0] weight5;
reg [3:0] weight6;
reg [3:0] weight7;
reg [3:0] cut;
reg [2:0] outlier_addr;
reg sel_ff1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        weight0 <= 4'd0;
        weight1 <= 4'd0;
        weight2 <= 4'd0;
        weight3 <= 4'd0;
        weight4 <= 4'd0;
        weight5 <= 4'd0;
        weight6 <= 4'd0;
        weight7 <= 4'd0;
        cut <= 4'd0;
    end else begin
        if (!sel || mod) begin
            weight0 <= weight_0;
            weight1 <= weight_1;
            weight2 <= weight_2;
            weight3 <= weight_3;
            weight4 <= weight_4;
            weight5 <= weight_5;
            weight6 <= weight_6;
            weight7 <= weight_7;
        end else begin
            case(addr[2:0])
                3'd0: begin
                    cut <= weight_0;
                    weight0 <= 4'd0;
                    weight1 <= weight_1;
                    weight2 <= weight_2;
                    weight3 <= weight_3;
                    weight4 <= weight_4;
                    weight5 <= weight_5;
                    weight6 <= weight_6;
                    weight7 <= weight_7;
                end
                3'd1: begin
                    cut <= weight_1;
                    weight0 <= weight_0;
                    weight1 <= 4'd0;
                    weight2 <= weight_2;
                    weight3 <= weight_3;
                    weight4 <= weight_4;
                    weight5 <= weight_5;
                    weight6 <= weight_6;
                    weight7 <= weight_7;
                end
                3'd2: begin
                    cut <= weight_2;
                    weight0 <= weight_0;
                    weight1 <= weight_1;
                    weight2 <= 4'd0;
                    weight3 <= weight_3;
                    weight4 <= weight_4;
                    weight5 <= weight_5;
                    weight6 <= weight_6;
                    weight7 <= weight_7;
                end
                3'd3: begin
                    cut <= weight_3;
                    weight0 <= weight_0;
                    weight1 <= weight_1;
                    weight2 <= weight_2;
                    weight3 <= 4'd0;
                    weight4 <= weight_4;
                    weight5 <= weight_5;
                    weight6 <= weight_6;
                    weight7 <= weight_7;
                end
                3'd4: begin
                    cut <= weight_4;
                    weight0 <= weight_0;
                    weight1 <= weight_1;
                    weight2 <= weight_2;
                    weight3 <= weight_3;
                    weight4 <= 4'd0;
                    weight5 <= weight_5;
                    weight6 <= weight_6;
                    weight7 <= weight_7;
                end
                3'd5: begin
                    cut <= weight_5;
                    weight0 <= weight_0;
                    weight1 <= weight_1;
                    weight2 <= weight_2;
                    weight3 <= weight_3;
                    weight4 <= weight_4;
                    weight5 <= 4'd0;
                    weight6 <= weight_6;
                    weight7 <= weight_7;
                end
                3'd6: begin
                    cut <= weight_6;
                    weight0 <= weight_0;
                    weight1 <= weight_1;
                    weight2 <= weight_2;
                    weight3 <= weight_3;
                    weight4 <= weight_4;
                    weight5 <= weight_5;
                    weight6 <= 4'd0;
                    weight7 <= weight_7;
                end
                3'd7: begin
                    cut <= weight_7;
                    weight0 <= weight_0;
                    weight1 <= weight_1;
                    weight2 <= weight_2;
                    weight3 <= weight_3;
                    weight4 <= weight_4;
                    weight5 <= weight_5;
                    weight6 <= weight_6;
                    weight7 <= 4'd0;
                end
            endcase
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        outlier_addr <= 3'd0;
        sel_ff1 <= 1'b0;
    end else begin
        outlier_addr <= addr[5:3];
        sel_ff1 <= sel;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        weight_o0 <= 8'd0;
        weight_o1 <= 8'd0;
        weight_o2 <= 8'd0;
        weight_o3 <= 8'd0;
        weight_o4 <= 8'd0;
        weight_o5 <= 8'd0;
        weight_o6 <= 8'd0;
        weight_o7 <= 8'd0;
    end else begin
        if (!sel_ff1) begin
            weight_o0 <= {4'd0, weight0};
            weight_o1 <= {4'd0, weight1};
            weight_o2 <= {4'd0, weight2};
            weight_o3 <= {4'd0, weight3};
            weight_o4 <= {4'd0, weight4};
            weight_o5 <= {4'd0, weight5};
            weight_o6 <= {4'd0, weight6};
            weight_o7 <= {4'd0, weight7};
        end else begin
            case(outlier_addr)
                3'd0: begin
                    weight_o0 <= {cut, weight0};
                    weight_o1 <= {4'd0, weight1};
                    weight_o2 <= {4'd0, weight2};
                    weight_o3 <= {4'd0, weight3};
                    weight_o4 <= {4'd0, weight4};
                    weight_o5 <= {4'd0, weight5};
                    weight_o6 <= {4'd0, weight6};
                    weight_o7 <= {4'd0, weight7};
                end
                3'd1: begin
                    weight_o0 <= {4'd0, weight0};
                    weight_o1 <= {cut, weight1};
                    weight_o2 <= {4'd0, weight2};
                    weight_o3 <= {4'd0, weight3};
                    weight_o4 <= {4'd0, weight4};
                    weight_o5 <= {4'd0, weight5};
                    weight_o6 <= {4'd0, weight6};
                    weight_o7 <= {4'd0, weight7};
                end
                3'd2: begin
                    weight_o0 <= {4'd0, weight0};
                    weight_o1 <= {4'd0, weight1};
                    weight_o2 <= {cut, weight2};
                    weight_o3 <= {4'd0, weight3};
                    weight_o4 <= {4'd0, weight4};
                    weight_o5 <= {4'd0, weight5};
                    weight_o6 <= {4'd0, weight6};
                    weight_o7 <= {4'd0, weight7};
                end
                3'd3: begin
                    weight_o0 <= {4'd0, weight0};
                    weight_o1 <= {4'd0, weight1};
                    weight_o2 <= {4'd0, weight2};
                    weight_o3 <= {cut, weight3};
                    weight_o4 <= {4'd0, weight4};
                    weight_o5 <= {4'd0, weight5};
                    weight_o6 <= {4'd0, weight6};
                    weight_o7 <= {4'd0, weight7};
                end
                3'd4: begin
                    weight_o0 <= {4'd0, weight0};
                    weight_o1 <= {4'd0, weight1};
                    weight_o2 <= {4'd0, weight2};
                    weight_o3 <= {4'd0, weight3};
                    weight_o4 <= {cut, weight4};
                    weight_o5 <= {4'd0, weight5};
                    weight_o6 <= {4'd0, weight6};
                    weight_o7 <= {4'd0, weight7};
                end
                3'd5: begin
                    weight_o0 <= {4'd0, weight0};
                    weight_o1 <= {4'd0, weight1};
                    weight_o2 <= {4'd0, weight2};
                    weight_o3 <= {4'd0, weight3};
                    weight_o4 <= {4'd0, weight4};
                    weight_o5 <= {cut, weight5};
                    weight_o6 <= {4'd0, weight6};
                    weight_o7 <= {4'd0, weight7};
                end
                3'd6: begin
                    weight_o0 <= {4'd0, weight0};
                    weight_o1 <= {4'd0, weight1};
                    weight_o2 <= {4'd0, weight2};
                    weight_o3 <= {4'd0, weight3};
                    weight_o4 <= {4'd0, weight4};
                    weight_o5 <= {4'd0, weight5};
                    weight_o6 <= {cut, weight6};
                    weight_o7 <= {4'd0, weight7};
                end
                3'd7: begin
                    weight_o0 <= {4'd0, weight0};
                    weight_o1 <= {4'd0, weight1};
                    weight_o2 <= {4'd0, weight2};
                    weight_o3 <= {4'd0, weight3};
                    weight_o4 <= {4'd0, weight4};
                    weight_o5 <= {4'd0, weight5};
                    weight_o6 <= {4'd0, weight6};
                    weight_o7 <= {cut, weight7};
                end
            endcase
        end
    end
end





endmodule