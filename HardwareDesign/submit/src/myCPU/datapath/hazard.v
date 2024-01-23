`timescale 1ns / 1ps

module hazard(
    input d_stall,i_stall,
	input gap_stall,
    output longest_stall,
	//fetch stage
	output stallF,
	output flushF,

	//decode stage
	input [4:0] rsD,rtD,
	input branchD,jrD,
	output forwardaD,forwardbD,
	output stallD,
	output jrstall_READ,
	output flushD,

	//execute stage
	input [4:0] rsE,rtE,
	input [4:0] writeregE,
	input regwriteE,
	input memtoregE,
    input hilotoregE,hilosrcE,
    input stall_divE,
	input div_stall_extend,
    input cp0ToRegE,
    input [4:0] readcp0AddrE,
	input div_readyE,
	output [4:0] forwardaE,forwardbE,
	output flushE,
    output forwardHIE,forwardLOE,
    output stallE,
    output forwardCP0E,

	//mem stage
	input [4:0] writeregM,
	input regwriteM,
	input memtoregM,
    input hilowriteM,
    input regToHilo_hiM,regToHilo_loM,mdToHiloM,
    input isWritecp0M,
    input [4:0] writecp0AddrM,
    input [31:0] except_typeM,cp0_epcM,
    input hilotoregM,cp0ToRegM,
    output reg [31:0] newPCM,
	output flushM,stallM,

	//write back stage
	input [4:0] writeregW,
	input regwriteW,
	output flushW,stallW
);

	wire lwstallD,branchstallD,jrstall_WRITE;


	// [数据冒险]
	// 			-> 前推
	// 读的不是$zero & M/W阶段的寄存器号与需要前推的E阶段寄存器号对的上 & 写使能开着，确实还没写入
	// assign forwardaE = 	((rsE!=0) & (rsE == writeregM & regwriteM)) ? 2'b10:
	// 					((rsE!=0) & (rsE == writeregW & regwriteW)) ? 2'b01:
	// 					2'b00;
	// assign forwardbE = 	((rtE!=0) & (rtE == writeregM & regwriteM)) ? 2'b10:
	// 					((rtE!=0) & (rtE == writeregW & regwriteW)) ? 2'b01:
	// 					2'b00;
    assign forwardaE = ((rsE!=0) & (rsE == writeregM & regwriteM)) ? 
                       ((cp0ToRegM) ? 5'b10000 :
                       (hilotoregM) ? 5'b01000 :
                       (memtoregM)  ? 5'b00100 : 5'b00010) :
                       (((rsE!=0) & (rsE == writeregW & regwriteW)) ? 5'b00001:5'b00000);
    assign forwardbE = ((rtE!=0) & (rtE == writeregM & regwriteM)) ? 
                       ((cp0ToRegM) ? 5'b10000 :
                       (hilotoregM) ? 5'b01000 :
                       (memtoregM)  ? 5'b00100 : 5'b00010) :
                       (((rtE!=0) & (rtE == writeregW & regwriteW)) ? 5'b00001:5'b00000); 

    // 针对数据移动指令（MF、MT）的数据前推
    // E阶段需要读hilo_reg & M阶段hilo_reg需要写的寄存器号与需要前推的E阶段hilo_reg需要读的寄存器号相同 & M阶段hilo_reg的写使能有效
    assign forwardHIE = ((hilotoregE) & (hilosrcE & (regToHilo_hiM | mdToHiloM)) & (hilowriteM)) ? 1'b1 : 1'b0;
    assign forwardLOE = ((hilotoregE) & (!hilosrcE & (regToHilo_loM | mdToHiloM)) & (hilowriteM)) ? 1'b1 : 1'b0;

    // 针对特权指令（MTC0、MFC0）的数据前推
    // E阶段需要读CP0 & M阶段CP0x需要写的寄存器地址与需要前推的E阶段CP0需要读的寄存器地址一致 & M阶段CP0的写使能有效
    assign forwardCP0E = ((cp0ToRegE) & (writecp0AddrM == readcp0AddrE) & (isWritecp0M)) ? 1'b1 : 1'b0;

	// 			-> 暂停
	// 假设当前指令是lw，下一条指令刚好需要lw写入的寄存器。当下一条指令执行至EXE阶段时，当前指令
	// 才到MEM阶段，而直至WB阶段才能从内存拿到写入寄存器的值。因而，无奈之举便是暂停下一条指令
	assign lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	/*
	assign stallD = lwstallD;
	assign stallF = lwstallD;
	assign flushE = lwstallD;
	*/
	// 上面的三个被控制冒险中的新写法所覆盖


	// [控制冒险]
	// 			-> 前推
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
	// 			-> 暂停
	// branch指令，如BEQ，需要在DECODE查看rt和rs寄存器。如果是上上一条指令有冒险，可以从MEM阶段前推过来
	// 但如果是上一条指令有冒险，当前指令在D阶段，上一条刚在EXE阶段，得不到Aluout，不能前推，因此要暂停当前指令
	// 判断条件：当前为branch & 上一条确实要写入寄存器，但没来得及 & E/M 目前的寄存器号与上一条的M/W阶段寄存器号对的上
	// branchstallD 可以涵盖：BEQ，BNE，BGEZ，BGTZ，BLEZ，BLTZ
	// 因为在DATAPATH设计中，writeregE可能被覆盖为31号，所以对于BGEZAL和BLTZAL也不用多写判断了
	assign branchstallD = 	(branchD & regwriteE & (writeregE == rsD | writeregE == rtD)) |
							(branchD & memtoregM & (writeregM == rsD | writeregM == rtD));

	// 同理，对于JR和JALR，因为它们要在DECODE阶段读rs的值，因此也要判断暂停DECODE阶段
	assign jrstall_READ = jrD & memtoregM & (writeregE == rsD);


	// 对JR指令不会产生，而是对JALR，因为其会将当前PC+8写回rd寄存器，
	// 因此可能产生RAW冒险，需要先暂停
	assign jrstall_WRITE = jrD && regwriteE && (writeregE == rsD);


	// [汇总后产生的stall信号]


	// 例如：出现eret，所有如pcM,pcW,pcE都被flush掉。就pcD由于出现lwstallD而不flush掉，这不合理吧？
	// 所以变成了 except_typemM == 32'd0 && ...
	assign stallD = (except_typeM == 32'd0) && (lwstallD | branchstallD | jrstall_READ | jrstall_WRITE | stall_divE | d_stall | gap_stall | i_stall | div_stall_extend);
	assign stallF = (except_typeM == 32'd0) && (lwstallD | branchstallD | jrstall_READ | jrstall_WRITE | stall_divE | d_stall | gap_stall | i_stall | div_stall_extend);
	assign flushE = (lwstallD | branchstallD | jrstall_READ | (except_typeM!=32'd0)) && !gap_stall;
	assign stallE = stall_divE | d_stall | gap_stall | i_stall | div_stall_extend;
	assign stallM = stall_divE | d_stall | gap_stall | i_stall | div_stall_extend;
	assign stallW = stall_divE | d_stall | gap_stall | i_stall | div_stall_extend;
	// 注意，longest_stall并不包含gap_stall，原因详见datapath.v中hazard模块上方的内容
	assign longest_stall = stall_divE | d_stall | i_stall;

	assign flushF = (except_typeM!=32'd0);
	assign flushD = (except_typeM!=32'd0);
	assign flushM = (except_typeM!=32'd0);
	assign flushW = (except_typeM!=32'd0);

    // 根据当前得到的例外类型跳转到例外处理程序入口（除了ERET外，都统一跳到0xBFC00380）
    always @(*) begin
        if(except_typeM != 32'b0) begin
            case(except_typeM)
                32'h00000001:begin newPCM <= 32'hBFC00380; end
                32'h00000004:begin newPCM <= 32'hBFC00380; end
                32'h00000005:begin newPCM <= 32'hBFC00380; end
                32'h00000008:begin newPCM <= 32'hBFC00380; end
                32'h00000009:begin newPCM <= 32'hBFC00380; end
                32'h0000000a:begin newPCM <= 32'hBFC00380; end
                32'h0000000c:begin newPCM <= 32'hBFC00380; end
                32'h0000000e:begin newPCM <= cp0_epcM; end
            endcase
        end
    end
endmodule
