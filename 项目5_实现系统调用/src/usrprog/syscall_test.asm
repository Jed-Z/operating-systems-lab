; @Author: Jed
; @Description: 测试系统调用的用户程序
; @Date: 2019-04-17
; @LastEditTime: 2019-04-19

%include "../macro.asm"
org offset_syscalltest

Start:
    pusha
    push es

    mov ax, 0003h
    int 10h                            ; 清屏

    PRINT_IN_POS hint_all, hint_all_len, 0, 0

    PRINT_IN_POS hint0, hint_len, 2, 0
    mov ah, 00h                        ; 系统调用功能号
    int 21h
    mov ah, 0
    int 16h
    cmp al, 27                         ; 按下ESC
    je QuitUsrProg                     ; 直接退出

    PRINT_IN_POS hint1, hint_len, 2, 0
    mov ax, cs
    mov es, ax                         ; es=cs
    mov dx, upper_lower                ; es:dx=串地址
    PRINT_IN_POS upper_lower, 14, 3, 0
    mov ah, 01h                        ; 系统调用功能号
    int 21h
    PRINT_IN_POS upper_lower, 14, 4, 0
    mov ah, 0
    int 16h
    cmp al, 27                         ; 按下ESC
    je QuitUsrProg                     ; 直接退出

    PRINT_IN_POS hint2, hint_len, 2, 0
    mov ax, cs
    mov es, ax                         ; es=cs
    mov dx, upper_lower                ; es:dx=串地址
    mov ah, 02h                        ; 系统调用功能号
    int 21h
    PRINT_IN_POS upper_lower, 14, 5, 0
    mov ah, 0
    int 16h
    cmp al, 27                         ; 按下ESC
    je QuitUsrProg                     ; 直接退出

    PRINT_IN_POS hint3, hint_len, 2, 0
    mov ah, 03h                        ; 系统调用功能号
    int 21h
    mov ah, 0
    int 16h
    cmp al, 27                         ; 按下ESC
    je QuitUsrProg                     ; 直接退出

    PRINT_IN_POS hint4, hint_len, 2, 0
    mov ah, 04h
    int 21h
    mov ah, 0
    int 16h
    cmp al, 27                         ; 按下ESC
    je QuitUsrProg                     ; 直接退出

    PRINT_IN_POS hint5, hint_len, 2, 0
    mov ax, cs
    mov es, ax                         ; es=cs
    mov dx, test_message1              ; es:dx=串地址
    mov ch, 19                         ; 行号
    mov cl, 0                          ; 列号
    mov ah, 05h                        ; 系统调用功能号
    int 21h                            ; 显示第一条字符串
    mov dx, test_message2
    mov ch, 20
    mov cl, 0
    int 21h                            ; 显示第二条字符串
    mov ah, 0
    int 16h
    cmp al, 27                         ; 按下ESC
    je QuitUsrProg                     ; 直接退出
QuitUsrProg:
    pop es
    popa
    retf

DataArea:
    hint_all db 'Welcome to syscall_test program, where there are several tests of system call. See the document for more details.'
    hint_all_len equ $-hint_all

    hint0 db 'Test of ah=00h is running. press ENTER to continue, or ESC to quit.'
    hint1 db 'Test of ah=01h is running. press ENTER to continue, or ESC to quit.'
    hint2 db 'Test of ah=02h is running. press ENTER to continue, or ESC to quit.'
    hint3 db 'Test of ah=03h is running. press ENTER to continue, or ESC to quit.'
    hint4 db 'Test of ah=04h is running. press ENTER to continue, or ESC to quit.'
    hint5 db 'Test of ah=05h is running. press ENTER to continue, or ESC to quit.'
    hint_len equ ($-hint5)

    upper_lower db 'AbCdEfGhIjKlMn', 0 ; 字符串以'\0'结尾

    test_message1 db 'This is a test message,'
    test_message2 db 'printed using `ah=05h` and `int 21h`.'