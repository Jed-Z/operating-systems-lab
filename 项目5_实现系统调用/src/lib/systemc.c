#include <stdint.h>

void toupper(char* str) {
    int i=0;
    while(str[i]) {
        if (str[i] >= 'a' && str[i] <= 'z')  
        str[i] = str[i]+'A'-'a';
        i++;
    }
}

void tolower(char* str) {
    int i=0;
    while(str[i]) {
        if (str[i] >= 'a' && str[i] <= 'z')  
        str[i] = str[i]+'a'-'A';
        i++;
    }
}