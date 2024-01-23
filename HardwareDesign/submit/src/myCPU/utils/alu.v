`include "./defines2.vh"
`timescale 1ns / 1ps

module alu(
    input [31:0]num1,
    input [31:0]num2,
    input [4:0]sa,
    input [4:0]op,
    input mdToHilo,
    output reg [31:0]result,
    output reg overflow //只考虑ADD、ADDI、SUB三条有符号算术运算指令的溢出
    );

    reg [32:0] temp; // 多了一位用于检验溢出

    always @(*) begin
        case(op)
            // 算术
            `ADD_CONTROL: begin
                result = num1 + num2;
                temp = {num1[31],num1} + {num2[31],num2};
                overflow = (mdToHilo == 1'b0) ? (temp[32]!=temp[31]) : 1'b0;
            end
            `SUB_CONTROL: begin
                result = num1 - num2;
                temp = {num1[31],num1} - {num2[31],num2};
                overflow = (mdToHilo == 1'b0) ? (temp[32]!=temp[31]) : 1'b0;
            end
            `ADDU_CONTROL: begin
                result = num1 + num2;
                overflow = 1'b0;
            end
            `SUBU_CONTROL: begin
                result = num1 - num2;
                overflow = 1'b0;
            end
            `SLT_CONTROL: begin
                result = ($signed(num1) < $signed(num2)) ? 1'b1 : 1'b0;
                overflow = 1'b0;
            end
            `SLTU_CONTROL: begin
                result = (num1 < num2) ? 1'b1 : 1'b0;
                overflow = 1'b0;
            end
            // 逻辑
            `AND_CONTROL: begin
                result = num1 & num2;
                overflow = 1'b0;
            end
            `OR_CONTROL: begin
                result = num1 | num2;
                overflow = 1'b0;
            end
            `XOR_CONTROL: begin
                result = num1 ^ num2;
                overflow = 1'b0;
            end
            `NOR_CONTROL: begin
                result = ~(num1 | num2);
                overflow = 1'b0;
            end
            // 位移
            `SLL_CONTROL: begin
                result = num2 << sa;
                overflow = 1'b0;
            end
            `SRL_CONTROL: begin
                result = num2 >> sa;
                overflow = 1'b0;
            end
            `SRA_CONTROL: begin
                result = $signed(num2) >>> sa;
                overflow = 1'b0;
            end
            `SLLV_CONTROL: begin
                result = num2 << num1[4:0];
                overflow = 1'b0;
            end
            `SRLV_CONTROL: begin
                result = num2 >> num1[4:0];
                overflow = 1'b0;
            end
            `SRAV_CONTROL: begin
                result = $signed(num2) >>> num1[4:0];
                overflow = 1'b0;
            end
            // ...
            default: begin
                result = 32'hxxxx_xxxx;
                overflow = 1'b0;
            end
        endcase
    end
// assign result =
//                 // 算术运算
//                 (op==`ADD_CONTROL)  ?   (num1+num2):    // ADD
//                 (op==`SUB_CONTROL)  ?   (num1-num2):    // SUB
//                 (op==`SLT_CONTROL)  ?   (num1<num2):    // SLT
//                 // 逻辑运算
//                 (op==`AND_CONTROL)  ?   (num1&num2):    // AND
//                 (op==`OR_CONTROL)   ?   (num1|num2):    // OR
//                 (op==`XOR_CONTROL)  ?   (num1^num2):    // XOR
//                 (op==`NOR_CONTROL)  ?   (~(num1|num2)): // NOR
//                 // 位移运算
//                 (op==`SLL_CONTROL)  ?   (num2<<sa):     //SLL
//                 (op==`SRL_CONTROL)  ?   (num2>>sa):     //SRL
//                 (op==`SRA_CONTROL)  ?   ({32{num2[31]}} << (6'd32 - {1'b0,sa})) | num2 >> sa: //SRA
//                 (op==`SLLV_CONTROL) ?   (num2<<num1[4:0]): //SLLV
//                 (op==`SRLV_CONTROL) ?   (num2>>num1[4:0]): //SRLV
//                 (op==`SRAV_CONTROL) ?   ({32{num2[31]}} << (6'd32 - {1'b0,num1[4:0]})) | num2 >> num1[4:0]: //SRAV
//                 32'hxxxx_xxxx;
endmodule
