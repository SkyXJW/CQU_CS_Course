`timescale 1ns / 1ps

module d_sram2sramlike(
    input wire clk,rst,
    // sram
    input wire  data_sram_en,
    input wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_rdata,
    input wire [3:0] data_sram_wen,
    input wire [31:0] data_sram_wdata,
    output wire d_stall,
    input wire longest_stall,// 为了避免由于除法等使得流水线暂停时，访存明明已经完成，但data_sram_en仍然为1，致使重复发送请求的情况产生

    // sram like
    output wire data_req,
    output wire data_wr,
    output wire [1:0] data_size,
    output wire [31:0] data_addr,
    output wire [31:0] data_wdata,
    input wire [31:0] data_rdata,
    input wire data_addr_ok,
    input wire data_data_ok,

    // ugly patches
    input gap_stall
);
// 以下代码参照视频示例实现
reg addr_rcv; // 地址握手成功
always @(posedge clk) begin
    if(rst) begin
        addr_rcv <= 1'b0;
    end
    else if(data_req & data_addr_ok & ~data_data_ok) begin //由于可能会出现addr_ok与data_ok同时有效的情况，但实际上，此时的addr_ok针对的是当前这次的地址传输握手成功，而此时的data_ok针对的是之前某次的数据传输握手成功
                                                     // 因此在此时为了避免误把这里的data_ok当作本次数据传输的握手信号，则采取将data_ok优先的策略，从而保证每次数据传输的addr_rcv有效后（即地址握手成功后），真正属于这次的数据传输才开始
         addr_rcv <= 1'b1;
    end
    else if(data_data_ok) begin
        addr_rcv <= 1'b0;
    end
end

reg do_finish; // 整个数据访存结束
always @(posedge clk)begin
    if(rst) begin
        do_finish <= 1'b0;
    end
    else if(data_data_ok) begin
        do_finish <= 1'b1;
    end
    else if(~longest_stall && ~gap_stall) begin //在没有流水线暂停的设计中，这次访存结束后，便可紧接着着手处理下一次访存请求，这是没有问题的……
                                  /* 然而由于流水线会因为各种原因stall，便会有本次访存明明已经完成，但由于data_sram_en仍然为1，致使重复发送请求的情况产生
                                  所以在每一次访存结束后，需要检测当前流水线是否还处于stall状态：
                                  如果是，则继续标记本次数据访存已完成，而在后续时钟周期不会再有新的访存请求产生（因为这时候流水线已经被stall），便不再发送请求，所以这时候置data_req信号为0；
                                  如果不是，则可以着手处理下一次新的访存请求，这时候do_finish便可重新置为0*/
        do_finish <= 1'b0;
    end
end

reg [31:0] data_rdata_save; //缓存读取的数据，保证在新的数据被成功读取之前，维持上一次被读取的数据不变
always @(posedge clk)begin
    if(rst) begin
        data_rdata_save <= 32'd0;
    end
    else if(data_data_ok) begin
        data_rdata_save <= data_rdata;
    end
end

assign data_req = data_sram_en & ~addr_rcv & ~do_finish;
assign data_wr = data_sram_en & (data_sram_wen[0]|data_sram_wen[1]|data_sram_wen[2]|data_sram_wen[3]);
// assign data_size = (data_sram_wen==4'b0001 || data_sram_wen==4'b0010 || data_sram_wen==4'b0100 || data_sram_wen==4'b1000) ? 2'b00:
//                    (data_sram_wen==4'b0011 || data_sram_wen==4'b1100) ? 2'b01 : 2'b10;
assign data_size = ((data_sram_wen==4'b0001) || (data_sram_wen==4'b0010) || (data_sram_wen==4'b0100) || (data_sram_wen==4'b1000)) ? 2'b00:
                       ((data_sram_wen==4'b0011) || (data_sram_wen==4'b1100) ) ? 2'b01 : 2'b10;
assign data_addr = data_sram_addr;
assign data_wdata = data_sram_wdata;

//sram
assign data_sram_rdata = data_rdata_save;
assign d_stall = data_sram_en & ~do_finish;// 这里同样是处于流水线stall情况的考虑，这时候data_sram_en由于流水线stall而一直为1，但实际上本访存已经完成，所以不再需要要求流水线stall
endmodule