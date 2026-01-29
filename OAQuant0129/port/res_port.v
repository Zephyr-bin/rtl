module res_port(
    input wire clk,
    input wire rst_n,
    input wire res_port_start,    // 启动本次传输
    output reg bce_0, bce_1, bce_2, bce_3, bce_4, bce_5, bce_6, bce_7,
    output reg [14:0] braddr_0, braddr_1, braddr_2, braddr_3, braddr_4, braddr_5, braddr_6, braddr_7,
    input wire [127:0] brdata_0, brdata_1, brdata_2, brdata_3, brdata_4, brdata_5, brdata_6, brdata_7,
    input wire brvalid_0, brvalid_1, brvalid_2, brvalid_3, brvalid_4, brvalid_5, brvalid_6, brvalid_7,
    output reg [255:0] data_o,
    output reg done               // 本次传输完成信号
);



endmodule