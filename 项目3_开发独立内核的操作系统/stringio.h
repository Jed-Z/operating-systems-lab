/*
 * @Author: Jed
 * @Description: 涉及字符串输入输出的C函数库
 * @Date: 2019-03-23
 * @LastEditTime: 2019-03-24
 */
#include <stdint.h>

extern void printInPos(char *msg, uint16_t len, uint8_t row, uint8_t col);
extern void putchar(char c);
extern char getch();

// char tempc;  // 临时存放一个字符的地方

/* 字符串长度 */
uint16_t strlen(char *str) {
    int count = 0;
    while (str[count++] != '\0');
    return count - 1;  // 循环中使用后递增，因此这里需要减1
}

/* 比较字符串 */
uint8_t strcmp(char* str1, char* str2) {
    int i = 0;
    while (1) {
        if(str1[i]=='\0' || str2[i]=='\0') { break; }
        if(str1[i] != str2[i]) { break; }
        ++i;
    }
    return str1[i] - str2[i];
}

/* 在光标处显示字符串 */
void print(char* str) {
    for(int i = 0, len = strlen(str); i < len; i++) {
        putchar(str[i]);
    }
}

/* 读取字符串到缓冲区 */
void readToBuf(char* buffer, uint16_t maxlen) {
    int i = 0;
    while(1) {
        char tempc = getch();
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
