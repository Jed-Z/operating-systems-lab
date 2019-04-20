#include <stdint.h>
#define bool unsigned short
#define true 1
#define false 0

/* 将字符串中的小写字母转换为大写 */
void toupper(char* str) {
    int i=0;
    while(str[i]) {
        if (str[i] >= 'a' && str[i] <= 'z')  
        str[i] = str[i]-'a'+'A';
        i++;
    }
}

/* 将字符串中的大写字母转换为小写 */
void tolower(char* str) {
    int i=0;
    while(str[i]) {
        if (str[i] >= 'A' && str[i] <= 'Z')  
        str[i] = str[i]-'A'+'a';
        i++;
    }
}

/* 翻转字符串 */
void my_reverse(char str[], int len)
{
	int start, end;
	char temp;
	for (start = 0, end = len - 1; start < end; start++, end--) {
		temp = *(str + start);
		*(str + start) = *(str + end);
		*(str + end) = temp;
	}
}

/* 将数字转换为字符串并放在str中 */
char* itoa_buf(int num, int base, char* str)
{
	int i = 0;
	bool isNegative = false;

	/* A zero is same "0" string in all base */
	if (num == 0) {
		str[i] = '0';
		str[i + 1] = '\0';
		return str;
	}

	/* negative numbers are only handled if base is 10
	   otherwise considered unsigned number */
	if (num < 0 && base == 10) {
		isNegative = true;
		num = -num;
	}

	while (num != 0) {
		int rem = num % base;
		str[i++] = (rem > 9) ? (rem - 10) + 'A' : rem + '0';
		num = num / base;
	}

	/* Append negative sign for negative numbers */
	if (isNegative) {
		str[i++] = '-';
	}

	str[i] = '\0';

	my_reverse(str, i);

	return str;
}

/* 将十进制数字字符串转换为整数 */
int atoi(char *str) {
    int res = 0; // Initialize result 

    // Iterate through all characters of input string and 
    // update result 
    for (int i = 0; str[i] != '\0'; ++i) {
        res = res*10 + str[i] - '0'; 
    }
    // return result. 
    return res; 
}