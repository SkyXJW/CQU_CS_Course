module mycpu_top(
    input [5:0] ext_int,

    input aclk,
    input aresetn,

    output [3:0]    arid,
    output [31:0]   araddr,
    output [7:0]    arlen,
    output [2:0]    arsize,
    output [1:0]    arburst,
    output [1:0]    arlock,
    output [3:0]    arcache,
    output [2:0]    arprot,
    output          arvalid,
    input           arready,

    input [3:0]     rid,
    input [31:0]    rdata,
    input [1:0]     rresp,
    input           rlast,
    input           rvalid,
    output          rready,

    output [3:0]    awid,
    output [31:0]   awaddr,
    output [7:0]    awlen,
    output [2:0]    awsize,
    output [1:0]    awburst,
    output [1:0]    awlock,
    output [3:0]    awcache,
    output [2:0]    awprot,
    output          awvalid,
    input           awready,

    output [3:0]    wid,
    output [31:0]   wdata,
    output [3:0]    wstrb,
    output          wlast,
    output          wvalid,
    input           wready,

    input [3:0]     bid,
    input [1:0]     bresp,
    input           bvalid,
    output          bready,

    //debug
    output [31:0]   debug_wb_pc,
    output [3:0]    debug_wb_rf_wen,
    output [4:0]    debug_wb_rf_wnum,
    output [31:0]   debug_wb_rf_wdata
);

    //cpu inst sram
    wire        inst_sram_en   ;
    wire [3 :0] inst_sram_wen  ;
    wire [31:0] inst_sram_addr ;
    wire [31:0] inst_sram_wdata;
    wire [31:0] inst_sram_rdata;
    //cpu data sram
    wire        data_sram_en   ;
    wire [3 :0] data_sram_wen  ;
    wire [31:0] data_sram_addr ;
    wire [31:0] data_sram_wdata;
    wire [31:0] data_sram_rdata;

    wire clk, resetn;
    assign clk = aclk;
    assign resetn = aresetn;

	wire [31:0] inst_vaddr;
	wire [31:0] instr;
	wire [3:0] memwrite;
    wire [31:0] data_vaddr, writedata, readdata;

    // debug wires
    wire data_sram_enM;
    wire [31:0] pcW;
    wire regwriteW;
    wire [4:0] writeregW;
    wire [31:0] resultW;


    wire d_stall,i_stall,longest_stall;//TODO longest_stall则需要由mips输出
    wire gap_stall;
    wire div_stall_extend;
    wire div_ready;
    wire hasException;
    mips mips(
        // [inputs]
        .clk(~aclk),
        .rst(~aresetn),
        .instrF(instr),
        .readdataM(readdata),
        // [outputs]
        .pcF(inst_vaddr),
        .memwriteEN(memwrite),
        .aluoutM(data_vaddr),
        .writedataM(writedata),
        .d_stall(d_stall),
        .i_stall(i_stall),
        .longest_stall(longest_stall),
		.gap_stall(gap_stall),
        .div_stall_extend(div_stall_extend),
        .div_ready(div_ready),
        .hasException(hasException),
        //      debug
        .data_sram_enM(data_sram_enM),
        .pcW(pcW),
        .regwriteW(regwriteW),
        .writeregW(writeregW),
        .resultW(resultW),
        .rstCompleteMessageW(rstCompleteMessageW)
    );

    // 地址转换
    wire [31:0] inst_paddr;
    wire [31:0] data_paddr;
    wire no_cache;

    mmu mmu(inst_vaddr,inst_paddr,data_vaddr,data_paddr,no_cache);

    assign inst_sram_en = 1'b1;     //如果有inst_en，就用inst_en
    assign inst_sram_wen = 4'b0;
    assign inst_sram_addr = inst_paddr;
    assign inst_sram_wdata = 32'b0;
    assign instr = inst_sram_rdata;

    assign data_sram_en = data_sram_enM;     //如果有data_en，就用data_en
    // 读入时，就算是只读半字，也需要读入整个word（即memwrite的四位都为0），然后再根据类型选择要读的有哪些部分
    // TODO: 在axi总线中不再是这样的了
    assign data_sram_wen = memwrite;
    assign data_sram_addr = data_paddr;
    assign data_sram_wdata = writedata;
    assign readdata = data_sram_rdata;

    assign debug_wb_pc = pcW;
    // reg debug_wb_rf_wen;


    reg rstCompleteMessageW_Reverse;
    wire rstCompleteMessage_Filtered;
    always @(negedge aclk) begin
        rstCompleteMessageW_Reverse <= rstCompleteMessageW;
    end
    assign rstCompleteMessage_Filtered = rstCompleteMessageW ^ rstCompleteMessageW_Reverse;
    // always @(negedge aclk) begin
    //     if(rstCompleteMessage_Filtered)
    //         debug_wb_rf_wen <= 4'b1111;
    //     else if((i_stall | d_stall | div_stall | gap_stall) & !hasException)
    //         debug_wb_rf_wen <= 4'd0;
    //     else
    //         debug_wb_rf_wen <= {4{regwriteW}};
    // end
    wire [3:0] wen = (i_stall | div_stall_extend | gap_stall) ? 4'b0000 : {4{regwriteW}};
    reg [3:0] wen_extend_half;
    always @(clk) begin
        wen_extend_half <= wen;
    end
    assign debug_wb_rf_wen = wen_extend_half | rstCompleteMessage_Filtered;
    assign debug_wb_rf_wnum = writeregW;
    assign debug_wb_rf_wdata = resultW;

    // like sram
    // 取指令的类sram接口
    wire ram_inst_req, ram_inst_wr;
    wire [1:0] ram_inst_size;
    wire [31:0] ram_inst_addr;
    wire [31:0] ram_inst_wdata;
    wire [31:0] ram_inst_rdata;
    wire ram_inst_addr_ok, ram_inst_data_ok;
    i_sram2sramlike i_sram2sramlike(
        .clk(aclk), .rst(~aresetn),
        .inst_sram_en(inst_sram_en),
        .inst_sram_addr(inst_sram_addr),
        .inst_sram_rdata(inst_sram_rdata),
        .inst_sram_wen(inst_sram_wen),
        .inst_sram_wdata(inst_sram_wdata),
        .i_stall(i_stall),
        .longest_stall(longest_stall),

        .inst_req     (ram_inst_req  ),
        .inst_wr      (ram_inst_wr   ),
        .inst_addr    (ram_inst_addr ),
        .inst_wdata   (ram_inst_wdata),
        .inst_size    (ram_inst_size ),
        .inst_rdata   (ram_inst_rdata),
        .inst_addr_ok (ram_inst_addr_ok),
        .inst_data_ok (ram_inst_data_ok)
    );

    // 数据访存的类sram接口
    wire ram_data_req, ram_data_wr;
    wire [1:0] ram_data_size;
    wire [31:0] ram_data_addr;
    wire [31:0] ram_data_wdata;
    wire [31:0] ram_data_rdata;
    wire ram_data_addr_ok, ram_data_data_ok;
    d_sram2sramlike d_sram2sramlike(
        .clk(aclk), .rst(~aresetn),
        .data_sram_en(data_sram_en),
        .data_sram_addr(data_sram_addr),
        .data_sram_rdata(data_sram_rdata),
        .data_sram_wen(data_sram_wen),
        .data_sram_wdata(data_sram_wdata),
        .d_stall(d_stall),
        .longest_stall(longest_stall),

        .data_req     (ram_data_req  ),
        .data_wr      (ram_data_wr   ),
        .data_addr    (ram_data_addr ),
        .data_wdata   (ram_data_wdata),
        .data_size    (ram_data_size ),
        .data_rdata   (ram_data_rdata),
        .data_addr_ok (ram_data_addr_ok),
        .data_data_ok (ram_data_data_ok),
        .gap_stall(gap_stall)
    );
    // ascii
    instdec instdec(
        .instr(instr)
    );

    // cache 与 cpu_axi_interface之间的“线”
    wire cache_inst_req,cache_inst_wr;
    wire [1:0] cache_inst_size;
    wire [31:0] cache_inst_addr,cache_inst_wdata,cache_inst_rdata;
    wire cache_inst_addr_ok,cache_inst_data_ok;
    wire cache_data_req,cache_data_wr;
    wire [1:0] cache_data_size;
    wire [31:0] cache_data_addr,cache_data_wdata,cache_data_rdata;
    wire cache_data_addr_ok,cache_data_data_ok;
    // 目前什么也不做，只是DUMMY的cache
    cache dummyCache(
        .clk(aclk), .rst(aresetn),.no_cache(no_cache),
        .cpu_inst_req     (ram_inst_req  ),
        .cpu_inst_wr      (ram_inst_wr   ),
        .cpu_inst_addr    (ram_inst_addr ),
        .cpu_inst_size    (ram_inst_size ),
        .cpu_inst_wdata   (ram_inst_wdata),
        .cpu_inst_rdata   (ram_inst_rdata),
        .cpu_inst_addr_ok (ram_inst_addr_ok),
        .cpu_inst_data_ok (ram_inst_data_ok),

        .cpu_data_req     (ram_data_req  ),
        .cpu_data_wr      (ram_data_wr   ),
        .cpu_data_addr    (ram_data_addr ),
        .cpu_data_wdata   (ram_data_wdata),
        .cpu_data_size    (ram_data_size ),
        .cpu_data_rdata   (ram_data_rdata),
        .cpu_data_addr_ok (ram_data_addr_ok),
        .cpu_data_data_ok (ram_data_data_ok),

        .cache_inst_req     (cache_inst_req  ),
        .cache_inst_wr      (cache_inst_wr   ),
        .cache_inst_addr    (cache_inst_addr ),
        .cache_inst_size    (cache_inst_size ),
        .cache_inst_wdata   (cache_inst_wdata),
        .cache_inst_rdata   (cache_inst_rdata),
        .cache_inst_addr_ok (cache_inst_addr_ok),
        .cache_inst_data_ok (cache_inst_data_ok),

        .cache_data_req     (cache_data_req  ),
        .cache_data_wr      (cache_data_wr   ),
        .cache_data_addr    (cache_data_addr ),
        .cache_data_wdata   (cache_data_wdata),
        .cache_data_size    (cache_data_size ),
        .cache_data_rdata   (cache_data_rdata),
        .cache_data_addr_ok (cache_data_addr_ok),
        .cache_data_data_ok (cache_data_data_ok)
    );


    cpu_axi_interface cpu_axi_interface(
        .clk(aclk),      .resetn(aresetn),

        .inst_req       (cache_inst_req  ),
        .inst_wr        (cache_inst_wr   ),
        .inst_size      (cache_inst_size ),
        .inst_addr      (cache_inst_addr ),
        .inst_wdata     (cache_inst_wdata),
        .inst_rdata     (cache_inst_rdata),
        .inst_addr_ok   (cache_inst_addr_ok),
        .inst_data_ok   (cache_inst_data_ok),

        .data_req       (cache_data_req  ),
        .data_wr        (cache_data_wr   ),
        .data_size      (cache_data_size ),
        .data_addr      (cache_data_addr ),
        .data_wdata     (cache_data_wdata ),
        .data_rdata     (cache_data_rdata),
        .data_addr_ok   (cache_data_addr_ok),
        .data_data_ok   (cache_data_data_ok),

        .arid(arid),
        .araddr(araddr),
        .arlen(arlen),
        .arsize(arsize),
        .arburst(arburst),
        .arlock(arlock),
        .arcache(arcache),
        .arprot(arprot),
        .arvalid(arvalid),
        .arready(arready),

        .rid(rid),
        .rdata(rdata),
        .rresp(rresp),
        .rlast(rlast),
        .rvalid(rvalid),
        .rready(rready),

        .awid(awid),
        .awaddr(awaddr),
        .awlen(awlen),
        .awsize(awsize),
        .awburst(awburst),
        .awlock(awlock),
        .awcache(awcache),
        .awprot(awprot),
        .awvalid(awvalid),
        .awready(awready),

        .wid(wid),
        .wdata(wdata),
        .wstrb(wstrb),
        .wlast(wlast),
        .wvalid(wvalid),
        .wready(wready),

        .bid(bid),
        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready)
    );

endmodule