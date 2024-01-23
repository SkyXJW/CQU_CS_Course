#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "utils.h"

// 将数据封装成UDP用户数据报
unsigned char* pack_UDP_Message(
    unsigned char* data,
    unsigned short length,
    unsigned int ip_src,
    unsigned int ip_dst,
    unsigned short port_src,
    unsigned short port_dst
);
// 将数据封装成IP数据报，采用的IP协议版本为IPV4，固定首部长度为20，采用UDP协议
unsigned char* pack_ip_data_message(
    unsigned char* data,
    unsigned short length,
    unsigned short identification,
    unsigned char DF,
    unsigned char MF,
    unsigned short offset,
    int ip_src,
    int ip_dst
);
// 将数据封装成PPP帧，使用异步链路和IP协议
unsigned char* pack_frame(
    unsigned char* data,
    unsigned short length,
    unsigned short* new_length
);



// IP数据报分片
unsigned char** sharding(
    unsigned char* data,
    unsigned int length,
    unsigned short* number,
    unsigned short identification,
    unsigned ip_src,
    unsigned int ip_dst
);