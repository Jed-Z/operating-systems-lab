/*
 * @Author: Jed
 * @Description: C库；以C语言编写的库文件
 * @Date: 2019-03-21
 * @LastEditTime: 2019-04-14
 */
#include "stringio.h"
#define BUFLEN 16
#define NEWLINE putchar('\r');putchar('\n')
#define OS_VERSION "1.3"

extern void clearScreen();
extern void powerOff();
extern void reBoot();
extern uint8_t getUsrProgNum();
extern char* getUsrProgName(uint16_t pid);
extern uint16_t getUsrProgSize(uint16_t pid);
extern uint8_t getUsrProgCylinder(uint16_t pid);
extern uint8_t getUsrProgHead(uint16_t pid);
extern uint8_t getUsrProgSector(uint16_t pid);
extern uint16_t getUsrProgAddr(uint16_t pid);
extern void loadAndRun(uint8_t cylinder, uint8_t head, uint8_t sector, uint16_t len, uint16_t addr);
extern uint8_t getDateYear();
extern uint8_t getDateMonth();
extern uint8_t getDateDay();
extern uint8_t getDateHour();
extern uint8_t getDateMinute();
extern uint8_t getDateSecond();
extern uint16_t switchHotwheel();

/* 系统启动界面 */
void startUp() {
    clearScreen();
    const char* title = "JedOS v" OS_VERSION;
    const char* subtitle = "Zhang Yixin, 17341203";
    const char* date = "2019-04-12";
    const char* hint = "System has been loaded successfully. Press ENTER to start shell.";
    printInPos(title, strlen(title), 5, 35);
    printInPos(subtitle, strlen(subtitle), 6, 29);
    printInPos(date, strlen(date), 8, 35);
    printInPos(hint, strlen(hint), 15, 8);
}

/* 打印系统提示符 */
void promptString() {
    const char* prompt_string = "JedOS # ";
    print_c(prompt_string, 0x0B);  // 浅青色
}

/* 显示帮助信息 */
void showHelp() {
    const char *help_msg = 
    "Shell for JedOS, version " OS_VERSION " - on x86 PC\r\n"
    "This is a shell which is used for JedOS. These shell commands are defined internally. Use `help` to see the list.\r\n"
    "\r\n"
    "    help - show information about builtin commands\r\n"
    "    clear - clear the terminal screen\r\n"
    "    list - show a list of user programmes and their PIDs\r\n"
    "    run <PIDs> - run user programmes in sequence, e.g. `run 3 2 1`\r\n"
    "    poweroff - power-off the machine\r\n"
    "    reboot - reboot the machine"
    "    date - display the current date and time\r\n"
    "    hotwheel - turn on/off the hotwheel\r\n"
    ;
    print(help_msg);
}

/* 显示用户程序信息 */
void listUsrProg() {
    const char* hint = "You can use `run <PID>` to run a user programme.\r\n";
    const char* list_head =
        "PID  -     Name         -  Size  -  Addr - Cylinder - Head - Sector\r\n";
    const char* separator = "  -  ";
    print(hint);
    print(list_head);
    uint16_t prog_num = getUsrProgNum();  // 获取用户程序数量
    for(int i = 1; i <= prog_num; i++) {
        print(itoa(i, 10)); print(separator);  // 打印PID
        print(getUsrProgName(i));
        for(int j = 0, len = 16-strlen(getUsrProgName(i)); j < len; j++) {
            putchar(' ');
        }
        print(separator);  // 打印用户程序名
        print(itoa(getUsrProgSize(i), 10)); print(separator);  // 打印用户程序大小
        print(itoa(getUsrProgAddr(i), 16)); print(separator);  // 打印用户程序内存地址
        print(itoa(getUsrProgCylinder(i), 10)); print(separator);  // 打印用户程序存放的柱面号
        print(itoa(getUsrProgHead(i), 10)); print(separator);  // 打印用户程序存放的磁头号
        print(itoa(getUsrProgSector(i), 10));  // 打印用户程序存放的起始扇区
        NEWLINE;
    }
}

/* 操作系统shell */
void shell() {
    clearScreen();
    showHelp();
    
    char cmdstr[BUFLEN+1] = {0};  // 用于存放用户输入的命令和参数
    char cmd_firstword[BUFLEN+1] = {0};  // 用于存放第一个空格之前的子串
    enum command             { help,   clear,   list,   run,   poweroff,   reboot,   date,   hotwheel};
    const char* commands[] = {"help", "clear", "list", "run", "poweroff", "reboot", "date", "hotwheel"};

    while(1) {
        promptString();
        readToBuf(cmdstr, BUFLEN);
        getFirstWord(cmdstr, cmd_firstword);

        if(strcmp(cmd_firstword, commands[help]) == 0) {
            showHelp();
        }
        else if(strcmp(cmd_firstword, commands[clear]) == 0) {
            clearScreen();
        }
        else if(strcmp(cmd_firstword, commands[list]) == 0) {
            listUsrProg();
        }
        else if(strcmp(cmd_firstword, commands[run]) == 0) {  // run：运行用户程序
            char pids[BUFLEN+1];
            getAfterFirstWord(cmdstr, pids);  // 获取run后的参数列表
            uint8_t isvalid = 1;  // 参数有效标志位
            for(int i = 0; pids[i]; i++) {  // 判断参数是有效的
                if(!isnum(pids[i]) && pids[i]!=' ') {  // 既不是数字又不是空格，无效参数
                    isvalid = 0;
                    break;
                }
                if(isnum(pids[i]) && pids[i]-'0'>getUsrProgNum()) {
                    isvalid = 0;
                    break;
                }
            }
            if(isvalid) {  // 参数有效，则按顺序执行指定的用户程序
                int i = 0;
                for(int i = 0; pids[i] != '\0'; i++) {
                    if(isnum(pids[i])) {  // 是数字（不是空格）
                        int pid_to_run = pids[i] - '0';  // 要运行的用户程序PID
                        loadAndRun(getUsrProgCylinder(pid_to_run), getUsrProgHead(pid_to_run), getUsrProgSector(pid_to_run), getUsrProgSize(pid_to_run)/512, getUsrProgAddr(pid_to_run));
                        clearScreen();
                    }
                }
                const char* hint = "All programmes have been executed successfully as you wish.\r\n";
                print(hint);
            }
            else {  // 参数无效，报错，不执行任何用户程序
                const char* error_msg = "Invalid arguments. PIDs must be decimal numbers and less than or equal to ";
                print(error_msg);
                print(itoa(getUsrProgNum(), 10));
                putchar('.');
                NEWLINE;
            }

        }
        else if(strcmp(cmd_firstword, commands[poweroff]) == 0) {
            powerOff();
        }
        else if(strcmp(cmd_firstword, commands[reboot]) == 0) {
            reBoot();
        }
        else if(strcmp(cmd_firstword, commands[date]) == 0) {
            putchar('2'); putchar('0');
            print(itoa(getDateYear(), 10)); putchar('-');
            print(itoa(getDateMonth(), 10)); putchar('-');
            print(itoa(getDateDay(), 10)); putchar(' ');
            print(itoa(getDateHour(), 10)); putchar(':');
            print(itoa(getDateMinute(), 10)); putchar(':');
            print(itoa(getDateSecond(), 10));
            NEWLINE;
        }
        else if(strcmp(cmd_firstword, commands[hotwheel]) == 0) {
            const char* turned_on = "Hotwheel has been turned on.\r\n";
            const char* turned_off = "Hotwheel has been turned off.\r\n";
            if(switchHotwheel()==0) {
                print(turned_off);
            }
            else {
                print(turned_on);
            }
        }
        else {
            if(cmd_firstword[0] != '\0') {
                const char* error_msg = ": command not found\r\n";
                print(cmd_firstword);
                print(error_msg);
            }
        }
    }
}