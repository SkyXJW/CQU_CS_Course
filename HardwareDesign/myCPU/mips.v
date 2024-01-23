`timescale 1ns / 1ps

module mips(
	input clk,rst,
	input [31:0] instrF,
	input [31:0] readdataM,
	output [31:0] pcF,
	output [3:0] memwriteEN,
	output [31:0] aluoutM,writedataM,
    input d_stall,i_stall,
    output longest_stall,
	output gap_stall,
	output div_stall_extend,
	output div_ready,
	output hasException,
	output rstCompleteMessageW,
	//debug
	output data_sram_enM,
    output [31:0] pcW,
    output regwriteW,
    output [4:0] writeregW,
    output [31:0] resultW
);

	wire [5:0] opD,functD;
	wire [4:0] rsD,rtD,rdD;
	wire regdstE,alusrcE,branchD,jalD,jrD,pcsrcD,memtoregE,memtoregM,memtoregW;
	wire balE,jalE,jrE,regwriteE,regwriteM;
	wire jumpD;
	wire [4:0] alucontrolE;
	wire flushE,flushM,flushW,validBranchConditionD;
    wire regToHilo_hiE,regToHilo_loE,mdToHiloE,mulOrdivE,mdIsSignE;
    wire regToHilo_hiM,regToHilo_loM,mdToHiloM;
    wire hilotoregE;
    wire hilotoregM,hilotoregW;
	wire hilowriteM,hilosrcM;
    wire hilosrcE;
    wire isWritecp0E,isWritecp0M;
	wire [3:0] memwriteE;
    wire [4:0] writecp0AddrE,writecp0AddrM,readcp0AddrE;
	wire [3:0] memReadWidthM;
	wire memLoadIsSignM;
    wire cp0ToRegE,cp0ToRegM,cp0ToRegW;
    wire branchE,branchM,jumpE,jumpM,jalM,jrM,jalrE,jalrM;
	wire ex_bpD, ex_sysD, ex_riD;
    wire stallE,stallM,stallW;

	controller c(
		.clk(clk), .rst(rst),
		//[fetch stage]
		//				==input==
		//				==output=
		//[decode stage]
		//				==input==
		.opD(opD), 					.rsD(rsD),
		.rtD(rtD), 					.rdD(rdD),
		.functD(functD),
		.validBranchConditionD(validBranchConditionD),
		//				==output=
		.pcsrcD(pcsrcD),			.branchD(branchD),
		.jumpD(jumpD),				.jalD(jalD),
		.jrD(jrD),                  .ex_riD(ex_riD),
		.ex_bpD(ex_bpD),			.ex_sysD(ex_sysD),
		//[execute stage]
		//				==input==
		.flushE(flushE),            .stallE(stallE),
			//output
		.memtoregE(memtoregE), 		.alusrcE(alusrcE),
		.regdstE(regdstE), 			.regwriteE(regwriteE),
		.alucontrolE(alucontrolE), 	.balE(balE),
		.jalE(jalE),				.jrE(jrE),
        .regToHilo_hiE(regToHilo_hiE),
        .regToHilo_loE(regToHilo_loE),
        .mdToHiloE(mdToHiloE),      .mulOrdivE(mulOrdivE),
        .hilotoregE(hilotoregE),
        .hilosrcE(hilosrcE),
        .mdIsSignE(mdIsSignE),
        .isWritecp0E(isWritecp0E),  .writecp0AddrE(writecp0AddrE),
        .readcp0AddrE(readcp0AddrE),.cp0ToRegE(cp0ToRegE),
        .branchE(branchE),          .jumpE(jumpE),
        .jalrE(jalrE),
		//[mem stage]
		//				==input==
		.flushM(flushM),            .stallM(stallM),
		//				==output=
		.memtoregM(memtoregM),		.memwriteE(memwriteE),
        .regToHilo_hiM(regToHilo_hiM),
        .regToHilo_loM(regToHilo_loM),
        .mdToHiloM(mdToHiloM),
		.regwriteM(regwriteM),
        .hilotoregM(hilotoregM),    .hilowriteM(hilowriteM),
        .hilosrcM(hilosrcM), 		.memReadWidthM(memReadWidthM),
		.memLoadIsSignM(memLoadIsSignM),
        .isWritecp0M(isWritecp0M),  .writecp0AddrM(writecp0AddrM),
        .cp0ToRegM(cp0ToRegM),      .branchM(branchM),
        .jumpM(jumpM),              .jalM(jalM),
        .jrM(jrM),                  .jalrM(jalrM),
		.data_sram_enM(data_sram_enM),
		//[writeBack stage]
		//				==input==
		.flushW(flushW),            .stallW(stallW),
		//				==output=
		.memtoregW(memtoregW),		.regwriteW(regwriteW),
        .hilotoregW(hilotoregW),    .cp0ToRegW(cp0ToRegW)
	);

	datapath dp(
		.clk(clk),	.rst(rst),
        .d_stall(d_stall), .longest_stall(longest_stall),
        .i_stall(i_stall),
		.gap_stall(gap_stall),
		//[fetch stage]
		//				==input==
		.instrF(instrF),
		//				==output=
		.pcF(pcF),
		//[decode stage]
		//				==input==
		.pcsrcD(pcsrcD),			.branchD(branchD),
		.jumpD(jumpD),				.jalD(jalD),
		.jrD(jrD),					.ex_riD(ex_riD),
		.ex_bpD(ex_bpD),			.ex_sysD(ex_sysD),
		//				==output=
		.validBranchConditionD(validBranchConditionD), 			.opD(opD),
		.rsD(rsD),				.rtD(rtD),
		.rdD(rdD),				.functD(functD),
		//[execute stage]
		//				==input==
		.memtoregE(memtoregE),		.alusrcE(alusrcE),
		.regdstE(regdstE), 			.regwriteE(regwriteE),
		.alucontrolE(alucontrolE), 	.balE(balE),
		.jalE(jalE),                .jrE(jrE),
        .hilotoregE(hilotoregE),
        .hilosrcE(hilosrcE),
        .mulOrdivE(mulOrdivE),
        .mdIsSignE(mdIsSignE),          .mdToHiloE(mdToHiloE),
		.memwriteE(memwriteE),
        .isWritecp0E(isWritecp0E),  .writecp0AddrE(writecp0AddrE),
        .readcp0AddrE(readcp0AddrE),.cp0ToRegE(cp0ToRegE),
        .branchE(branchE),          .jumpE(jumpE),
        .jalrE(jalrE),

		//				==output=
		.flushE(flushE),            .stallE(stallE),
		.div_stall_extend(div_stall_extend),		.div_readyE(div_ready),
		//[mem stage]
		//				==input==
		.memtoregM(memtoregM), 		.regwriteM(regwriteM),
		.readdataM(readdataM),
        .hilowriteM(hilowriteM),
        .hilotoregM(hilotoregM),    .hilosrcM(hilosrcM),
        .regToHilo_hiM(regToHilo_hiM),
        .regToHilo_loM(regToHilo_loM),
        .mdToHiloM(mdToHiloM),		.memReadWidthM(memReadWidthM),
		.memLoadIsSignM(memLoadIsSignM),
        .isWritecp0M(isWritecp0M),  .writecp0AddrM(writecp0AddrM),
        .cp0ToRegM(cp0ToRegM),      .branchM(branchM),
        .jumpM(jumpM),              .jalM(jalM),
        .jrM(jrM),                  .jalrM(jalrM),
		//				==output=
		.aluoutM(aluoutM),			.writedataExtendedM(writedataM),
		.memwrite_filterdM(memwriteEN),
		.flushM(flushM),            .stallM(stallM),
		.hasExceptionM(hasException),
		//[writeBack stage]
		//				==input==
		.memtoregW(memtoregW), 		.regwriteW(regwriteW),
        .hilotoregW(hilotoregW),    .cp0ToRegW(cp0ToRegW),
		//				==output=
		.pcW(pcW),                  .writeregW(writeregW),
        .result_filterdW(resultW),
		.flushW(flushW),            .stallW(stallW),
		.rstCompleteMessageW(rstCompleteMessageW)
	);

endmodule
