/*
 * @Author: Jed
 * @Description: C库；以C语言编写的库文件
 * @Date: 2019-03-21
 * @LastEditTime: 2019-03-23
 */
#include <stdint.h>
#define BUFLEN 6

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
        getch();
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
    "Shell for JedOS, version 1.1 - on x86 PC\r\n"
    "This is a shell which is used for JedOS. These shell commands are defined internally. Use `help` to see the list.\r\n"
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
    clearScreen();
    showHelp();
    
    char buf[BUFLEN] = {0};
    char* commands[] = {"help", "clear"};

    while(1) {
        promptString();
        readToBuf(buf, BUFLEN);
        if(strcmp(buf, commands[0]) == 0) {
            showHelp();
        }
        else if(strcmp(buf, commands[1]) == 0) {
            clearScreen();
        }
        else {
            if(buf[0] != '\0') {
                char* error_msg = " : command not found\r\n";
                print(buf);
                print(error_msg);
            }
        }
    }
}