/*
 * @Author: Jed
 * @Description: C库；以C语言编写的库文件
 * @Date: 2019-03-21
 * @LastEditTime: 2019-03-23
 */
#include <stdint.h>
#define BUFLEN 16

extern void clearScreen();
extern void printInPos(char *msg, uint16_t len, uint8_t row, uint8_t col);
extern void putchar(char c);
extern void getch();

char tempc;

/* 字符串长度 */
uint16_t strlen(char *str) {
    int count = 0;
    while (str[count++] != '\0');
    return count - 1;  // 循环中使用后递增，因此这里需要减1
}

/* 比较字符串 */
uint8_t strcmp(char* str1, char* str2) {
    int i = 0;
    putchar('&');
    while (1) {
        putchar('*');
        if(str1[i]=='\0' || str2[i]=='\0') { break; }
        if(str1[i] != str2[i]) { break; }
        ++i;
    }
    putchar('&');
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
    int i;
    for(i = 0; i < maxlen; i++) {  // 不能超出最大长度
        getch();
        putchar(tempc);
        if(tempc == 0xD) {  // 按下回车，停止读取
            putchar('\n');
            break; 
        }
        buffer[i] = tempc;
    }
    for(; i < maxlen; i++) {
        buffer[i] = '\0';
    }
}

/* 系统启动界面 */
void startUp() {
    clearScreen();
    char* title = "JedOS V1.1";
    char* subtitle = "Zhang Yixin, 17341203";
    char* date = "2019-03-23";
    char* hint = "System is loaded successfully. Press ENTER to start shell.";
    printInPos(title, strlen(title), 5, 35);
    printInPos(subtitle, strlen(subtitle), 6, 29);
    printInPos(date, strlen(date), 8, 35);
    printInPos(hint, strlen(hint), 15, 11);
}

/* 打印提示符 */
void promptString() {
    char* prompt_string = "JedOS # ";
    print(prompt_string);
}

/* 显示帮助信息 */
void showHelp() {
    char *help_msg = 
    "JedOS shell, version 1.1\r\n"
    "This is a shell which is used for JedOS. These shell commands are defined internally. Type `help` to see this list.\r\n"
    "\r\n"
    "    help - show information about builtin commands\r\n"
    "    clear - clear the terminal screen\r\n"
    "    list - show a list of user programmes\r\n"
    "    run1 - run user programme 1\r\n"
    "    run2 - run user programme 2\r\n"
    "    run3 - run user programme 3\r\n"
    "    run4 - run user programme 4\r\n"
    ;
    print(help_msg);
}

/* 操作系统shell */
void shell() {
    char buf[BUFLEN] = {0};
    char* commands[] = {"help", "clear"};
    clearScreen();
    showHelp();
    while(1) {
        promptString();
        readToBuf(buf, BUFLEN);
        if(strcmp(buf, "help")) {
            showHelp();
        }
        else{
            clearScreen();
        }
    }
}