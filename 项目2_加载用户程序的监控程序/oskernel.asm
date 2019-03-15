%include "header.asm"
org 0A100h

start:
    call ClearScreen ; 清屏
    PRINT_IN_POS str_title, titlelen, 5, 35
    PRINT_IN_POS str_subtitle, subtitlelen, 6, 29
    PRINT_IN_POS str_date, datelen, 8, 35
    PRINT_IN_POS str_hint1, hint1len, 15, 10

Keyboard:
    mov ah, 0; Bochs: 0000:a173
    int 16h
    cmp al, '1'; 按下1
    je offset_usrprog1   ; 执行用户程序1
    cmp al, '2'; 按下2
    je offset_usrprog2   ; 执行用户程序2
    cmp al, '3'; 按下3
    je offset_usrprog3   ; 执行用户程序3
    cmp al, '4'; 按下4
    je offset_usrprog4   ; 执行用户程序14
    jmp Keyboard; 无效按键，重新等待用户按键

ClearScreen:         ; 函数：清屏
    pusha
    mov ax, 0003h
    int 10h          ; 中断调用，清屏
    popa
    ret

DataArea:
    str_title db 'JedOS V1.0'
    titlelen equ ($-str_title)

    str_subtitle db 'Zhang Yixin, 17341203'
    subtitlelen equ ($-str_subtitle)

    str_date db '2019-03-12'
    datelen equ ($-str_date)

    str_hint1 db 'Press a key (1/2/3/4) to run the corresponding user program!'
    hint1len equ ($-str_hint1)

SectorEnding:
    times 510-($-$$) db 0
    db 0x55,0xaa