%include "../macro.asm"
org offset_syscalltest

Start:
    mov ax, 0003h
    int 10h             ; 清屏

    PRINT_IN_POS hint_all, hint_all_len, 0, 0
    PRINT_IN_POS hint0, hint_len, 2, 0
    mov ah, 00h
    int 21h

    Keyboard:
    mov ah, 0
    int 16h
    cmp al, 27          ; 按下ESC
    je QuitUsrProg      ; 直接退出

QuitUsrProg:
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
    test_message db 'This is a test message shown in (20, 50).'
    test_message_len equ ($-test_message)