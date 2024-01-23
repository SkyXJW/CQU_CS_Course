module cache (
    input wire clk, rst,no_cache,
    // [mips core]
    input         cpu_inst_req     ,
    input         cpu_inst_wr      ,
    input  [1 :0] cpu_inst_size    ,
    input  [31:0] cpu_inst_addr    ,
    input  [31:0] cpu_inst_wdata   ,
    output [31:0] cpu_inst_rdata   ,
    output        cpu_inst_addr_ok ,
    output        cpu_inst_data_ok ,

    input         cpu_data_req     ,
    input         cpu_data_wr      ,
    input  [1 :0] cpu_data_size    ,
    input  [31:0] cpu_data_addr    ,
    input  [31:0] cpu_data_wdata   ,
    output [31:0] cpu_data_rdata   ,
    output        cpu_data_addr_ok ,
    output        cpu_data_data_ok ,

    // [axi interface]
    output         cache_inst_req     ,
    output         cache_inst_wr      ,
    output  [1 :0] cache_inst_size    ,
    output  [31:0] cache_inst_addr    ,
    output  [31:0] cache_inst_wdata   ,
    input   [31:0] cache_inst_rdata   ,
    input          cache_inst_addr_ok ,
    input          cache_inst_data_ok ,

    output         cache_data_req     ,
    output         cache_data_wr      ,
    output  [1 :0] cache_data_size    ,
    output  [31:0] cache_data_addr    ,
    output  [31:0] cache_data_wdata   ,
    input   [31:0] cache_data_rdata   ,
    input          cache_data_addr_ok ,
    input          cache_data_data_ok
);

    // 接受mips的，传给axi interface
    // assign cache_inst_req = cpu_inst_req;
    // assign cache_inst_wr = cpu_inst_wr;
    // assign cache_inst_size = cpu_inst_size;
    // assign cache_inst_addr = cpu_inst_addr;
    // assign cache_inst_wdata = cpu_inst_wdata;
    wire [31:0] d_cpu_data_rdata;
    wire  d_cpu_data_addr_ok,d_cpu_data_data_ok;
    wire d_cache_data_req,d_cache_data_wr;
    wire [1:0] d_cache_data_size;
    wire [31:0] d_cache_data_addr,d_cache_data_wdata;

    assign cache_data_req = (no_cache) ? cpu_data_req : d_cache_data_req;
    assign cache_data_wr = (no_cache) ? cpu_data_wr : d_cache_data_wr;
    assign cache_data_size = (no_cache) ? cpu_data_size : d_cache_data_size;
    assign cache_data_addr = (no_cache) ? cpu_data_addr : d_cache_data_addr;
    assign cache_data_wdata = (no_cache) ? cpu_data_wdata : d_cache_data_wdata;

    // assign cache_data_req = cpu_data_req;
    // assign cache_data_wr = cpu_data_wr;
    // assign cache_data_size = cpu_data_size;
    // assign cache_data_addr = cpu_data_addr;
    // assign cache_data_wdata = cpu_data_wdata;


    // 接受axi interface的，传给mips
    // assign cpu_inst_rdata = cache_inst_rdata;
    // assign cpu_inst_addr_ok = cache_inst_addr_ok;
    // assign cpu_inst_data_ok = cache_inst_data_ok;

    assign cpu_data_rdata = (no_cache) ? cache_data_rdata : d_cpu_data_rdata;
    assign cpu_data_addr_ok = (no_cache) ? cache_data_addr_ok : d_cpu_data_addr_ok;
    assign cpu_data_data_ok = (no_cache) ? cache_data_data_ok : d_cpu_data_data_ok;

    // assign cpu_data_rdata = cache_data_rdata;
    // assign cpu_data_addr_ok = cache_data_addr_ok;
    // assign cpu_data_data_ok = cache_data_data_ok;

    i_cache i_cache(
        .clk(clk), .rst(~rst),
        .cpu_inst_req     (cpu_inst_req     ),
        .cpu_inst_wr      (cpu_inst_wr      ),
        .cpu_inst_size    (cpu_inst_size    ),
        .cpu_inst_addr    (cpu_inst_addr    ),
        .cpu_inst_wdata   (cpu_inst_wdata   ),
        .cpu_inst_rdata   (cpu_inst_rdata   ),
        .cpu_inst_addr_ok (cpu_inst_addr_ok ),
        .cpu_inst_data_ok (cpu_inst_data_ok ),

        .cache_inst_req     (cache_inst_req     ),
        .cache_inst_wr      (cache_inst_wr      ),
        .cache_inst_size    (cache_inst_size    ),
        .cache_inst_addr    (cache_inst_addr    ),
        .cache_inst_wdata   (cache_inst_wdata   ),
        .cache_inst_rdata   (cache_inst_rdata   ),
        .cache_inst_addr_ok (cache_inst_addr_ok ),
        .cache_inst_data_ok (cache_inst_data_ok )
    );

    d_cache_wb d_cache(
        .clk(clk), .rst(~rst),
        .cpu_data_req     (cpu_data_req & ~no_cache),
        .cpu_data_wr      (cpu_data_wr      ),
        .cpu_data_size    (cpu_data_size    ),
        .cpu_data_addr    (cpu_data_addr    ),
        .cpu_data_wdata   (cpu_data_wdata   ),
        .cpu_data_rdata   (d_cpu_data_rdata   ),
        .cpu_data_addr_ok (d_cpu_data_addr_ok ),
        .cpu_data_data_ok (d_cpu_data_data_ok ),

        .cache_data_req     (d_cache_data_req     ),
        .cache_data_wr      (d_cache_data_wr      ),
        .cache_data_size    (d_cache_data_size    ),
        .cache_data_addr    (d_cache_data_addr    ),
        .cache_data_wdata   (d_cache_data_wdata   ),
        .cache_data_rdata   (cache_data_rdata   ),
        .cache_data_addr_ok (cache_data_addr_ok ),
        .cache_data_data_ok (cache_data_data_ok )
    );
endmodule