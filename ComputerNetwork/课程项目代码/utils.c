#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

void fill_in_two_byte(unsigned char* st, unsigned short num)
{
    st[0] = (num >> 8) & 0xff;
    st[1] = num & 0xff;
}
void fill_in_four_byte(unsigned char* st, unsigned int num)
{
    st[0] = (num >> 24) & 0xff;
    st[1] = (num >> 16) & 0xff;
    st[2] = (num >> 8) & 0xff;
    st[3] = num & 0xff;
}
unsigned short look_up_two_byte(unsigned char* st, unsigned short* num)
{
    return (st[0] << 8) | st[1];
}
unsigned int look_up_four_byte(unsigned char* st, unsigned int* num)
{
    return (st[0] << 24) | (st[1] << 16) | (st[2] << 8) | st[3];
}

// 计算UDP校验和
unsigned short UDP_checksum(unsigned char* data, unsigned short length)
{ // length是指字节数
    unsigned int sum = 0;
    unsigned short i = 0;
    while (length > 1) {
        sum += ((data[i] << 8) | data[i + 1]);
        length -= 2;
        i += 2;
    }

    // 如果数据长度是奇数，即需要填充0
    if (length > 0) {
        sum += ((data[i] << 8) | 0x00);
    }

    // 将高16位与低16位相加
    sum = (sum >> 16) + (sum & 0xFFFF);

    // 将进位加到低16位
    sum += (sum >> 16);

    // 取反得到一's complement
    return (unsigned short)~sum;
}

// 计算IP头部的校验和
unsigned short IP_checksum(unsigned short* buf, int nwords)
{
    // 初始化校验和为0
    unsigned long sum = 0;
    // 每次处理两个字节，累加到校验和中
    for (; nwords > 0; nwords--) {
        unsigned short res = (*buf>>8) | (*buf<<8) ;
        sum += res;
        buf++;
    }
    // 如果校验和超过16位，将高16位和低16位相加
    sum = (sum >> 16) + (sum & 0xffff);
    // 如果还有进位，再加一次
    sum += (sum >> 16);
    // 返回校验和的反码
    return ~sum;
}

unsigned short crc_ccitt(unsigned char data[], unsigned short length)
{
    unsigned short crc = 0xFFFF; // 初始值
    unsigned short poly = 0x1021; // 多项式
    for (int i = 0; i < length; i++) { // 遍历每个字节
        crc ^= data[i] << 8; // 将字节与CRC寄存器异或
        for (int j = 0; j < 8; j++) { // 遍历每个比特
            if (crc & 0x8000) { // 如果最高位为1
                crc = (crc << 1) ^ poly; // 左移一位，与多项式异或
            } else { // 如果最高位为0
                crc = crc << 1; // 左移一位
            }
        }
    }
    return crc; // 返回计算结果
}
// PPP帧采用异步传输，这里则需要对信息字段进行透明传输的处理，使用字节填充的方法
unsigned char* byte_stuffing(unsigned char data[], unsigned short length, unsigned short* new_length)
{
    unsigned char* stuffed_data = (unsigned char*)malloc(length * 2); // 分配足够的空间
    unsigned short index = 0; // 记录填充后的数据的索引
    for (int i = 0; i < length; i++) { // 遍历每个字节
        if (data[i] == 0x7E) { // 如果是标志字段
            stuffed_data[index++] = 0x7D; // 插入转义字符
            stuffed_data[index++] = 0x5E; // 将原字节减0x20
        } else if (data[i] == 0x7D) { // 如果是转义字符
            stuffed_data[index++] = 0x7D; // 插入转义字符
            stuffed_data[index++] = 0x5D; // 将原字节减0x20
        } else if (data[i] < 0x20) { // 如果是控制字符
            stuffed_data[index++] = 0x7D; // 插入转义字符
            stuffed_data[index++] = data[i] + 0x20; // 将原字节加0x20
        } else { // 如果是普通字符
            stuffed_data[index++] = data[i]; // 直接复制
        }
    }
    *new_length = index; // 返回填充后的数据的长度
    return stuffed_data; // 返回填充后的数据
}