`include "./control_signal_define.vh"
`timescale 1ns / 1ps

module memload_filter #(parameter WIDTH = 32)(
    input [WIDTH-1:0] addr,
    input [WIDTH-1:0] memLoadData,
    input [3:0] memReadWidth,
    input memLoadIsSign,
    output reg [WIDTH-1:0] loadDataFiltered
    );

    // 根据addr的偏移来确定LH是低半字还是高半字
    //                  LB是哪个字节
    // 例如，如果addr是10，那么LH就是高半字（也可以看作将原本的0011左移两位，变成1100）
    // 再例如，如果addr是11，那么LB就是最高的那个字节（也可以看作将原本的0001左移三位，变成1000）
    // wire [3:0] memReadMask = memReadWidth << addr[1:0];
    reg [3:0] memReadMask;

    always @(*) begin
        memReadMask = memReadWidth << addr[1:0];
        case(memReadWidth)
            `memReadWidth_WORD: loadDataFiltered = memLoadData[31:0];
            `memReadWidth_HALF: begin
                case(memReadMask)
                    4'b0011:   begin
                        loadDataFiltered = (memLoadIsSign) ?
                            {{16{memLoadData[15]}}, memLoadData[15:0]} :
                            {{16{1'b0}}, memLoadData[15:0]};
                    end
                    4'b1100:   begin
                        loadDataFiltered = (memLoadIsSign) ?
                            {{16{memLoadData[31]}}, memLoadData[31:16]} :
                            {{16{1'b0}}, memLoadData[31:16]};
                    end
                    default:   loadDataFiltered = memLoadData; // 按理说不应出现这种情况，可能需要例外
                endcase
            end
            `memReadWidth_BYTE: begin
                case(memReadMask)
                    4'b0001: begin
                        loadDataFiltered = (memLoadIsSign) ?
                            {{24{memLoadData[7]}}, memLoadData[7:0]} :
                            {{24{1'b0}}, memLoadData[7:0]};
                    end
                    4'b0010: begin
                        loadDataFiltered = (memLoadIsSign) ?
                            {{24{memLoadData[15]}}, memLoadData[15:8]} :
                            {{24{1'b0}}, memLoadData[15:8]};
                    end
                    4'b0100: begin
                        loadDataFiltered = (memLoadIsSign) ?
                            {{24{memLoadData[23]}}, memLoadData[23:16]} :
                            {{24{1'b0}}, memLoadData[23:16]};
                    end
                    4'b1000: begin
                        loadDataFiltered = (memLoadIsSign) ?
                            {{24{memLoadData[31]}}, memLoadData[31:24]} :
                            {{24{1'b0}}, memLoadData[31:24]};
                    end
                    default:   loadDataFiltered = memLoadData; // 按理说不应出现这种情况，可能需要例外
                endcase
            end
            default:           loadDataFiltered = memLoadData;
        endcase
    end

endmodule
