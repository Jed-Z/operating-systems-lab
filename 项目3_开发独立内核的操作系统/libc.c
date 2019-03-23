/*
 * @Author: Jed
 * @Description: C库；以C语言编写的库文件
 * @Date: 2019-03-21
 * @LastEditTime: 2019-03-23
 */
#include "stringio.h"
#define BUFLEN 16

extern void loadAndRun(uint8_t start, uint8_t len, uint16_t target);
extern void clearScreen();

struct UsrProgInfo {
    uint16_t pid;      // 用户程序编号
    char* name;        // 程序名
    uint16_t size;     // 程序大小（字节）
    uint16_t section;  // 在软盘中的扇区数
};

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

/* 打印系统提示符 */
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
    "    run 1 - run user programme 1\r\n"
    "    run 2 - run user programme 2\r\n"
    "    run 3 - run user programme 3\r\n"
    "    run 4 - run user programme 4\r\n"
    ;
    print(help_msg);
}

/* 操作系统shell */
void shell() {
    clearScreen();
    showHelp();
    
    char buf[BUFLEN] = {0};
    char* commands[] = {"help", "clear", "list", "run 1", "run 2", "run 3", "run 4"};

    while(1) {
        promptString();
        readToBuf(buf, BUFLEN);
        if(strcmp(buf, commands[0]) == 0) {
            showHelp();
        }
        else if(strcmp(buf, commands[1]) == 0) {
            clearScreen();
        }
        else if(strcmp(buf, commands[2]) == 0) {
            //?????????????????
        }
        else if(strcmp(buf, commands[3]) == 0) {
            loadAndRun(10, 2, 0xA300);
            clearScreen();
        }
        else if(strcmp(buf, commands[4]) == 0) {
            loadAndRun(12, 2, 0xA700);
            clearScreen();
        }
        else if(strcmp(buf, commands[5]) == 0) {
            loadAndRun(14, 2, 0xAB00);
            clearScreen();
        }
        else if(strcmp(buf, commands[6]) == 0) {
            loadAndRun(16, 2, 0xAF00);
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