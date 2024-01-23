#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

// 填充2个字节
void fill_in_two_byte(unsigned char* st, unsigned short num);
// 填充4个字节
void fill_in_four_byte(unsigned char* st, unsigned int num);
// 查看2个字节
unsigned short look_up_two_byte(unsigned char* st);
// 查看4个字节
unsigned int look_up_four_byte(unsigned char* st);


// 计算UDP校验和
unsigned short UDP_checksum(unsigned char* data, unsigned short length);
// 计算IP头部的校验和
unsigned short IP_checksum(unsigned short* buf, int nwords);
// 计算PPP帧的校验和，使用CRC-CCITT算法
unsigned short crc_ccitt(unsigned char data[], unsigned short length);
// PPP帧采用异步传输，这里则需要对信息字段进行透明传输的处理，使用字节填充的方法
unsigned char* byte_stuffing(unsigned char data[], unsigned short length, unsigned short* new_length);