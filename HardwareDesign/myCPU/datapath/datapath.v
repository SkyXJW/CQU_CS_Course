`include "../utils/defines2.vh"
`include "../utils/control_signal_define.vh"
`timescale 1ns / 1ps

module datapath(
	input clk,rst,d_stall,i_stall,
    output longest_stall,
	output reg gap_stall,
	//fetch stage
	input [31:0] instrF,
	output [31:0] pcF,
	//decode stage
	input pcsrcD,branchD,
	input jumpD,jalD,jrD,
	input ex_bpD, ex_sysD, ex_riD,
	output reg validBranchConditionD,
	output [4:0] rsD,rtD,rdD,
	output [5:0] opD,functD,
	//execute stage
	input memtoregE,
	input alusrcE,regdstE,
	input regwriteE,
	input [4:0] alucontrolE,
	input balE, jalE, jrE,
    input hilotoregE, hilosrcE,
    input mulOrdivE,mdIsSignE,mdToHiloE,
	input [3:0] memwriteE,
    input isWritecp0E,
    input [4:0] writecp0AddrE,readcp0AddrE,
    input cp0ToRegE,
    input branchE,jumpE,jalrE,
	output flushE,stallE,
	output reg div_stall_extend,
	output div_readyE,
	//mem stage
	input memtoregM,
	input regwriteM,
    input hilowriteM,hilotoregM,hilosrcM,
	input [31:0] readdataM,
    input regToHilo_hiM,regToHilo_loM,mdToHiloM,
	input [3:0] memReadWidthM,
	input memLoadIsSignM,
    input isWritecp0M,
    input [4:0] writecp0AddrM,
    input cp0ToRegM,
    input branchM,jumpM,jalM,jrM,jalrM,
	output [31:0] aluoutM,writedataExtendedM,
	output [3:0] memwrite_filterdM,
	output flushM,stallM,
	output hasExceptionM,
	//writeback stage
	input memtoregW,
	input regwriteW,
    input hilotoregW,
    input cp0ToRegW,
    output [31:0] pcW,
    output [4:0] writeregW,
    output [31:0] result_filterdW,
	output flushW,stallW,
	output rstCompleteMessageW
);

    //测试数据，暂时用于代表乘法结果与除法结果
    wire [31:0] mulResult_hiE,mulResult_loE;//乘法结果
    wire [31:0] divResult_hiE,divResult_loE;//除法结果
	//fetch stage
	wire stallF;
	wire [31:0] pc_plus4F;
	wire [7:0] checkExceptionF;
	wire flushF;
	wire rstCompleteMessageF;

	//decode stage
	wire [31:0] pc_afterjumpD,pc_afterbranchD,pc_branch_offsetD;
	wire [31:0] pc_plus4D, pc_plus8D, instrD;
	wire forwardaD,forwardbD;
	wire jrstall_READ;
	wire stallD;
	wire [31:0] signimmD,signimm_slD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D,srca3D,srcb3D;
    wire [4:0] saD;
    wire [31:0] HID,LOD;
    wire [31:0] pcD;
	wire [7:0] checkExceptionD;
	wire flushD;
	wire rstCompleteMessageD;

	//execute stage
	wire [4:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] writeregE;
	wire [31:0] pc_plus4E, pc_plus8E;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE;
    wire [4:0] saE;
    wire [31:0] HIE,HI2E,LOE,LO2E;
    wire forwardHIE,forwardLOE;
    wire [31:0] mdResult_hiE,mdResult_loE;
	wire rstCompleteMessageE;

	wire [7:0] checkExceptionE;
    wire [31:0] cp0_dataE,cp0_data2E;
    wire forwardCP0E;
    reg start_divE;
    wire ex_ovE;
    wire [31:0] cp0_countE,cp0_compareE,cp0_statusE,cp0_causeE,cp0_epcE,cp0_configE,cp0_pridE,cp0_badvaddrE;
    wire cp0_timer_intE;
    wire isInDelayslotE;
    assign isInDelayslotE = (branchM | jumpM | jalM | jrM | jalrM);
    wire [31:0] pcE;

	//mem stage
	wire [4:0] writeregM;
    wire [31:0] srcaM,srcbM;
    wire [31:0] HIM,HI2M,LOM,LO2M;
    wire [31:0] hilooutM;
    wire [31:0] mdResult_hiM,mdResult_loM;
	wire [31:0] writedataM;
	wire [3:0] memwriteM;
    wire [31:0] cp0_dataM;
    wire [31:0] except_typeM;
    wire [31:0] cp0_countM,cp0_compareM,cp0_statusM,cp0_causeM,cp0_epcM,cp0_configM,cp0_pridM,cp0_badvaddrM;
    wire cp0_timer_intM;
    wire isInDelayslotM;
    wire [31:0] pcM;
    wire [31:0] badAddrM;
    wire [31:0] newPCM;
	wire [7:0] checkExceptionM;
	wire rstCompleteMessageM;

	//writeback stage
	wire [31:0] aluoutW,readdataW,resultW,hilooutW;
	wire [3:0] memReadWidthW;
	wire memLoadIsSignW;
    wire [31:0] cp0_dataW;



	// =======================================================================================
	// 			对流水线五个flip-flop的暂存，及其data/control hazard发生的改变
	// =======================================================================================

	// 有可能暂停的flip要带en
	// 有可能flush的flip要带clear

	// [fetch -> decode]
	// 暂存
	flopenrc r1D(clk,rst,~stallD,flushD,pc_plus4F,pc_plus4D);
	flopenrc r2D(clk,rst,~stallD,flushD,instrF,instrD);
    flopenrc r4D(clk,rst,~stallD,flushD,pcF,pcD);
    flopenrc #(8) exceptionF2D(clk,rst,~stallD,flushD,{checkExceptionF[7],7'd0},checkExceptionD);
	flopenr #(1) rstCompleteMessageF2D(clk,rst,~stallD,rstCompleteMessageF,rstCompleteMessageD);

	// flopenr r1D(clk,rst,~stallD,pc_plus4F,pc_plus4D);
	// flopenr r2D(clk,rst,~stallD,instrF,instrD);
    // flopenr r4D(clk,rst,~stallD,pcF,pcD);
    // flopenr #(8) exceptionF2D(clk,rst,~stallD,{checkExceptionF[7],7'd0},checkExceptionD);

	// 前推
	// D阶段要读rs，那么看是否需要有会写入rs寄存器的指令在MEM阶段，如果有就前推
	// 如果要前推，如果是从hilo寄存器写入rs，那么就推hilooutM
	// 			 如果是从cp0寄存器写入rs，那么就推cp0_dataM
	// 			 否则就是从alu的结果写入rs，推aluoutM
	wire [2:0] forwardaSelectD,forwardbSelectD;
	assign forwardaSelectD = (forwardaD) ? (
		(hilotoregM) ? 3'b010 :
		(cp0ToRegM) ? 3'b100 :
		3'b001
	) : 3'b000;
	assign forwardbSelectD = (forwardbD) ? (
		(hilotoregM) ? 3'b010 :
		(cp0ToRegM) ? 3'b100 :
		3'b001
	) : 3'b000;
	mux4 forwardamux(srcaD,aluoutM,hilooutM,cp0_dataM,forwardaSelectD,srca2D);
	mux4 forwardbmux(srcbD,aluoutM,hilooutM,cp0_dataM,forwardbSelectD,srcb2D);
	// 额外forwardaD前推：二选一，如果是从mem读到的内容需要前推，那么就推readdataM
	mux2 forwardJR(srca2D,readdataM,jrstall_READ | (forwardaD & memtoregM), srca3D);
	mux2 forwardJR2(srcb2D,readdataM,jrstall_READ | (forwardbD & memtoregM), srcb3D);
	// assign srcb3D = srcb2D;

	// [decode]
	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
    assign saD = instrD[10:6];

	wire ex_eretD;
	assign ex_eretD = (instrD == 32'b01000010000000000000000000011000) ? 1'b1 : 1'b0;

	// 提前在decode判断branch
	// 根据指令不同，判断是否valid的格式也不同
	always @(*) begin
		case(opD)
			`BEQ: validBranchConditionD = (srca3D == srcb3D);
			`BNE: validBranchConditionD = (srca3D != srcb3D);
			`BGTZ: validBranchConditionD = (~srca3D[31]) & (srca3D != 32'd0);
			`BLEZ: validBranchConditionD = (srca3D[31] || srca3D == 32'd0);
			`BG_EXT_INST: begin // BG_EXT_INST = 000001, contains: BGEZ,BLTZ,BGEZAL,BLTZAL,
				case(rtD)
					`BGEZ: validBranchConditionD = (~srca3D[31]);
					`BLTZ: validBranchConditionD = (srca3D[31]);
					`BGEZAL: validBranchConditionD = (~srca3D[31]);
					`BLTZAL: validBranchConditionD = (srca3D[31]);
					default: validBranchConditionD = 1'b0;
				endcase
			end
		endcase
	end

	// [decode -> execute]
	// 暂存
	flopenrc r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE); // 如果只有暂存，rsD没必要推过去，但rsE对hazard前推有用
	flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
    flopenrc #(5) r7E(clk,rst,~stallE,flushE,saD,saE);
	flopenrc #(32) r8E(clk,rst,~stallE,flushE,pc_plus8D,pc_plus8E);
    flopenrc r9E(clk,rst,~stallE,flushE,HID,HIE);
    flopenrc r10E(clk,rst,~stallE,flushE,LOD,LOE);
    flopenrc r12E(clk,rst,~stallE,flushE,pcD,pcE);
    flopenrc #(8) exceptionD2E(clk,rst,~stallE,flushE,{checkExceptionD[7],ex_bpD,ex_sysD,ex_eretD,ex_riD,3'b000},checkExceptionE);
	flopenr #(1) rstCompleteMessageD2E(clk,rst,~stallD,rstCompleteMessageD,rstCompleteMessageE);
	// 前推
	// forwardE =10，M阶段的要推过去
	// forwardE =01，W阶段的要推过去
	// 如果是M阶段，且cp0toregM为1，那么说明是从cp0_dataM推的，否则是aluoutM推的
	// E阶段在ALU计算前，可能会使用rs/rt的数据，那么前面指令若要写入rs/rt，就需要前推

	// wire [31:0] srca1_5E, srcb1_5E;
	// wire [2:0] forwardaSelectE, forwardbSelectE;
	// wire forwardaSelect2E, forwardbSelect2E;
	// assign forwardaSelectE =
	// 	(forwardaE == 2'b10) ? (
	// 		(cp0ToRegM) ? 3'b100 	// cp0toregM
	// 		: 3'b010  				// aluoutM
	// 	) : ((forwardaE == 2'b01) ? (
	// 		3'b001 					// result_filteredW
	// 	) : 3'b000);					// none
	// assign forwardbSelectE =
	// 	(forwardbE == 2'b10) ? (
	// 		(cp0ToRegM) ? 3'b100 	// cp0toregM
	// 		: 3'b010  				// aluoutM
	// 	) : ((forwardbE == 2'b01) ? (
	// 		3'b001 					// result_filteredW
	// 	) : 3'b000);					// none
	// assign forwardaSelect2E = (forwardaE == 2'b01 & cp0ToRegW) ? 1'b1 : 1'b0;
	// assign forwardbSelect2E = (forwardbE == 2'b01 & cp0ToRegW) ? 1'b1 : 1'b0;
	// mux4 forwardaemux(srcaE,result_filterdW,aluoutM,cp0_dataM,forwardaSelectE,srca1_5E);
	// mux4 forwardbemux(srcbE,result_filterdW,aluoutM,cp0_dataM,forwardbSelectE,srcb1_5E);
	// mux2 forwardae2mux(srca1_5E, cp0_dataW, forwardaSelect2E, srca2E);
	// mux2 forwardbe2mux(srcb1_5E, cp0_dataW, forwardbSelect2E, srcb2E);
	// // mux3 forwardaemux(srcaE,result_filterdW,aluoutM,forwardaE,srca2E);
	// // mux3 forwardbemux(srcbE,result_filterdW,aluoutM,forwardbE,srcb2E);

    //cunstom前推 begin
    mux6 forwardaemux(srcaE,cp0_dataM,hilooutM,readdataM,aluoutM,result_filterdW,forwardaE,srca2E);
	mux6 forwardbemux(srcbE,cp0_dataM,hilooutM,readdataM,aluoutM,result_filterdW,forwardbE,srcb2E);
    // end
    mux2 forwardHIEmux(HIE,HI2M,forwardHIE,HI2E);
    mux2 forwardLOEmux(LOE,LO2M,forwardLOE,LO2E);
    mux2 forwardCP0Emux(cp0_dataE,srcbM,forwardCP0E,cp0_data2E);

	// [execute -> mem]
	// 暂存
	flopenrc r1M(clk,rst,~stallM,flushM,srcb2E,writedataM);
	flopenrc r2M(clk,rst,~stallM,flushM,aluoutE,aluoutM);
	flopenrc #(5) r3M(clk,rst,~stallM,flushM,writeregE,writeregM);
    flopenrc r5M(clk,rst,~stallM,flushM,srca2E,srcaM);
    flopenrc r6M(clk,rst,~stallM,flushM,HI2E,HIM);
    flopenrc r7M(clk,rst,~stallM,flushM,LO2E,LOM);
    flopenrc r8M(clk,rst,~stallM,flushM,mdResult_hiE,mdResult_hiM);
    flopenrc r9M(clk,rst,~stallM,flushM,mdResult_loE,mdResult_loM);
	flopenrc #(4) r10M(clk,rst,~stallM,flushM,memwriteE,memwriteM);
    flopenrc r11M(clk,rst,~stallM,flushM,srcb3E,srcbM);
    flopenrc r12M(clk,rst,~stallM,flushM,cp0_data2E,cp0_dataM);
    flopenrc r14M(clk,rst,~stallM,flushM,cp0_countE,cp0_countM);
    flopenrc r15M(clk,rst,~stallM,flushM,cp0_compareE,cp0_compareM);
    flopenrc r16M(clk,rst,~stallM,flushM,cp0_statusE,cp0_statusM);
    flopenrc r17M(clk,rst,~stallM,flushM,cp0_causeE,cp0_causeM);
    flopenrc r18M(clk,rst,~stallM,flushM,cp0_epcE,cp0_epcM);
    flopenrc r19M(clk,rst,~stallM,flushM,cp0_configE,cp0_configM);
    flopenrc r20M(clk,rst,~stallM,flushM,cp0_badvaddrE,cp0_badvaddrM);
    flopenrc #(1) r21M(clk,rst,~stallM,flushM,cp0_timer_intE,cp0_timer_intM);
    flopenrc r22M(clk,rst,~stallM,flushM,pcE,pcM);
    flopenrc #(1) r23M(clk,rst,~stallM,flushM,isInDelayslotE,isInDelayslotM);
    flopenrc #(6) exceptionE2M(clk,rst,~stallM,flushM,{checkExceptionE[7:3],ex_ovE},checkExceptionM[7:2]);
	flopenr #(1) rstCompleteMessageE2M(clk,rst,~stallD,rstCompleteMessageE,rstCompleteMessageM);


	// flopr r1M(clk,rst,srcb2E,writedataM);
	// flopr r2M(clk,rst,aluoutE,aluoutM);
	// flopr #(5) r3M(clk,rst,writeregE,writeregM);
    // flopr r5M(clk,rst,srca2E,srcaM);
    // flopr r6M(clk,rst,HI2E,HIM);
    // flopr r7M(clk,rst,LO2E,LOM);
    // flopr r8M(clk,rst,mdResult_hiE,mdResult_hiM);
    // flopr r9M(clk,rst,mdResult_loE,mdResult_loM);
	// flopr #(4) r10M(clk,rst,memwriteE,memwriteM);
    // flopr r11M(clk,rst,srcb3E,srcbM);
    // flopr r12M(clk,rst,cp0_data2E,cp0_dataM);
    // flopr r14M(clk,rst,cp0_countE,cp0_countM);
    // flopr r15M(clk,rst,cp0_compareE,cp0_compareM);
    // flopr r16M(clk,rst,cp0_statusE,cp0_causeM);
    // flopr r17M(clk,rst,cp0_causeE,cp0_causeM);
    // flopr r18M(clk,rst,cp0_epcE,cp0_epcM);
    // flopr r19M(clk,rst,cp0_configE,cp0_configM);
    // flopr r20M(clk,rst,cp0_badvaddrE,cp0_badvaddrM);
    // flopr #(1) r21M(clk,rst,cp0_timer_intE,cp0_timer_intM);
    // flopr r22M(clk,rst,pcE,pcM);
    // flopr #(1) r23M(clk,rst,isInDelayslotE,isInDelayslotM);
    // flopr #(6) exceptionE2M(clk,rst,{checkExceptionE[7:3],ex_ovE},checkExceptionM[7:2]);
    // 更新hilo_reg前，确定HI、LO
    mux3 mux_HI2M(HIM,mdResult_hiM,srcaM,{regToHilo_hiM,mdToHiloM},HI2M);
    mux3 mux_LO2M(LOM,mdResult_loM,srcaM,{regToHilo_loM,mdToHiloM},LO2M);


	// [mem -> writeBack]
	// 暂存
	flopenrc r1W(clk,rst,~stallW,flushW,aluoutM,aluoutW);
	flopenrc r2W(clk,rst,~stallW,flushW,readdataM,readdataW);
	flopenrc #(5) r3W(clk,rst,~stallW,flushW,writeregM,writeregW);
    flopenrc r4W(clk,rst,~stallW,flushW,hilooutM,hilooutW);
	flopenrc #(4) r5W(clk,rst,~stallW,flushW,memReadWidthM,memReadWidthW);
	flopenrc #(1) r6W(clk,rst,~stallW,flushW,memLoadIsSignM,memLoadIsSignW);
    flopenrc r7W(clk,rst,~stallW,flushW,cp0_dataM,cp0_dataW);
	flopenrc r8W(clk,rst,~stallW,flushW,pcM,pcW);
	flopenr #(1) rstCompleteMessageM2W(clk,rst,~stallD,rstCompleteMessageM,rstCompleteMessageW);

	// flopr r1W(clk,rst,aluoutM,aluoutW);
	// flopr r2W(clk,rst,readdataM,readdataW);
	// flopr #(5) r3W(clk,rst,writeregM,writeregW);
    // flopr r4W(clk,rst,hilooutM,hilooutW);
	// flopr #(4) r5W(clk,rst,memReadWidthM,memReadWidthW);
	// flopr #(1) r6W(clk,rst,memLoadIsSignM,memLoadIsSignW);
    // flopr r7W(clk,rst,cp0_dataM,cp0_dataW);
	// flopr r8W(clk,rst,pcM,pcW);


	// =============================
	// 			hazard模块
	// =============================
	// 每次出现跳转周期时：
	// - 如果在M阶段的指令非lw/sw类，那么所有阶段跳转。一直等到i_stall结束，真的取到了pcF的对应instr，再在下个时钟沿更新阶段
	// - 如果在M阶段的指令为lw/sw类。那么所有阶段跳转。一直等到d_stall结束，完成了访存/写存操作。但现在不能更新阶段，因为还没有取新的pcF的对应instr。一个周期后触发i_stall，直到i_stall结束，我们才能说“好了，进入下一个阶段”
	// 而在情况2时，d_stall和i_stall的产生之间相隔了一个周期，为了不让阶段改变，这里有一个gap_stall，来填补空缺
	// 注：因为内外时钟取反，所以这里的i_stall和d_stall都是在下降沿改变
	always @(negedge clk) begin
		gap_stall <= d_stall;
	end


	hazard h(
        .d_stall(d_stall),
        .i_stall(i_stall),
		.gap_stall(gap_stall),
        .longest_stall(longest_stall),
		//fetch stage
		.stallF(stallF),
		.flushF(flushF),
		//decode stage
		.rsD(rsD),
		.rtD(rtD),
		.branchD(branchD),
		.jrD(jrD),
		.forwardaD(forwardaD),
		.forwardbD(forwardbD),
		.stallD(stallD),
		.jrstall_READ(jrstall_READ),
		.flushD(flushD),
		//execute stage
		.rsE(rsE),
		.rtE(rtE),
		.writeregE(writeregE),
		.regwriteE(regwriteE),
		.memtoregE(memtoregE),
        .hilotoregE(hilotoregE),
        .hilosrcE(hilosrcE),
        .stall_divE(stall_divE),
        .div_stall_extend(div_stall_extend),
        .cp0ToRegE(cp0ToRegE),
        .readcp0AddrE(readcp0AddrE),
		.div_readyE(div_readyE),
		.forwardaE(forwardaE),
		.forwardbE(forwardbE),
		.flushE(flushE),
        .forwardHIE(forwardHIE),
        .forwardLOE(forwardLOE),
        .stallE(stallE),
        .forwardCP0E(forwardCP0E),
		//mem stage
		.writeregM(writeregM),
		.regwriteM(regwriteM),
		.memtoregM(memtoregM),
        .hilowriteM(hilowriteM),
        .regToHilo_hiM(regToHilo_hiM),
        .regToHilo_loM(regToHilo_loM),
        .mdToHiloM(mdToHiloM),
        .isWritecp0M(isWritecp0M),
        .writecp0AddrM(writecp0AddrM),
        .except_typeM(except_typeM),
        .cp0_epcM(cp0_epcM),
        .hilotoregM(hilotoregM),
        .cp0ToRegM(cp0ToRegM),
        .newPCM(newPCM),
		.flushM(flushM),
        .stallM(stallM),
		//write back stage
		.writeregW(writeregW),
		.regwriteW(regwriteW),
		.flushW(flushW),
        .stallW(stallW)
	);


	// =============================================================
	// 以下代码全部为实验3内原功能的代码，区别在于增加了不同阶段的划分，以及更改
	// 了因阶段不同而改变的信号
	// =============================================================


	// ====================================
    // PC部分
    // PC -> PC+4 -> 判断branch
    //            -> 判断jump
    //            -> 更新PC
    // ====================================

	wire [31:0] pc_next_addr;

	// [Fetch] PC 模块
	flopenr_pc pcreg(clk,rst,~stallF,flushF,pc_next_addr,newPCM,rstCompleteMessageF,pcF);
    // [fetch] 标记取指令的地址是否对齐，不对齐产生例外
    assign checkExceptionF = (pcF[1:0]==2'b00) ? 8'd0 : 8'b1000_0000;
	// [Fetch] PC + 4
	adder adder_plus4(pcF,32'd4,pc_plus4F);

	// [Decode] 数据扩展
	signext DataExtend(opD, instrD[15:0], signimmD);
	// [Decode] 左移两位
	sl2 immsh(signimmD,signimm_slD);
	// [Decode] 计算branch的地址
	adder adder_branch(signimm_slD,pc_plus4D,pc_branch_offsetD);
	// [Decode] 判断是否执行branch
	//			为了（部分）解决控制冒险，提前判断branch
	mux2 mux_PCSrc(pc_plus4F,pc_branch_offsetD,pcsrcD,pc_afterbranchD);
	// [Decode] 【特殊情况】如果是BAL或者JAL的操作，pc+8的内容要写入31号寄存器，需要将pc+8传到后面的EXE阶段
	//					  如果是JALR的操作，pc+8的内容要写入rd号寄存器
	adder adder_plus8(pc_plus4D,32'd4,pc_plus8D);
	// [Decode] 判断是否执行jump
	mux2 mux_PCJump(
		pc_afterbranchD,
		{pc_plus4D[31:28],instrD[25:0],2'b00},
		jumpD,
		pc_afterjumpD
	);
	// [Decode] 【特殊情况】如果是JR或者JALR，那么无条件跳转的值为寄存器rs中的值
    //			 由于现在可能会出现例外情况，因此pc_next_addr的选择又多了一项例外返回地址
	//			 newPCM选项,且如若有例外出现，则newPCM优先
	wire [31:0] pc_jr;
	assign pc_jr = srca3D;

	wire pc_next_addr_en;
	// assign pc_next_addr_en = i_stall | (jumpD & d_stall) | (~d_stall & ~i_stall & jrD);
	// always@(posedge clk) begin
	// 	if(pc_next_addr_en) begin
	// 		pc_next_addr <= (checkExceptionM != 8'd0) ? newPCM :
	// 						(jrD) 					  ? pc_jr  :
	// 						pc_afterjumpD;
	// 	end
	// end
    assign pc_next_addr =
		// (pc_next_addr_en) ? (
			(checkExceptionM != 8'd0) ? newPCM :
			(jrD) 					  ? pc_jr  :
			pc_afterjumpD;
		// ) : pc_next_addr;
						// (checkExceptionM != 8'd0) 		 ? newPCM :
						// (~i_stall && ~(jumpD & d_stall)) ? pc_next_addr :
                        // (jrD)                     		 ? pc_jr  :
                        // pc_afterjumpD;
	// assign pc_next_addr = (jrD) ? pc_jr : pc_afterjumpD;


    // ====================================
    // Data部分
    // ====================================

	// [8个Exception]
	// 分别是：
	// 7. 取地址不对齐
	// 6. break指令
	// 5. syscall指令
	// 4. eret指令
	// 3. reserved指令
	// 2. overflow例外
	// 1. 地址错例外（读内存数据）
	// 0. 地址错例外（写内存数据）

	// [decode]
	// 检查解析命令会不会获得例外
    // 依次标记break、syacall、eret, reserved
	// assign checkExceptionD[6] = ex_bpD;
	// assign checkExceptionD[5] = ex_sysD;
    // assign checkExceptionD[4] =
	// assign checkExceptionD[3] = ex_riD;

	// [Execute]
	// 存储通过regdst得到的寄存器号，但有可能被BAL、JAL、JALR覆盖
	wire [4:0] writereg_tempE;
	wire is_al_instruction;
	// [Execute] 决定 write register 是 rt 还是 rd
	mux2 #(5) mux_regdst(rtE,rdE,regdstE,writereg_tempE);
	// [Execute] 【特殊情况】如果是BAL或者JAL的操作，那么会被强制写回31号寄存器
	//					   但如果是JALR的操作，那么不会覆盖，而是用rd写入
	assign is_al_instruction = (balE | jalE) & (~(jrE & jalE));
	mux2 #(5) mux_regdst_al(writereg_tempE, 5'd31, is_al_instruction, writeregE);
    // [Execute] 决定使用乘法结果-mulResult还是除法结果-divResult
    mux2 mux_mdresult_hi(divResult_hiE,mulResult_hiE,mulOrdivE,mdResult_hiE);
    mux2 mux_mdresult_lo(divResult_loE,mulResult_loE,mulOrdivE,mdResult_loE);


	wire [31:0] aluout_tempE; // 存储从ALU出来的结果，但有可能被BAL或JAL覆盖
    // [Execute] 针对寄存器堆，进行操作
	regfile register(clk,rst,regwriteW,rsD,rtD,writeregW,result_filterdW,srcaD,srcbD);
    // [Execute] 判断ALU收到的srcB是RD2还是SignImm
	mux2 mux_ALUsrc(srcb2E,signimmE,alusrcE,srcb3E);
    // [Execute] ALU运算
	// 			 注意可能产生overflow例外
	alu alu(srca2E,srcb3E,saE,alucontrolE,mdToHiloE,aluout_tempE,ex_ovE);
	// assign checkExceptionE[2] = ex_ovE;
	// [Execute] 【特殊情况】如果是BAL或者JAL的操作，pc+8的内容要写入31号寄存器，需要将pc+8作为aluout的结果
	//					   如果是JALR的操作，同样要写入pc+8
	mux2 mux_ALUout(aluout_tempE, pc_plus8E, (balE | jalE), aluoutE);
    // [Execute] 乘法运算
    mul mul(srca2E,srcb2E,mdIsSignE,mulResult_hiE,mulResult_loE);
    // [Execute] 除法运算
    // 			 除法完成需要36个周期，因此在除法完成前，如若没有强行中断除法运算的特殊情况发生，
	//			 流水线必须stall
    // 			 以下是一个简单的状态机，针对的是进行除法运算
    always @(negedge clk) begin
        div_stall_extend <= stall_divE;
    end
	reg stall_divE;
    always @(*)begin
		case({mdToHiloE,mulOrdivE})
			2'b10:begin
				if (except_typeM != 32'd0) begin start_divE = 1'b0; stall_divE = 1'b0; end
				else if(div_readyE == 1'b0) begin start_divE = 1'b1; stall_divE = 1'b1; end
				else if(div_readyE == 1'b1) begin start_divE = 1'b0; stall_divE = 1'b0; end
			end
			default: begin start_divE = 1'b0; stall_divE = 1'b0; end
		endcase
    end
    div div(clk,rst,mdIsSignE,srca2E,srcb3E,stallE,start_divE,flushE,{divResult_hiE,divResult_loE},div_readyE);

    // [Memory] 写hilo_reg
	// 若i指令有异常，i+1是div。当i达到M，i+1达到E，这时i+1在M发现了异常，设置了跳转。而除法开始做运算，进行了stall
	// 似乎根据trace更好的做法是检测到异常就压根不做下一条的除法
	// 但是这里用一个还算折中的实现，即如果是以上提到的情况，那么除法的结果不写回给HILO
	wire hilowrite_safeM;
	assign hilowrite_safeM = (pcF == 32'hBFC00380) ? 1'b0 : hilowriteM;
    hilo_reg hilo(clk,rst,hilowrite_safeM,HI2M,LO2M,HID,LOD);
    // [Memory] 决定 write rd是 HI,还是LO
    mux2 mux_rddst(LO2M,HI2M,hilosrcM,hilooutM);
    // [memory] 如果需要与内存读写数据，需要标记数据读写类型与读写地址是否正确
    // 			读数据
    assign checkExceptionM[1] = (memReadWidthM == `memReadWidth_WORD && aluoutM[1:0] != 2'b00) ? 1'b1 :
                                (memReadWidthM == `memReadWidth_HALF && (aluoutM[1:0] == 2'b11 || aluoutM[1:0] == 2'b01)) ? 1'b1 :
                                1'b0;
    // 			写数据
    assign checkExceptionM[0] = (memwriteM == `memWrite_WORD && aluoutM[1:0] != 2'b00) ? 1'b1 :
                                (memwriteM == `memWrite_HALF && (aluoutM[1:0] == 2'b11 || aluoutM[1:0] == 2'b01)) ? 1'b1 :
                                1'b0;
	// [Memory] 在向内存写入之前，需要将写入数据扩展成32位
	memwrite_extend memwrite_extend(writedataM, memwriteM, writedataExtendedM);
	// [Memory] 在向内存写入之前，如果是SW指令还需要进行写入地址的选择
	//			【提醒】如果存在例外0(ades)，那么写入地址是错误的，因此需要把写入给取消
	wire [3:0] memwrite_safeM;
	assign memwrite_safeM = (checkExceptionM[0] == 1'b1) ? 4'b0000 : memwriteM;
	memwrite_filter memwrite_filter(aluoutM,memwrite_safeM,memwrite_filterdM);


    // [Memory] 得到当前（优先级最高）的例外类型
	assign hasExceptionM = (checkExceptionM != 8'd0) ? 1'b1 : 1'b0;
    exception_type exception_type(rst,checkExceptionM,cp0_statusM,cp0_causeM,except_typeM);
    // [Memory] 决定 写入cp0的错误地址 是指令地址pcM 还是数据地址 aluoutM(注: 这里指令地址错误的优先级高于数据地址错误)
    mux2 mux_badAddr(aluoutM,pcM,checkExceptionM[7],badAddrM);
    // [Memory] 写cp0
    cp0_reg cp0(clk,rst,
	isWritecp0M,writecp0AddrM,readcp0AddrE,srcbM,
	6'b000000,
	except_typeM,pcM,isInDelayslotM,badAddrM,
	cp0_countE,cp0_dataE,cp0_compareE,cp0_statusE,cp0_causeE,cp0_epcE,cp0_configE,cp0_pridE,cp0_badvaddrE,cp0_timer_intE);

    // [WriteBack] 判断写回寄存器堆的是：从ALU出来的结果（可能被BAL、JAL或JALR覆盖） or 从数据存储器读取的data or HI/LO寄存器的数据 or CP0寄存器的数据
	// mux2 mux_regwriteData(aluoutW,readdataW,memtoregW,resultW);
    // mux3 mux_regwriteData(aluoutW,readdataW,hilooutW,{hilotoregW,memtoregW},resultW);
	mux4 mux_regwriteData(aluoutW,readdataW,hilooutW,cp0_dataW,{cp0ToRegW,hilotoregW,memtoregW},resultW);

	// [WriteBack] 对于从内存中读出的数据，如果是Load指令（尤其是LH,LB），需要进行数据选择以及扩展
	// 传出来的result_load_filterd即是LW/LH/lB最终的写回数据
	// 当然，如果不是LW/LH/LB指令，那么传出来的东西不变
	memload_filter #(32) memload_filter(aluoutW,resultW,memReadWidthW,memLoadIsSignW,result_filterdW);

endmodule
