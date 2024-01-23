`timescale 1ns / 1ps


module controller(
	input clk,rst,

	//decode stage
	input [4:0] rsD,rtD,rdD,
	input [5:0] opD,functD,
	input validBranchConditionD,
	output pcsrcD,branchD,jumpD,jalD,jrD,
	output ex_bpD, ex_sysD, ex_riD,

	//execute stage
	input flushE,stallE,
	output memtoregE,alusrcE,
	output balE,jalE,jrE,
	output regdstE,regwriteE,
	output [4:0] alucontrolE,
    output regToHilo_hiE,regToHilo_loE,
    output mdToHiloE,
    output mulOrdivE,
    output hilotoregE,
    output hilosrcE,
    output mdIsSignE,
	output [3:0] memwriteE,
    output isWritecp0E,
    output [4:0] writecp0AddrE,readcp0AddrE,
    output cp0ToRegE,
    output branchE,jumpE,jalrE,


	//mem stage
	input flushM,stallM,
	output memtoregM,regwriteM,hilowriteM,regToHilo_hiM,regToHilo_loM,mdToHiloM,hilotoregM,hilosrcM,isWritecp0M,cp0ToRegM,branchM,jumpM,jalM,jrM,jalrM,
	output [3:0] memReadWidthM,
	output memLoadIsSignM,
    output [4:0] writecp0AddrM,
	output data_sram_enM,

	//write back stage
	input flushW,stallW,
	output memtoregW,regwriteW,hilotoregW,cp0ToRegW
);

	//decode stage
	wire [3:0] memwriteD, memReadWidthD;
	wire memLoadIsSignD;
	wire memtoregD,alusrcD,regdstD,regwriteD;
	wire regToHilo_hiD,regToHilo_loD,mdToHiloD,mulOrdivD,hilowriteD,hilotoregD,hilosrcD,mdIsSignD,isWritecp0D,cp0ToRegD,jalrD;
	wire balD;
	wire[4:0] alucontrolD,writecp0AddrD,readcp0AddrD;
	wire data_sram_enD;

	//execute stage
	wire [3:0] memReadWidthE;
	wire memLoadIsSignE;
	wire hilowriteE;
	wire data_sram_enE;

	// 用不到的，就继续传

	// [decode -> execute]
	assign pcsrcD = branchD & validBranchConditionD;
	// 注意，这里存在flush可能性
	flopenrc #(45) regE(
		clk, rst,
        ~stallE,
		flushE,
		{memtoregD,memwriteD,memReadWidthD,// 9 bit
		alusrcD,regdstD,regwriteD,alucontrolD,// 17bit
		balD,jalD,jrD,regToHilo_hiD,regToHilo_loD,mdToHiloD,//23bit
		mulOrdivD,hilowriteD,hilotoregD,hilosrcD,mdIsSignD,memLoadIsSignD,isWritecp0D,writecp0AddrD,readcp0AddrD,cp0ToRegD,jalrD,branchD,jumpD,data_sram_enD},//44bit

		{memtoregE,memwriteE,memReadWidthE,
		alusrcE,regdstE,regwriteE,alucontrolE,
		balE,jalE,jrE,regToHilo_hiE,regToHilo_loE,mdToHiloE,
		mulOrdivE,hilowriteE,hilotoregE,hilosrcE,mdIsSignE,memLoadIsSignE,isWritecp0E,writecp0AddrE,readcp0AddrE,cp0ToRegE,jalrE,branchE,jumpE,data_sram_enE}
	);

	// [execute -> mem]
	flopenrc #(26) regM(
		clk,rst,~stallM,flushM,
		{memtoregE,memReadWidthE,//5bit
		regwriteE,regToHilo_hiE,regToHilo_loE,mdToHiloE,hilowriteE,hilotoregE,//11bit
		hilosrcE,memLoadIsSignE,isWritecp0E,writecp0AddrE,cp0ToRegE,branchE,jumpE,jalE,jrE,jalrE,data_sram_enE},//26bit

		{memtoregM,memReadWidthM,
		regwriteM,regToHilo_hiM,regToHilo_loM,mdToHiloM,hilowriteM,hilotoregM,
		hilosrcM,memLoadIsSignM,isWritecp0M,writecp0AddrM,cp0ToRegM,branchM,jumpM,jalM,jrM,jalrM,data_sram_enM}
	);

	// [mem -> writeBack]
	flopenrc #(4) regW(
		clk,rst,~stallW,flushW,
		{memtoregM,regwriteM,hilotoregM,cp0ToRegM},
		{memtoregW,regwriteW,hilotoregW,cp0ToRegW}
	);

	// =============================================================
	// 以下代码全部为实验3内原功能的代码，区别在于增加了不同阶段的划分
	// =============================================================


	maindec control_maindec(
		.op(opD),
		.rs(rsD),
		.rt(rtD),
		.rd(rdD),
        .funct(functD),
		//input
        .regwrite(regwriteD),
        .regdst(regdstD),
        .alusrc(alusrcD),
        .branch(branchD),
		.bal(balD),
		.jal(jalD),
		.jr(jrD),
        .memWrite(memwriteD),
		.memReadWidth(memReadWidthD),
		.memLoadIsSign(memLoadIsSignD),
        .memToReg(memtoregD),
        .jump(jumpD),
        .hilowrite(hilowriteD),
        .regToHilo_hi(regToHilo_hiD),
        .regToHilo_lo(regToHilo_loD),
        .mdToHilo(mdToHiloD),
        .mulOrdiv(mulOrdivD),
        .hiloToReg(hilotoregD),
        .hilosrc(hilosrcD),
        .mdIsSign(mdIsSignD),
        .isWritecp0(isWritecp0D),
        .writecp0Addr(writecp0AddrD),
        .readcp0Addr(readcp0AddrD),
        .cp0ToReg(cp0ToRegD),
        .ex_ri(ex_riD),
		.ex_bp(ex_bpD),
		.ex_sys(ex_sysD),
        .jalr(jalrD),
		.data_sram_en(data_sram_enD)
        //output
	);

	aludec control_aludec(
		.op(opD),
        .funct(functD),
        //input
        .aluctrl(alucontrolD)
        //output
    );


endmodule
