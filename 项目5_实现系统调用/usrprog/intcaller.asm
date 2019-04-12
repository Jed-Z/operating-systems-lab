; @Author: Jed
; @Description: 用户程序，其中根据键盘输入调用int 33/34/35/36
; @Date: 2019-04-02
; @LastEditTime: 2019-04-12

%include "../macro.asm"
org offset_intcaller

Start:
    pusha
    push ds
    mov ax, cs
    mov ds, ax
    call ClearScreen
    PRINT_IN_POS hint_msg1, hint_msg1_len, 7, 10
    PRINT_IN_POS hint_msg2, hint_msg2_len, 10, 10

    ; 这四个中断处理程序是相同的，参数是不同的
    WRITE_INT_VECTOR 33, Int33~36
    WRITE_INT_VECTOR 34, Int33~36
    WRITE_INT_VECTOR 35, Int33~36
    WRITE_INT_VECTOR 36, Int33~36

Keyboard:
    mov ah, 0
    int 16h
    cmp al, '3'         ; 按下3
    je callInt33        ; 执行int 33
    cmp al, '4'         ; 按下4
    je callInt34        ; 执行int 34
    cmp al, '5'         ; 按下5
    je callInt35        ; 执行int 35
    cmp al, '6'         ; 按下6
    je callInt36        ; 执行int 36
    cmp al, 27          ; 按下ESC
    je QuitUsrProg      ; 直接退出
    jmp Keyboard        ; 无效按键，重新等待用户按键

callInt33:
    mov word[start_row], 0
    mov word[end_row], 5
    int 33
    jmp QuitUsrProg
callInt34:
    mov word[start_row], 6
    mov word[end_row], 11
    int 34
    jmp QuitUsrProg
callInt35:
    mov word[start_row], 12
    mov word[end_row], 17
    int 35
    jmp QuitUsrProg
callInt36:
    mov word[start_row], 18
    mov word[end_row], 24
    int 36
    jmp QuitUsrProg

QuitUsrProg:
    pop ds
    popa
    retf

ClearScreen:            ; 函数：清屏
    pusha
    mov ax, 0003h
    int 10h             ; 中断调用，清屏
    popa
    ret

Footer:
    hint_msg1 db 'This is the Interrupt Caller Programme.'
    hint_msg1_len equ $-hint_msg1
    hint_msg2 db 'Press `3/4/5/6` to call int 33/34/35/36. Press `ESC` to quit.'
    hint_msg2_len equ $-hint_msg2

%include "interrupt/int33~36.asm"