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
    output reg [14:0] braddr3
);

reg [4:0] caltime;
reg [14:0] addr;
wire brvalid;
reg pingpang;
// assign brvalid = brvalid0 | brvalid1 | brvalid2 | brvalid3;


parameter PP_NUM = 15'd32512;

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
        caltime <= 5'd0;
        addr <= 15'd248;
    end else begin
        if (start) begin
            caltime <= 5'd1;
            addr[7:0] <= addr[7:0] - 8'd8;
            if(!pingpang) begin
                bce0 <= 1'b1;
                bce1 <= 1'b1;
                braddr0 <= addr;
                braddr1 <= addr;
            end else begin
                bce2 <= 1'b1;
                bce3 <= 1'b1;
                braddr2 <= addr;
                braddr3 <= addr;
            end
        end else if (caltime == 5'd0) begin
            bce0 <= 1'b0;
            bce1 <= 1'b0;
            bce2 <= 1'b0;
            bce3 <= 1'b0;
        end else begin
            caltime <= caltime + 5'd1;
            if(caltime != 5'd31) begin
                addr[7:0] <= addr[7:0] - 8'd8;
            end else begin
                addr[7:0] <= 8'd248;
                addr[14:8] <= addr[14:8] + 7'd1;
            end
            if(!pingpang) begin
                braddr0 <= addr;
                braddr1 <= addr;
            end else begin
                braddr2 <= addr;
                braddr3 <= addr;
            end
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