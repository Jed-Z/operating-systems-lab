/*
 * @Author: Jed
 * @Description: 涉及字符串输入输出的C函数库
 * @Date: 2019-03-23
 * @LastEditTime: 2019-04-27
 */
#ifndef _STRINGIO_H_
#define _STRINGIO_H_

#include <stdint.h>
extern void printInPos(const char *msg, uint16_t len, uint8_t row, uint8_t col);
extern void putchar_c(char c, uint8_t color);
extern char getch();
enum bios_color {white_c=0x07};

/* 字符串长度 */
uint16_t strlen(const char *str) {
    int count = 0;
    while (str[count++] != '\0');
    return count - 1;  // 循环中使用后递增，因此这里需要减1
}

/* 比较字符串 */
uint8_t strcmp(const char* str1, const char* str2) {
    int i = 0;
    while (1) {
        if(str1[i]=='\0' || str2[i]=='\0') { break; }
        if(str1[i] != str2[i]) { break; }
        ++i;
    }
    return str1[i] - str2[i];
}

/* 显示一个白色字符 */
void putchar(char c) {
    putchar_c(c, 0x07);
}

/* 在光标处显示字符串 */
void print(const char* str) {
    for(int i = 0, len = strlen(str); i < len; i++) {
        putchar(str[i]);
    }
}

/* 在光标处显示彩色字符串 */
void print_c(const char* str, uint8_t color) {
    for(int i = 0, len = strlen(str); i < len; i++) {
        putchar_c(str[i], color);
    }
}

/* 读取字符串到缓冲区 */
void readToBuf(char* buffer, uint16_t maxlen) {
    int i = 0;
    while(1) {
        char tempc = getch();
        if(!(tempc==0xD || tempc=='\b' || tempc>=32 && tempc<=127)) { continue; }  // 非有效字符不予理会
        if(i > 0 && i < maxlen-1) { // buffer中有字符且未满
            if(tempc == 0x0D) {
                break;  // 按下回车，停止读取
            }
            else if(tempc == '\b') {  // 按下退格，则删除一个字符
                putchar('\b');
                putchar(' ');
                putchar('\b');
                --i;
            }
            else{
                putchar(tempc);  // 回显
                buffer[i] = tempc;
                ++i;
            }
        }
        else if(i >= maxlen-1) {  // 达到最大值，只能按退格或回车
            if(tempc == '\b') {  // 按下退格，则删除一个字符
                putchar('\b');
                putchar(' ');
                putchar('\b');
                --i;
            }
            else if(tempc == 0x0D) {
                break;  // 按下回车，停止读取
            }
        }
        else if(i <= 0) {  // buffer中没有字符，只能输入或回车，不能删除
            if(tempc == 0x0D) {
                break;  // 按下回车，停止读取
            }
            else if(tempc != '\b') {
                putchar(tempc);  // 回显
                buffer[i] = tempc;
                ++i;
            }
        }
    }
    putchar('\r'); putchar('\n');
    buffer[i] = '\0';  // 字符串必须以空字符结尾
}

/* 将整数转为指定进制的字符串 */
char* itoa(int val, int base) {
	if(val==0) return "0";
	static char buf[32] = {0};
	int i = 30;
	for(; val && i ; --i, val /= base) {
		buf[i] = "0123456789ABCDEF"[val % base];
    }
	return &buf[i+1];
}

/* 判断字符是否是十进制数字 */
uint8_t isnum(char c) {
    return c>='0' && c<='9';
}

/* 获取字符串的第一个空格前的词 */
void getFirstWord(const char* str, char* buf) {
    int i = 0;
    while(str[i] && str[i] != ' ') {
        buf[i] = str[i];
        i++;
    }
    buf[i] = '\0'; // 字符串必须以空字符结尾
}

/* 获取字符串的第一个空格后的词 */
void getAfterFirstWord(const char* str, char* buf) {
    buf[0] = '\0';  // 为了应对用户故意搞破坏
    int i = 0;
    while(str[i] && str[i] != ' ') {
        i++;
    }
    while(str[i] && str[i] == ' ') {
        i++;
    }
    int j = 0;
    while(str[i]) {
        buf[j++] = str[i++];
    }
    buf[j] = '\0';  // 字符串必须以空字符结尾
}

#endif