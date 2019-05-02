; @Author: Jed
; @Description: 操作系统内核入口
; @Date: 2019-03-22
; @LastEditTime: 2019-03-23

BITS 16
%include "macro.asm"
[extern startUp]
[extern shell]
[extern syscaller]
[extern Timer]

extern set_clock

global _start
_start:
    WRITE_INT_VECTOR 21h, syscaller ; 装填系统调用中断向量表

SetTimer:
    call set_clock
    call dword startUp              ; 进入欢迎界面

Keyboard:
    mov ah, 0
    int 16h
    cmp al, 0Dh                     ; 按下回车
    jne Keyboard                    ; 无效按键，重新等待用户按键
    call dword shell                ; 进入命令行界面
    jmp Keyboard                    ; 无限循环