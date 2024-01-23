#include "utils.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// 解封装UDP用户数据报，提取数据部分(raw)
unsigned char* unpack_UDP_Message(unsigned char* UDP_Message, unsigned short* length, unsigned int ip_src, unsigned int ip_dst)
{
    // 从UDP_Message中获取数据部分长度
    unsigned short data_length = look_up_two_byte(UDP_Message + 4) - 8;
    *length = data_length;

    // 验证校验和
    unsigned short received_checksum = look_up_two_byte(UDP_Message + 6);
    if (received_checksum != 0) { // 如果为0说明不需要检验，跳过
        // 为了检验，重新加上伪数据报头，但不将校验和字段置0
        unsigned char* UDP_reset = (unsigned char*)malloc(20 + data_length);
        for (int i = 12; i < 20 + data_length; i++) {
            UDP_reset[i] = UDP_Message[i - 12];
        }
        // 加入伪首部
        fill_in_four_byte(UDP_reset, ip_src);
        fill_in_four_byte(UDP_reset + 4, ip_dst);
        UDP_reset[8] = 0x00;
        UDP_reset[9] = 0x11;
        fill_in_two_byte(UDP_reset + 10, data_length + 8);
        // 检验
        unsigned short checksum = UDP_checksum(UDP_reset, data_length + 20);
        if (checksum != 0) {
            printf("UDP Checksum verification failed. Discarding the packet.\n");
            return NULL;
        }
    }
    // 解封装
    unsigned char* data = (unsigned char*)malloc(data_length);
    for (int i = 0; i < data_length; i++) {
        data[i] = UDP_Message[8 + i];
    }
    return data;
    // return NULL;
}

// 对收到的IP数据报进行首部检验
int verify_ip_header(unsigned char* ip_data, unsigned short length)
{
    if (ip_data[0] != 0x45) {
        printf("error in 0\n");
        return 0;
    }
    if (ip_data[1] != 0x00) {
        printf("error in 1\n");
        return 0;
    }
    if (ip_data[2] != ((length >> 8) & 0xff)) {
        printf("error in 2\n");
        return 0;
    }
    if (ip_data[3] != (length & 0xff)) {
        printf("error in 3\n");
        return 0;
    }
    unsigned short received_checksum = look_up_two_byte(ip_data + 10);

    // 重做一遍验证，但不置0校验和段
    unsigned short checksum = IP_checksum((unsigned short*)ip_data, 10);
    return checksum == 0;
}
// 解包IP数据报，提取数据部分（UDP包装）
unsigned char* unpack_ip_data_message(unsigned char* ip_data, unsigned short* length, unsigned int* ip_src, unsigned int* ip_dst)
{
    // 检验首部
    unsigned short ip_header_length = (ip_data[0] & 0x0F) * 4; // 获取IP头部长度
    unsigned short total_length = look_up_two_byte(ip_data + 2); // 获取总长度
    *ip_src = look_up_four_byte(ip_data + 12); // 获取源IP地址
    *ip_dst = look_up_four_byte(ip_data + 16); // 获取目的IP地址
    if (!verify_ip_header(ip_data, total_length)) {
        printf("error in verify IP header\n");
        return NULL;
    }

    // 解封装
    unsigned char* data = NULL;
    unsigned short data_length = total_length - ip_header_length; // 计算数据部分长度
    // printf("IN UNPACKING: full_length=%d, data_length=%d\n", total_length, data_length);
    *length = data_length;

    if (data_length > 0) {
        data = (unsigned char*)malloc(data_length * sizeof(unsigned char));
        for (int i = 0; i < data_length; i++) {
            data[i] = ip_data[ip_header_length + i];
        }
    }

    return data;
}

// 对收到的PPP帧进行首部检验
int verify_ppp_header(unsigned char* ppp_frame, unsigned short frame_length)
{
    if (ppp_frame[0] != 0x7E) {
        printf("error in 0\n");
        return 0;
    }
    if (ppp_frame[1] != 0xFF) {
        printf("error in 1\n");
        return 0;
    }
    if (ppp_frame[2] != 0x03) {
        printf("error in 2\n");
        return 0;
    }
    if (ppp_frame[3] != 0x00) {
        printf("error in 3\n");
        return 0;
    }
    if (ppp_frame[4] != 0x21) {
        printf("error in 4\n");
        return 0;
    }
    if (ppp_frame[frame_length - 1] != 0x7E) {
        printf("error in %d\n", frame_length - 1);
        return 0;
    }
    return 1;
}
// 解包PPP帧，提取数据字段（IP包装）
unsigned char* unpack_frame(unsigned char* ppp_frame, unsigned short frame_length, unsigned short* data_length)
{
    // 检验首部
    if (!verify_ppp_header(ppp_frame, frame_length)) {
        printf("error in verify ppp header\n");
        return NULL;
    }
    // 解封数据
    unsigned char* data = (unsigned char*)malloc(frame_length * sizeof(unsigned char)); // 分配足够的空间
    unsigned short index = 0; // 记录解包后的数据的索引
    for (int i = 5; i < frame_length - 3; i++) { // 遍历信息字段
        if (ppp_frame[i] == 0x7D) { // 如果是转义字符
            if (ppp_frame[i + 1] == 0x5E) { // 如果是转义字符0x5E
                data[index++] = 0x7E; // 将原字节加0x20
                i++;
            } else if (ppp_frame[i + 1] == 0x5D) { // 如果是转义字符0x5D
                data[index++] = 0x7D; // 将原字节加0x20
                i++;
            } else { // 如果是其他转义字符
                data[index++] = ppp_frame[i + 1] - 0x20; // 将原字节减0x20
                i++;
            }
        } else { // 如果是普通字符
            data[index++] = ppp_frame[i];
        }
    }
    *data_length = index; // 返回解包后的数据长度
    // 检验fcs是否一致
    unsigned short fcs_received = look_up_two_byte(ppp_frame + frame_length - 3);
    unsigned short fcs = crc_ccitt(&ppp_frame[5], frame_length - 8);
    if (fcs != fcs_received) {
        printf("error in varifying checksum\n");
        return NULL;
    }
    return data; // 返回解包后的数据
}

// IP数据报重组
unsigned char* reassembly(unsigned char** ip_fragments, unsigned short* number, unsigned int* length)
{
    unsigned short total_length = 0;
    unsigned short identification = 0;
    unsigned char* data = malloc(10 * sizeof(char));
    unsigned int data_p = 0;

    unsigned short i = 0;
    while (1) {
        unsigned char* ip_fragment = ip_fragments[i++];
        unsigned int fragment_flag = ip_fragment[6] >> 5; // 获取分片标志
        unsigned short fragment_offset = ((ip_fragment[6] & 0x1f) << 8 | ip_fragment[7]) << 3; // 获取offset

        unsigned short IP_unpack_length;
        unsigned int unpacked_ip_src, unpacked_ip_dst;
        unsigned char* IP_unpack = unpack_ip_data_message(ip_fragment, &IP_unpack_length, &unpacked_ip_src, &unpacked_ip_dst);

        if (IP_unpack == NULL) {
            printf("Error in unpacking fragment %d\n", i);
            return NULL;
        }
        if (fragment_offset != data_p) {
            printf("Error: the offset does not match the bytes received\n");
            printf("received bytes: %d, offset: %d\n", data_p, fragment_offset);
            return NULL;
        }
        data = realloc(data, sizeof(char) * (data_p + IP_unpack_length));
        memcpy(data + data_p, IP_unpack, IP_unpack_length);
        data_p += IP_unpack_length;

        if (fragment_flag != 1) // will continue only if MF=1 DF=0
            break;
    }
    *length = data_p;
    *number = i;
    return data;
}