; @Author: Jed
; @Description: 汇编库；以nasm汇编格式编写的库文件，包含了多个函数，可供asm或C调用
; @Date: 2019-03-21
; @LastEditTime: 2019-03-23

BITS 16
[global clearScreen]

clearScreen: ; 函数：清屏
    push ax
    mov ax, 0003h
    int 10h  ; 中断调用，清屏
    pop ax
    retf