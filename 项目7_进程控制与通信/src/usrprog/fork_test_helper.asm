BITS 16
[global putchar]
[extern cmain]
[global _start]

_start:
pusha
push ds
call dword cmain

TestEscKey:
    mov ah, 0
    int 16h
    cmp al, 27     ; 按下ESC
    jne TestEscKey ; 无效按键，重新等待用户按键

pop ds
popa
retf               ; 退出用户程序

putchar:           ; 函数：在光标处打印一个字符
    pusha
    mov bp, sp
    add bp, 16+4   ; 参数地址
    mov al, [bp]   ; al=要打印的字符
    mov bh, 0      ; bh=页码
    mov ah, 0Eh    ; 功能号：打印一个字符
    int 10h        ; 打印字符
    popa
    retf