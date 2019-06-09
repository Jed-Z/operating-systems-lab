#include "../process.h"
extern void print(char*);
extern void clearScreen();
extern char* itoa();
extern int fork();
extern void wait();
extern void exit();

int letter_count = 0;
char the_str[] = "129djwqhdsajd128dw9i39ie93i8494urjoiew98kdkd";

void countLetter() {
    char* ptr = the_str;
    while(ptr) {
        if(*ptr >= 'a' && *ptr <= 'z') {
            letter_count += 1;
        }
    }
}

void cmain()
{
    clearScreen();
    print("This is the `fork_test` user programme.\r\n");

    int pid = fork();

    if(pid < 0) {  // fork失败
        print("[-] Error in fork! Press ESC to quit.\r\n");
    }
    else if(pid > 0) {  // 父进程
        print("[+] Parent process entered.\r\n");
        wait();

        print("The string is: ");
        print(the_str);
        print("\r\nLetter number is: ");
        print(itoa(letter_count, 10));
        print("\r\n\r\n[+] The fork test is finished! Press ESC to quit.\r\n");
        exit();
    }
    else {  // 子进程
        print("[+] Son process entered.\r\n");
        countLetter();  // 统计字母个数
        exit();
    }
}