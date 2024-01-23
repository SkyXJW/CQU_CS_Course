`timescale 1ns / 1ps

module mul(
    input [31:0] a,b,
    input isSign,
    output reg [31:0] hi,lo
);

wire [31:0] mult_a,mult_b;
//判断被乘数、乘数符号，如果是负数，取补码
assign mult_a = (a[31]==1'b1) ? ((~a)+1) : a;
assign mult_b = (b[31]==1'b1) ? ((~b)+1) : b;

wire [63:0] abs_result  = mult_a * mult_b;
//对结果进行修正
wire [63:0] sign_result = (a[31]^b[31]) ? ((~abs_result)+1) : abs_result;
//如果是有符号乘法且两个乘数异号，则将上述求补码得到的结果sing_result作为最终结果
wire [63:0] result = (isSign) ? sign_result : a * b;
always @(*)begin
    hi = result[63:32];
    lo = result[31:0];
end
endmodule