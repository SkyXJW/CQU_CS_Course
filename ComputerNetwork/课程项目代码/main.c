#include "pack.h"
#include "unpack.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int main()
{
    // 示例数据
    // unsigned char data[] = {0x45, 0x00, 0x00, 0x3C, 0x01, 0x23, 0x40, 0x00, 0x40, 0x06, 0x00, 0x00, 0xC0, 0xA8, 0x01, 0x01,
    //                   0xC0, 0xA8, 0x01, 0x02};
    // printf("封装测试：\n=================================\n");
    unsigned char data[] = { "Hello, this is test" };
    // 计算数据长度
    unsigned short dataLength = sizeof(data) / sizeof(data[0]);
    // printf("原始字符串: \n");
    // printf("%s\n",data);
    // printf("原始字符串(十六进制格式，按照字节单位进行输出) = \n");
    // for(int i=0;i<dataLength;i++)
    //  printf("%02x ",data[i]);
    // printf("\n");
    // // for(int i=0;i<dataLength;i++)
    // //    printf("%02x ",data[i]);
    // // printf("\n");

    // // 封装数据为UDP用户数据报
    // unsigned char* UDP = pack_UDP_Message(data, dataLength, 0xc0a80101, 0xc0a80202, 1, 2);
    // printf("运输层-UDP用户数据报封装(十六进制格式，按照字节单位进行输出): \n");
    // // 获取UDP用户数据报的长度
    // unsigned short UDP_length = (UDP[4] << 8) | UDP[5];
    //  for(int i=0;i<UDP_length;i++)
    //  printf("%02x ",UDP[i]);
    //  printf("\n");

    // // 封装数据为IP数据报
    // unsigned char* IP = pack_ip_data_message(UDP, UDP_length, 1, '1', 0, 0, 0xc0a80101, 0xc0a80202);
    // printf("网络层-IP数据报封装(十六进制格式，按照字节单位进行输出): \n");
    // // 获取数据报长度
    // unsigned short IP_length = (IP[2] << 8) | IP[3];
    // for(int i=0;i<IP_length;i++)
    //  printf("%02x ",IP[i]);
    // printf("\n");

    // // 封装后PPP帧的长度
    // unsigned short PPP_length = 0;
    // // 封装为PPP帧
    // unsigned char* ppp = pack_frame(IP, IP_length, &PPP_length);
    // printf("数据链路层-PPP帧封装(十六进制格式，按照字节单位进行输出): \n");
    // for(int i=0;i<PPP_length;i++)
    // printf("%02x ",ppp[i]);
    // printf("%d", PPP_length);
    // printf("\n");

    // // =================== 解封装 ===================
    //  printf("解封装测试：\n=================================\n");
    // unsigned short ppp_unpack_length = 0;
    // unsigned char* ppp_unpack = unpack_frame(ppp, PPP_length, &ppp_unpack_length);
    // if (ppp_unpack == NULL) {
    //     printf("unpack ppp failed\n");
    //     return 0;
    // }
    // printf("数据链路层-PPP帧解封装结果(IP数据报,十六进制格式，按照字节单位进行输出): \n");
    // // printf("IP_length=%d, unpacked_data_length=%d\n", IP_length, data_length);
    // for (size_t i = 0; i < ppp_unpack_length; i++) {
    //     if (ppp_unpack[i] != IP[i]) {
    //         printf("error in %d\n", i);
    //     }
    //     printf("%02x ", ppp_unpack[i]);
    // }
    // printf("\n");

    // unsigned short IP_unpack_length = 0;
    // unsigned int unpacked_ip_src, unpacked_ip_dst;
    // unsigned char* IP_unpack = unpack_ip_data_message(ppp_unpack, &IP_unpack_length, &unpacked_ip_src, &unpacked_ip_dst);
    // // printf("UDP_length=%d, unpacked_IP_length=%d\n", UDP_length, IP_unpack_length);
    // if (IP_unpack == NULL) {
    //     printf("unpack IP failed\n");
    //     return 0;
    // }
    // printf("网络层-IP数据报解封装结果(UDP用户数据报,十六进制格式，按照字节单位进行输出): \n");
    // for (size_t i = 0; i < IP_unpack_length; i++) {
    //     if (IP_unpack[i] != UDP[i]) {
    //         printf("error in %d\n", i);
    //     }
    //     printf("%02x ", IP_unpack[i]);
    // }
    // printf("\n");

    // unsigned short UDP_unpack_length = 0;
    // unsigned char* UDP_unpack = unpack_UDP_Message(IP_unpack, &UDP_unpack_length, unpacked_ip_src, unpacked_ip_dst);
    // // printf("data_length=%d, unpacked_UDP_length=%d\n", dataLength, UDP_unpack_length);
    // if (UDP_unpack == NULL) {
    //     printf("unpack UDP failed\n");
    //     return 0;
    // }
    // printf("运输层-UDP用户数据报解封装结果(解封后的数据,十六进制格式，按照字节单位进行输出): \n");
    // for (size_t i = 0; i < UDP_unpack_length; i++) {
    //     if (UDP_unpack[i] != data[i]) {
    //         printf("error in %d\n", i);
    //     }
    //     printf("%02x ",UDP_unpack[i]);
    // }
    // printf("\n");

    // printf("解封后的数据: \n");
    // printf("%s",UDP_unpack);

    // IP数据包分片
    // 准备数据
    printf("分片与重组测试:\n");
    printf("=================================\n");
    unsigned char shard_data[2900];
    printf("原始数据长度 = 2900\n");
    for (int i = 0; i < 145; i++)
        for (int j = 0; j < 20; j++)
            shard_data[i * 20 + j] = data[j];
    unsigned short number = 0; // 片数
    //进行分片，得到一个由多个分片IP数据报组成的数组
    unsigned char** ip = sharding(shard_data, 2900, &number, 1, 0xc0a80101, 0xc0a80202);
    printf("分片数目: %d\n", number);
    // 输出分片结果
    for (int i = 0; i < number; i++) {
        // 获取数据报长度
        unsigned short length = (ip[i][2] << 8) | ip[i][3];
        printf("第%d片长度(包含首部): %d\n", i + 1, length);
        printf("第%d片的IP数据报(十六进制格式,以字节为单位进行输出):\n",i+1);
        for(int j=0;j<length;j++)
         printf("%02x ",ip[i][j]);
        printf("\n");
    }

    // 分片重组
    unsigned int rebuild_length;
    unsigned short rebuild_number;
    unsigned char* rebuild_data = reassembly(ip, &rebuild_number, &rebuild_length);
    printf("重组中收到的分片数: %d\n", rebuild_number);
    printf("重组后数据长度 = %d\n", rebuild_length);
    //这里用重组后的数据将分片的IP数据报重新用一个IP数据报单独封装
    //获取原来分片IP数据报的源地址ip与目的地址ip
    unsigned int ip_src = 0;
    ip_src |= ip[0][12];
    ip_src |= ip[0][13];
    ip_src |= ip[0][14];
    ip_src |= ip[0][15];
    unsigned int ip_dst = 0;
    ip_dst |= ip[0][12];
    ip_dst |= ip[0][13];
    ip_dst |= ip[0][14];
    ip_dst |= ip[0][15];
    //进行分片IP数据报的重组
    unsigned char* rebuild_ip_message = pack_ip_data_message(rebuild_data,rebuild_length,ip[0][4],'0','0',0,ip_src,ip_src);
    //获取重组后的IP数据报长度
    unsigned short IP_length = (rebuild_ip_message[2]<<8) | rebuild_ip_message[3];
    printf("重组后的IP数据报长度(包含首部): %d\n",IP_length);
    printf("重组后的IP数据报(十六进制格式,以字节为单位进行输出):\n");
    for(int i=0;i<IP_length;i++)
    printf("%02x ",rebuild_ip_message[i]);
    printf("\n=================================\n");
    return 0;
}