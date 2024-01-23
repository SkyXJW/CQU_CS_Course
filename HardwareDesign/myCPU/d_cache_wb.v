module d_cache_wb (
    input wire clk, rst,
    //mips core
    input         cpu_data_req     ,
    input         cpu_data_wr      ,
    input  [1 :0] cpu_data_size    ,
    input  [31:0] cpu_data_addr    ,
    input  [31:0] cpu_data_wdata   ,
    output [31:0] cpu_data_rdata   ,
    output        cpu_data_addr_ok ,
    output        cpu_data_data_ok ,

    //axi interface
    output         cache_data_req     ,
    output         cache_data_wr      ,
    output  [1 :0] cache_data_size    ,
    output  [31:0] cache_data_addr    ,
    output  [31:0] cache_data_wdata   ,
    input   [31:0] cache_data_rdata   ,
    input          cache_data_addr_ok ,
    input          cache_data_data_ok 
);
    //Cache配置
    parameter  INDEX_WIDTH  = 10, OFFSET_WIDTH = 2;
    localparam TAG_WIDTH    = 32 - INDEX_WIDTH - OFFSET_WIDTH;
    localparam CACHE_DEEPTH = 1 << INDEX_WIDTH;
    
    //Cache存储单元
    reg                 cache_valid [CACHE_DEEPTH - 1 : 0];
    reg [TAG_WIDTH-1:0] cache_tag   [CACHE_DEEPTH - 1 : 0];
    reg [31:0]          cache_block [CACHE_DEEPTH - 1 : 0];
    reg                 cache_dirty [CACHE_DEEPTH - 1 : 0];//在写直达基础上增添脏位记录

    //访问地址分解
    wire [OFFSET_WIDTH-1:0] offset;
    wire [INDEX_WIDTH-1:0] index;
    wire [TAG_WIDTH-1:0] tag;
    
    assign offset = cpu_data_addr[OFFSET_WIDTH - 1 : 0];
    assign index = cpu_data_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign tag = cpu_data_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];

    //访问Cache line
    wire c_valid;
    wire [TAG_WIDTH-1:0] c_tag;
    wire [31:0] c_block;
    wire c_dirty;

    assign c_valid = cache_valid[index];
    assign c_tag   = cache_tag  [index];
    assign c_block = cache_block[index];
    assign c_dirty = cache_dirty[index];

    //判断是否命中
    wire hit, miss;
    assign hit = c_valid & (c_tag == tag);  //cache line的valid位为1，且tag与地址中tag相等
    assign miss = ~hit;

    //读或写
    wire read, write;
    assign write = cpu_data_wr;
    assign read = ~write;

    //根据写回+写分配策略设计FSM
    parameter IDLE = 2'b00, RM = 2'b01, WM = 2'b11;
    reg [1:0] state;
    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE:   state <= cpu_data_req & read & miss & c_dirty? WM :
                                 cpu_data_req & read & miss & ~c_dirty? RM :
                                 cpu_data_req & write & miss & c_dirty? WM :
                                 cpu_data_req & write & miss & ~c_dirty? RM : IDLE;
                RM:     state <= cache_data_data_ok ? IDLE : RM;
                WM:     state <= cache_data_data_ok ? RM : WM;
            endcase
        end
    end

    //读内存
    //变量read_req, addr_rcv, read_finish用于构造类sram信号。
    wire read_req;      //一次完整的读事务，从发出读请求到结束
    reg addr_rcv;       //地址接收成功(addr_ok)后到结束
    wire read_finish;   //数据接收成功(data_ok)，即读请求结束
    always @(posedge clk) begin
        addr_rcv <= rst ? 1'b0 :
                    read_req & cache_data_req & cache_data_addr_ok ? 1'b1 :
                    read_finish ? 1'b0 : addr_rcv;
    end
    assign read_req = state==RM;
    assign read_finish = read_req & cache_data_data_ok;

    //写内存
    wire write_req;     
    reg waddr_rcv;      
    wire write_finish;   
    always @(posedge clk) begin
        waddr_rcv <= rst ? 1'b0 :
                     write_req & cache_data_req & cache_data_addr_ok ? 1'b1 :
                     write_finish ? 1'b0 : waddr_rcv;
    end
    assign write_req = state==WM;
    assign write_finish = write_req & cache_data_data_ok;

    //output to mips core
    assign cpu_data_rdata   = hit ? c_block : cache_data_rdata;
    //在写回策略下，如果请求的访问命中，则cache直接返回数据/写数据；
    //如果请求的访问缺失，则无论该块是否为脏块，都需要等到cache从内存中读出数据后，才能利用cpu发出的数据访问地址在cache中对数据进行读写操作
    assign cpu_data_addr_ok = cpu_data_req & hit | cache_data_req & read_req &cache_data_addr_ok;
    assign cpu_data_data_ok = cpu_data_req & hit | read_req & cache_data_data_ok;

    //output to axi interface
    assign cache_data_req   = read_req & ~addr_rcv | write_req & ~waddr_rcv;
    assign cache_data_wr    = write_req;
    assign cache_data_size  = cpu_data_size;
    //在写回策略下，如果需要写内存，则写回的地址一定是cache line中的地址，如果是需要读内存，则是直接通过cpu的请求数据地址来读取内存
    assign cache_data_addr  = cache_data_wr ? {c_tag, index, offset} : cpu_data_addr;
    //在写回策略下，仅当访问缺失且“脏块”时，才需要写回内存，因此写回内存的数据一定是cache line中的数据
    assign cache_data_wdata = c_block;

    //写入Cache
    //保存地址中的tag, index，防止addr发生改变
    reg [TAG_WIDTH-1:0] tag_save;
    reg [INDEX_WIDTH-1:0] index_save;
    always @(posedge clk) begin
        tag_save   <= rst ? 0 :
                      cpu_data_req ? tag : tag_save;
        index_save <= rst ? 0 :
                      cpu_data_req ? index : index_save;
    end

    wire [31:0] write_cache_data;
    wire [3:0] write_mask;

    //根据地址低两位和size，生成写掩码（针对sb，sh等不是写完整一个字的指令），4位对应1个字（4字节）中每个字的写使能
    assign write_mask = cpu_data_size==2'b00 ?
                            (cpu_data_addr[1] ? (cpu_data_addr[0] ? 4'b1000 : 4'b0100):
                                                (cpu_data_addr[0] ? 4'b0010 : 4'b0001)) :
                            (cpu_data_size==2'b01 ? (cpu_data_addr[1] ? 4'b1100 : 4'b0011) : 4'b1111);

    //掩码的使用：位为1的代表需要更新的。
    //位拓展：{8{1'b1}} -> 8'b11111111
    //new_data = old_data & ~mask | write_data & mask
    assign write_cache_data = cache_block[index] & ~{{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}} | 
                              cpu_data_wdata & {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};

    integer t;
    always @(posedge clk) begin
        if(rst) begin
            for(t=0; t<CACHE_DEEPTH; t=t+1) begin   //刚开始将Cache置为无效且干净
                cache_valid[t] <= 0;
                cache_dirty[t] <= 0;
            end
        end
        else begin
            if(read_finish) begin //读缺失，访存结束时
                cache_valid[index_save] <= 1'b1;             //将Cache line置为有效
                cache_tag  [index_save] <= tag_save;
                cache_block[index_save] <= cache_data_rdata; //写入Cache line
                cache_dirty[index_save] <= 1'b0;//刚从内存读取到cache的数据一定是干净的
            end
            else if(write & hit) begin   //写命中时需要写Cache
                cache_block[index] <= write_cache_data;      //写入Cache line，使用index而不是index_save
                cache_dirty[index] <= 1'b1;
            end
        end
    end
endmodule