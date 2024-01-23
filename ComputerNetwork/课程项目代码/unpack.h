#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "utils.h"

// 解封装UDP用户数据报，提取数据部分
unsigned char* unpack_UDP_Message(
    unsigned char* UDP_Message,
    unsigned short* length,
    unsigned int ip_src,
    unsigned int ip_dst
);
// 解包IP数据报，提取数据部分
unsigned char* unpack_ip_data_message(
    unsigned char* ip_data,
    unsigned short* length,
    unsigned int* ip_src,
    unsigned int* ip_dst
);
// 解包PPP帧，提取数据字段
unsigned char* unpack_frame(
    unsigned char* ppp_frame,
    unsigned short frame_length,
    unsigned short* data_length
);




// IP数据报重组
unsigned char* reassembly(
    unsigned char** ip_fragments,
    unsigned short* number,
    unsigned int* length
);