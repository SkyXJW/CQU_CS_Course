module d_cache_wb_4_LRU (
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
    reg                 cache_valid [CACHE_DEEPTH - 1 : 0][3:0];
    reg [TAG_WIDTH-1:0] cache_tag   [CACHE_DEEPTH - 1 : 0][3:0];
    reg [31:0]          cache_block [CACHE_DEEPTH - 1 : 0][3:0];
    reg                 cache_dirty [CACHE_DEEPTH - 1 : 0][3:0];
    reg [2:0]           cache_tree  [CACHE_DEEPTH - 1 : 0];

    //访问地址分解
    wire [OFFSET_WIDTH-1:0] offset;
    wire [INDEX_WIDTH-1:0] index;
    wire [TAG_WIDTH-1:0] tag;
    
    assign offset = cpu_data_addr[OFFSET_WIDTH - 1 : 0];
    assign index = cpu_data_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign tag = cpu_data_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];

    //访问Cache line
    wire c_valid[3:0];
    wire [TAG_WIDTH-1:0] c_tag[3:0];
    wire [31:0] c_block[3:0];
    wire c_dirty[3:0];
    wire [2:0] c_tree; //* tree 为对应cache set的查找树, tree[2]为根节点, tree[1]右子树，tree[0]左子树

    assign c_valid[0] = cache_valid[index][0];
    assign c_valid[1] = cache_valid[index][1];
    assign c_valid[2] = cache_valid[index][2];
    assign c_valid[3] = cache_valid[index][3];
    assign c_dirty[0] = cache_dirty[index][0];
    assign c_dirty[1] = cache_dirty[index][1];
    assign c_dirty[2] = cache_dirty[index][2];
    assign c_dirty[3] = cache_dirty[index][3];
    assign c_tag  [0] = cache_tag  [index][0];
    assign c_tag  [1] = cache_tag  [index][1];
    assign c_tag  [2] = cache_tag  [index][2];
    assign c_tag  [3] = cache_tag  [index][3];
    assign c_block[0] = cache_block[index][0];
    assign c_block[1] = cache_block[index][1];
    assign c_block[2] = cache_block[index][2];
    assign c_block[3] = cache_block[index][3];
    assign c_tree     = cache_tree [index];  
 
    //判断是否命中
    wire hit, miss;
    assign hit = c_valid[0] & (c_tag[0] == tag) | c_valid[1] & (c_tag[1] == tag) | c_valid[2] & (c_tag[2] == tag) | c_valid[3] & (c_tag[3] == tag);  //cache line的valid位为1，且tag与地址中tag相等
    assign miss = ~hit;
    wire [1:0] c_way;
    assign c_way = hit & (c_tag[0] == tag) ? 2'b00:
                   hit & (c_tag[1] == tag) ? 2'b01:
                   hit & (c_tag[2] == tag) ? 2'b10:
                   hit & (c_tag[3] == tag) ? 2'b11:
                   c_tree[2] ? {c_tree[2],c_tree[0]} :{c_tree[2],c_tree[1]};
 
    //读或写
    wire read, write;
    assign write = cpu_data_wr;
    assign read = ~write;

    //FSM
    parameter IDLE = 2'b00, RM = 2'b01, WM = 2'b11;
    reg [1:0] state;
    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE:   state <= cpu_data_req & read & miss & c_dirty[c_way]? WM :
                                 cpu_data_req & read & miss & ~c_dirty[c_way]? RM :
                                 cpu_data_req & write & miss & c_dirty[c_way]? WM :
                                 cpu_data_req & write & miss & ~c_dirty[c_way]? RM : IDLE;
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
    assign cpu_data_rdata   = hit ? c_block[c_way] : cache_data_rdata;
    assign cpu_data_addr_ok = cpu_data_req & hit | cache_data_req & read_req &cache_data_addr_ok;
    assign cpu_data_data_ok = cpu_data_req & hit | read_req & cache_data_data_ok;

    //output to axi interface
    assign cache_data_req   = read_req & ~addr_rcv | write_req & ~waddr_rcv;
    assign cache_data_wr    = write_req;
    assign cache_data_size  = cpu_data_size;
    assign cache_data_addr  = cache_data_wr ? {c_tag[c_way], index, offset} : cpu_data_addr;
    assign cache_data_wdata = c_block[c_way];

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
    assign write_cache_data = cache_block[index][c_way] & ~{{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}} | 
                              cpu_data_wdata & {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};

    integer t,T;
    always @(posedge clk) begin
        if(rst) begin
            for(t=0; t<CACHE_DEEPTH; t=t+1) begin //刚开始将Cache置为无效且干净，并将每组cache set的访问情况初始化
                cache_tree[t] <=3'b000;
             for(T=0; T<4; T=T+1) begin   
                cache_valid[t][T] <= 0;
                cache_dirty[t][T] <= 0;
            end
         end
        end
        else begin
            if(read_finish) begin //读缺失，访存结束时
                cache_valid[index_save][c_way] <= 1'b1;             //将Cache line置为有效
                cache_tag  [index_save][c_way] <= tag_save;
                cache_block[index_save][c_way] <= cache_data_rdata; //写入Cache line
                cache_dirty[index_save][c_way] <= 1'b0;
            end
            else if(write & hit) begin   //写命中时需要写Cache
                cache_block[index][c_way] <= write_cache_data;      //写入Cache line，使用index而不是index_save
                cache_dirty[index][c_way] <= 1'b1;
            end
            //这里考虑访问命中时cache_tree的更新（对于不命中的情况，在cache从内存中读回数据后，则转变为访问命中）：
            //依据伪LRU的二叉查找原理，如果分支节点为0，则说明该节点的右子树未被访问，为1，则说明该节点的左子树未被访问；
            //如果访问缺失，则从根节点开始一直这样找下去，最终达到的叶子节点，即是最近最少使用的一路；
            //而每次访问后，都需要将该叶子节点到根节点的所有分支节点（包括根节点）的值取反，来维护查找树的正确性。
            if(hit) begin
                if (c_way[1] == 1'b0)
                    {cache_tree[index][2], cache_tree[index][1]} <= {1-c_way[1],1-c_way[0]};
                else
                    {cache_tree[index][2], cache_tree[index][0]} <= {1-c_way[1],1-c_way[0]};
            end
        end
    end
endmodule