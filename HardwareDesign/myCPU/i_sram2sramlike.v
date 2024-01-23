`timescale 1ns / 1ps

module i_sram2sramlike(
    input wire clk,rst,
    // sram
    input wire inst_sram_en,
    input wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_rdata,
    input wire [3:0] inst_sram_wen,
    input wire [31:0] inst_sram_wdata,
    output wire i_stall,
    input wire longest_stall,// 为了避免由于除法等使得流水线暂停时，访存明明已经完成，但data_sram_en仍然为1，致使重复发送请求的情况产生

    // sram like
    output wire inst_req,
    output wire inst_wr,
    output wire [1:0] inst_size,
    output wire [31:0] inst_addr,
    output wire [31:0] inst_wdata,
    input wire [31:0] inst_rdata,
    input wire inst_addr_ok,
    input wire inst_data_ok
);
// 以下代码参照视频示例实现
reg addr_rcv; // 地址握手成功
always @(posedge clk) begin
    if(rst) begin
        addr_rcv <= 1'b0;
    end
    else if(inst_req & inst_addr_ok & ~inst_data_ok) begin //由于可能会出现addr_ok与data_ok同时有效的情况，但实际上，此时的addr_ok针对的是当前这次的地址传输握手成功，而此时的data_ok针对的是之前某次的数据传输握手成功
                                                     // 因此在此时为了避免误把这里的data_ok当作本次数据传输的握手信号，则采取将data_ok优先的策略，从而保证每次数据传输的addr_rcv有效后（即地址握手成功后），真正属于这次的数据传输才开始
         addr_rcv <= 1'b1;
    end
    else if(inst_data_ok) begin
        addr_rcv <= 1'b0;
    end
end

reg do_finish; // 整个数据访存结束
always @(posedge clk)begin
    if(rst) begin
        do_finish <= 1'b0;
    end
    else if(inst_data_ok) begin
        do_finish <= 1'b1;
    end
    else if(~longest_stall) begin //在没有流水线暂停的设计中，这次访存结束后，便可紧接着着手处理下一次访存请求，这是没有问题的……
                                  /* 然而由于流水线会因为各种原因stall，便会有本次访存明明已经完成，但由于inst_sram_en仍然为1，致使重复发送请求的情况产生
                                  所以在每一次访存结束后，需要检测当前流水线是否还处于stall状态：
                                  如果是，则继续标记本次数据访存已完成，而在后续时钟周期不会再有新的访存请求产生（因为这时候流水线已经被stall），便不再发送请求，所以这时候置inst_req信号为0；
                                  如果不是，则可以着手处理下一次新的访存请求，这时候do_finish便可重新置为0*/
        do_finish <= 1'b0;
    end
end

reg [31:0] inst_rdata_save; //缓存读取的数据，保证在新的数据被成功读取之前，维持上一次被读取的数据不变
always @(posedge clk)begin
    if(rst) begin
        inst_rdata_save <= 32'd0;
    end
    else if(inst_data_ok) begin
        inst_rdata_save <= inst_rdata;
    end
    else begin
        inst_rdata_save <= 32'd0;
    end
end

assign inst_req = inst_sram_en & ~addr_rcv & ~do_finish;
assign inst_wr = inst_sram_en & inst_sram_wen;
assign inst_size = 2'b10;
assign inst_addr = inst_sram_addr;
assign inst_wdata = inst_sram_wdata;

//sram
assign inst_sram_rdata = inst_rdata_save;
assign i_stall = inst_sram_en & ~do_finish;// 这里同样是处于流水线stall情况的考虑，这时候inst_sram_en由于流水线stall而一直为1，但实际上本访存已经完成，所以不再需要要求流水线stall
endmodule