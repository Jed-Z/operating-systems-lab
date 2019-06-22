/*
 * @Author: Jed
 * @Description: 内核的 C 函数部分
 * @Date: 2019-03-21
 * @LastEditTime: 2019-06-03
 */
#include <stdint.h>
#include "stringio.h"
#include "process.h"
#define BUFLEN 16
#define OS_VERSION "1.6"
#define OS_BUILDDATE "2019-06-23"

extern void clearScreen();
extern void powerOff();
extern void reBoot();
extern uint8_t getUsrProgNum();
extern char* getUsrProgName(uint16_t progid);
extern uint16_t getUsrProgSize(uint16_t progid);
extern uint8_t getUsrProgCylinder(uint16_t progid);
extern uint8_t getUsrProgHead(uint16_t progid);
extern uint8_t getUsrProgSector(uint16_t progid);
extern uint16_t getUsrProgAddrSeg(uint16_t progid);
extern uint16_t getUsrProgAddrOff(uint16_t progid);
extern void loadAndRun(uint8_t cylinder, uint8_t head, uint8_t sector, uint16_t len, uint16_t seg, uint16_t offset);
extern uint8_t getDateYear();
extern uint8_t getDateMonth();
extern uint8_t getDateDay();
extern uint8_t getDateHour();
extern uint8_t getDateMinute();
extern uint8_t getDateSecond();
extern uint8_t bcd2decimal(uint8_t bcd);
extern void loadProcessMem(uint8_t cylinder, uint8_t head, uint8_t sector, uint16_t len, uint16_t seg, uint16_t offset, int progid_to_run);
extern uint16_t timer_flag;

PCB pcb_table[PROCESS_NUM];

void Delay()
{
	int i = 0;
	int j = 0;
	for( i=0;i<10000;i++ )
		for( j=0;j<10000;j++ )
		{
			j++;
			j--;
		}
}

/* 系统启动界面 */
void startUp() {
    pcb_init();

    clearScreen();
    const char* title = "JedOS v" OS_VERSION;
    const char* subtitle = "Zhang Yixin, 17341203";
    const char* date = OS_BUILDDATE;
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
    "    list - show a list of user programmes and their ProgIDs\r\n"
    "    bat <ProgIDs> - run user programmes in batch method, e.g. `bat 3 2 1`\r\n"
    "    run <ProgIDs> - create processes and run programmes simultaneously\r\n"
    "    poweroff - force power-off the machine\r\n"
    "    reboot - reboot the machine\r\n"
    "    date - display the current date and time\r\n"
    ;
    print(help_msg);
}

/* 显示用户程序信息 */
void listUsrProg() {
    const char* hint = "You can use `run <ProgID>` to run a user programme.\r\n";
    const char* list_head =
        "ProgID  - Program Name  -  Size  -  Addr - Cylinder - Head - Sector\r\n";
    const char* separator = "  -  ";
    print(hint);
    print(list_head);
    uint16_t prog_num = getUsrProgNum();  // 获取用户程序数量
    for(int i = 1; i <= prog_num; i++) {
        print(itoa(i, 10)); print(separator);  // 打印ProgID
        print(getUsrProgName(i));
        for(int j = 0, len = 16-strlen(getUsrProgName(i)); j < len; j++) {
            putchar(' ');
        }
        print(separator);  // 打印用户程序名
        print(itoa(getUsrProgSize(i), 10)); print(separator);  // 打印用户程序大小
        putchar('0'); putchar('x');  // 在十六进制数前显示0x
        print(itoa(getUsrProgAddrSeg(i), 16)); print(separator);  // 打印用户程序内存地址
        print(itoa(getUsrProgCylinder(i), 10)); print(separator);  // 打印用户程序存放的柱面号
        print(itoa(getUsrProgHead(i), 10)); print(separator);  // 打印用户程序存放的磁头号
        print(itoa(getUsrProgSector(i), 10));  // 打印用户程序存放的起始扇区
        NEWLINE;
    }
}

/* 显示日期时间 */
void showDateTime() {
    putchar('2'); putchar('0');
    print(itoa(bcd2decimal(getDateYear()), 10)); putchar('-');
    print(itoa(bcd2decimal(getDateMonth()), 10)); putchar('-');
    print(itoa(bcd2decimal(getDateDay()), 10)); putchar(' ');
    print(itoa(bcd2decimal(getDateHour()), 10)); putchar(':');
    print(itoa(bcd2decimal(getDateMinute()), 10)); putchar(':');
    print(itoa(bcd2decimal(getDateSecond()), 10));
    NEWLINE;
}

/* 批处理执行程序 */
void batch(char* cmdstr) {
    char progids[BUFLEN+1];
    getAfterFirstWord(cmdstr, progids);  // 获取run后的参数列表
    uint8_t isvalid = 1;  // 参数有效标志位
    for(int i = 0; progids[i]; i++) {  // 判断参数是有效的
        if(!isnum(progids[i]) && progids[i]!=' ') {  // 既不是数字又不是空格，无效参数
            isvalid = 0;
            break;
        }
        if(isnum(progids[i]) && progids[i]-'0'>4) {
            isvalid = 0;
            break;
        }
    }
    if(isvalid) {  // 参数有效，则按顺序执行指定的用户程序
        int i = 0;
        for(int i = 0; progids[i] != '\0'; i++) {
            if(isnum(progids[i])) {  // 是数字（不是空格）
                int progid_to_run = progids[i] - '0';  // 要运行的用户程序ProgID
                loadAndRun(getUsrProgCylinder(progid_to_run), getUsrProgHead(progid_to_run), getUsrProgSector(progid_to_run), getUsrProgSize(progid_to_run)/512, getUsrProgAddrSeg(progid_to_run), getUsrProgAddrOff(progid_to_run));
                clearScreen();
            }
        }
        const char* hint = "All programmes have been executed successfully as you wish.\r\n";
        print(hint);
    }
    else {  // 参数无效，报错，不执行任何用户程序
        const char* error_msg = "Invalid arguments. ProgIDs must be numbers and less than or equal to ";
        print(error_msg);
        print(itoa(getUsrProgNum(), 10));
        putchar('.');
        NEWLINE;
    }
}

void multiProcessing(char* cmdstr) {
    char progids[BUFLEN+1];
    getAfterFirstWord(cmdstr, progids);  // 获取run后的参数列表
    uint8_t isvalid = 1;  // 参数有效标志位
    if(progids[0] == '\0') { isvalid = 0; }
    for(int i = 0; progids[i]; i++) {  // 判断参数是有效的
        if(!isnum(progids[i]) && progids[i]!=' ') {  // 既不是数字又不是空格，无效参数
            isvalid = 0;
            break;
        }
        if(isnum(progids[i]) && progids[i]-'0' > 5) {
            isvalid = 0;
            break;
        }
    }
    if(isvalid) {  // 参数有效，则按顺序执行指定的用户程序
        int i = 0;
        for(int i = 0; progids[i] != '\0'; i++) {
            if(isnum(progids[i])) {  // 是数字（不是空格）
                int progid_to_run = progids[i] - '0';  // 要运行的用户程序ProgID
                loadProcessMem(getUsrProgCylinder(progid_to_run), getUsrProgHead(progid_to_run), getUsrProgSector(progid_to_run), getUsrProgSize(progid_to_run)/512, getUsrProgAddrSeg(progid_to_run), getUsrProgAddrOff(progid_to_run), progid_to_run);
            }
        }
        timer_flag = 1;  // 允许时钟中断处理多进程
        Delay();
        timer_flag = 0;  // 禁止时钟中断处理多进程
        clearScreen();
        const char* hint = "All processes have been killed.\r\n";
        print(hint);
    }
    else {  // 参数无效，报错，不执行任何用户程序
        const char* error_msg = "Invalid arguments. Check your progIDs again.";
        print(error_msg);
        NEWLINE;
    }
}

/* 操作系统shell */
void shell() {
    clearScreen();
    showHelp();
    char cmdstr[BUFLEN+1] = {0};  // 用于存放用户输入的命令和参数
    char cmd_firstword[BUFLEN+1] = {0};  // 用于存放第一个空格之前的子串
    enum command             { help,   clear,   list,   bat,   run,   poweroff,    reboot,   date};
    const char* commands[] = {"help", "clear", "list", "bat", "run", "poweroff",  "reboot", "date"};
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
        else if(strcmp(cmd_firstword, commands[bat]) == 0) {  // bat：批处理
            batch(cmdstr);
        }
        else if(strcmp(cmd_firstword, commands[run]) == 0) {  // bat：批处理
            multiProcessing(cmdstr);
        }
        else if(strcmp(cmd_firstword, commands[poweroff]) == 0) {
            powerOff();
        }
        else if(strcmp(cmd_firstword, commands[reboot]) == 0) {
            reBoot();
        }
        else if(strcmp(cmd_firstword, commands[date]) == 0) {
            showDateTime();
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