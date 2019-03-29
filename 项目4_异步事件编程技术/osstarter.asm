; @Author: Jed
; @Description: 操作系统内核文件；程序入口_start也在这里
; @Date: 2019-03-22
; @LastEditTime: 2019-03-23
BITS 16

[extern startUp]
[extern shell]
[extern Timer]

%macro WRITE_INT_VECTOR 2       ; 写中断向量表；参数：（中断号，中断处理程序地址）
    pusha
    mov ax, cs
    mov es, ax                  ; ES = 0
    mov word [es:%1*4], %2      ; 设置中断向量的偏移地址
    mov ax,cs
    mov word [es:%1*4+2], ax    ; 设置中断向量的段地址=CS
    popa
%endmacro

global _start
_start:
    WRITE_INT_VECTOR 08h, Timer ; 装填时钟中断向量表
    call dword startUp

Keyboard:
    mov ah, 0
    int 16h
    cmp al, 0dh                 ; 按下回车
    jne Keyboard                ; 无效按键，重新等待用户按键
    call dword shell            ; 进入命令行界面
    jmp Keyboard                ; 无限循环