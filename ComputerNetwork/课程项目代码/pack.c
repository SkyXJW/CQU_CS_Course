// 从上至下:运输层-UDP用户数据报、网络层-IP数据报、数据链路层-PPP帧
// 其中，网络层的IP数据报采用IPv4,且不考虑可选字段，即固定首部为20字节，但需要完成IP数据报的分片(本封装中已经完成)与重组(由解封装负责完成)
// 此外，数据链路层的PPP帧使用异步传输，因此使用了字节填充，所以需要解封时将填充的字节删掉得到正确的数据部分，即进行字节填充的逆操作
// 最终封装产生的PPP帧由一个字节数组存储，并且提供该帧的长度(以字节为单位)
// ……

#include "utils.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

// 将数据封装成UDP用户数据报
unsigned char* pack_UDP_Message(unsigned char* data, unsigned short length, unsigned int ip_src, unsigned int ip_dst, unsigned short port_src, unsigned short port_dst)
{
    unsigned char* UDP_Message = (unsigned char*)malloc(65548); // 申请足够的空间，UDP用户数据报的长度最多为65536字节,但这里加上12字节的伪首部
    fill_in_two_byte(UDP_Message + 12, port_src); // 源端口字段
    fill_in_two_byte(UDP_Message + 14, port_dst); // 目的端口字段

    unsigned short newlength = 8 + length;
    fill_in_two_byte(UDP_Message + 16, newlength); // 长度字段
    fill_in_two_byte(UDP_Message + 18, 0); // 将校验和字段置0，为后续校验和计算准备
    for (int i = 0; i < length; i++) {
        UDP_Message[20 + i] = data[i];
    }

    // 加入伪首部
    fill_in_four_byte(UDP_Message, ip_src);
    fill_in_four_byte(UDP_Message + 4, ip_dst);
    UDP_Message[8] = 0x00;
    UDP_Message[9] = 0x11;
    fill_in_two_byte(UDP_Message + 10, newlength);
    // 计算校验和
    unsigned short checksum = UDP_checksum(UDP_Message, newlength + 12);
    fill_in_two_byte(UDP_Message + 18, checksum); // 填入校验和字段
    return &UDP_Message[12];
}

// 将数据封装成IP数据报，采用的IP协议版本为IPV4，固定首部长度为20，采用UDP协议
unsigned char* pack_ip_data_message(unsigned char* data, unsigned short length, unsigned short identification, unsigned char DF, unsigned char MF, unsigned short offset, int ip_src, int ip_dst)
{
    // for(int i=0;i<length;i++)
    //   ip_data_message->data[i] = data[i];

    unsigned char* ip = (unsigned char*)malloc(65535); // 申请足够的空间，IP数据包的长度最长为65535字节
    ip[0] = 0x45; // IPv4的版本号-4 与首部长度-20
    ip[1] = 0x00; // 该字段不使用
    unsigned short total_length = 20 + length;
    fill_in_two_byte(ip + 2, total_length); // 总长度
    fill_in_two_byte(ip + 4, identification); // 标识
    unsigned short tm = ((0xffff & (DF << 1) | MF) << 13) | offset;
    fill_in_two_byte(ip + 6, tm); // 标识与片偏移
    ip[8] = 1; // 生存时间默认为1
    ip[9] = 17; // 采用UDP协议
    fill_in_two_byte(ip + 10, 0); // 先将首部校验位置0，为后面的首部校验和计算准备
    fill_in_four_byte(ip + 12, ip_src); // 源IP地址
    fill_in_four_byte(ip + 16, ip_dst); // 目的IP地址

    // 调用checksum函数，传入IP头部的指针和头部长度的一半（因为是按两个字节处理的）
    unsigned short check_sum = IP_checksum((unsigned short*)ip, 10); // 计算校验和
    fill_in_two_byte(ip + 10, check_sum); // 填入首部校验和字段
    for (int i = 0; i < length; i++)
        ip[20 + i] = data[i];
    return ip;
}

// IP数据报分片
unsigned char** sharding(unsigned char* data, unsigned int length, unsigned short* number, unsigned short identification, unsigned ip_src, unsigned int ip_dst)
{
    // 计算分片数目
    unsigned short count = length / 1480; // 因为采用的是PPP协议，限制MTU为1500，再减去20字节的固定首部，即得到每片IP数据报的数据部分为1480
    unsigned char** array_ip = (unsigned char**)malloc((count + 1) * sizeof(unsigned char*));
    for (int i = 0; i < count + 1; i++) {
        array_ip[i] = (unsigned char*)malloc(1500 * sizeof(unsigned char));
    }
    // unsigned char (*array_ip)[1508] = malloc((count+1) * sizeof(unsigned char[1508]));
    for (int i = 0; i < count; i++)
        array_ip[i] = pack_ip_data_message(&data[i * 1480], 1480, identification, 0, 1, 185 * i, ip_src, ip_dst);
    // 计算最后可能剩余的数据长度
    unsigned short res = length % 1480;
    if (res != 0) {
        array_ip[count] = pack_ip_data_message(&data[count * 1480], res, identification, 0, 0, count * 185, ip_src, ip_dst);
        *number = count + 1;
    } else {
        array_ip[count - 1] = pack_ip_data_message(&data[(count - 1) * 1480], 1480, identification, 0, 0, 185 * (count - 1), ip_src, ip_dst);
        *number = count;
    }
    return array_ip;
}

// 将数据封装成PPP帧，使用异步链路和IP协议
unsigned char* pack_frame(unsigned char* data, unsigned short length, unsigned short* new_length)
{
    unsigned char* ppp = (unsigned char*)malloc(sizeof(1508)); // 申请足够的空间，PPP帧最多只有1508字节
    ppp[0] = 0x7E; // 填充标志字段
    ppp[1] = 0xFF; // 填充地址字段
    ppp[2] = 0x03; // 填充控制字段
    ppp[3] = 0x00;
    ppp[4] = 0x21; // 填充协议字段
    unsigned short newlength = 0; // 信息字段完成字节填充后的信息字段长度
    unsigned char* stuffed_data = byte_stuffing(data, length, &newlength); // 对信息字段进行字节填充
    for (int i = 5; i < 5 + newlength; i++) {
        ppp[i] = stuffed_data[i - 5];
    }
    unsigned short fcs = crc_ccitt(&ppp[5], newlength); // 计算校验和
    fill_in_two_byte(ppp + 5 + newlength, fcs); // 填充校验和字段
    ppp[7 + newlength] = 0x7e;
    *new_length = 8 + newlength;
    return ppp; // 返回封装后的帧
}