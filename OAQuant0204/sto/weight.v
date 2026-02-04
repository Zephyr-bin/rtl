module weight(
    input wire clk,
    input wire rst_n,
    input wire start,
    output reg bce0,
    output reg bce1,
    output reg bce2,
    output reg bce3,
    output reg [14:0] braddr0,
    output reg [14:0] braddr1,
    output reg [14:0] braddr2,
    output reg [14:0] braddr3,
    output wire weight_load_done
);

reg [4:0] caltime;
reg [11:0] addr;
wire brvalid;
reg pingpang;
reg start_ff1;
reg en;
// assign brvalid = brvalid0 | brvalid1 | brvalid2 | brvalid3;
assign weight_load_done = !en && bce0;

parameter PP_NUM = 15'd32512;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start_ff1 <= 1'b0;
    end else begin
        start_ff1 <= start;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addr <= 12'b0;
        caltime <= 5'd0;
        en <= 1'b0;
    end else if (start)begin
        addr[4:0] <= addr[4:0] + 5'd31;
        caltime <= 5'd1;
        en <= 1'b1;
    end else if(caltime == 5'd0) begin
        en <= 1'b0;
        if(en) begin
            addr[11:5] <= addr[11:5] + 7'd1;
        end
    end else begin
        caltime <= caltime + 5'd1;
        addr[4:0] <= addr[4:0] - 5'd1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bce0 <= 1'b0;
        bce1 <= 1'b0;
        bce2 <= 1'b0;
        bce3 <= 1'b0;
        braddr0 <= 15'd0;
        braddr1 <= 15'd0;
        braddr2 <= 15'd0;
        braddr3 <= 15'd0;
    end else begin
        if(!pingpang) begin
            bce0 <= en;
            bce1 <= en;
            braddr0 <= {addr, 3'd0};
            braddr1 <= {addr, 3'd0};
        end else begin
            bce2 <= en;
            bce3 <= en;
            braddr2 <= {addr, 3'd0};
            braddr3 <= {addr, 3'd0};
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pingpang <= 1'b0;
    end else begin
        if (addr == PP_NUM) begin
            pingpang <= ~pingpang;
        end
    end
end



endmodule