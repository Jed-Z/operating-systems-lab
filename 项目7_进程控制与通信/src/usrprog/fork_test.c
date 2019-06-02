#include <stdint.h>
#include "../fork.h"

extern void putchar(char c);
uint16_t strlen(const char *str) {
    int count = 0;
    while (str[count++] != '\0');
    return count - 1;  // 循环中使用后递增，因此这里需要减1
}
void print(const char* str) {
    for(int i = 0, len = strlen(str); i < len; i++) {
        putchar(str[i]);
    }
}
char* itoa(int val, int base) {
	if(val==0) return "0";
	static char buf[32] = {0};
	int i = 30;
	for(; val && i ; --i, val /= base) {
		buf[i] = "0123456789ABCDEF"[val % base];
    }
	return &buf[i+1];
}

char str[]= "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
uint16_t letter_num = 0;

void cmain()
{
    int pid = fork();
    if(pid == -1) {
        const char* fork_error = "Error in fork!\r\n";
        print(fork_error);
        exit();
    }
    else if(pid != 0) {  // 父进程
        wait();
        const char* hint = "The number of letters is ";
        print(hint);
        print(itoa(letter_num, 10));
    }
    else {  // 子进程
        for(int i = 0; i < strlen(str); i++) {
            if(str[i] >= '0' && str[i] <= '9') {
                letter_num += 1;
            }
        }
        exit();
    }
    const char* ready = "ready to exit\r\n";
    print(ready);
}