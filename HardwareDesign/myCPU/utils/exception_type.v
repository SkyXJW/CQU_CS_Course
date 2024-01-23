`timescale 1ns / 1ps

module exception_type(
    input rst,
    input [7:0] except,
    input [31:0] cp0_status,cp0_cause,
    output reg [31:0] except_type
    );
    always @(*)begin
        if(rst) begin
            except_type <= 32'b0;
        end
        else if((cp0_status[15:8] & cp0_cause[15:8] != 8'h00) &&
                        (cp0_status[1] == 1'b0 && (cp0_status[0] == 1'b1))) begin
                            except_type <= 32'h00000001;//中断
                        end
        else if(except[7] == 1'b1 || except[1] == 1'b1) begin
            except_type <= 32'h00000004;//ADEL
        end
        else if(except[0] == 1'b1) begin
            except_type <= 32'h00000005;//ADSL
        end
        else if(except[5] == 1'b1) begin
            except_type <= 32'h00000008;//Sys
        end
        else if(except[6] == 1'b1) begin
            except_type <= 32'h00000009;//Bp
        end
        else if(except[4] == 1'b1) begin
            except_type <= 32'h0000000e;//Eret
        end
        else if(except[3] == 1'b1) begin
            except_type <= 32'h0000000a;//RI
        end
        else if(except[2] == 1'b1) begin
            except_type <= 32'h0000000c;//Ov
        end
        else
            except_type <= 32'd0;
    end

endmodule