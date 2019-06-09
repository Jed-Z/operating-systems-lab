BITS 16
%include "../macro.asm"
[global _start]

_start:
    mov ax, 0003h
    int 10h         ; 清屏
    PRINTLN welcome ; 打印欢迎信息

    int 22h         ; 调用fork()，ax=fork的结果
    cmp ax, 0
    jl ForkFailure
    cmp ax, 0
    jg ForkParent
    cmp ax, 0
    je ForkSon

    jmp QuitUsrProg


ForkFailure:
    PRINTLN error_fork
    jmp QuitUsrProg

ForkParent:         ; 父进程
    PRINTLN parent_say
    int 23h         ; 调用wait()

    PRINTLN finishbye
    int 24h         ; 调用exit()

    jmp QuitUsrProg

ForkSon:            ; 子进程
    PRINTLN son_say
    call countLetter
    int 24h         ; 调用exit()
    jmp QuitUsrProg


QuitUsrProg:
    jmp $

countLetter:
    mov word[letter_count], 8
    ret

DataArea:
    the_str db '129djwqhdsajd128dw9i39ie93i8494urjoiew98kdkd', 0
    letter_count dw 0

    welcome db 'This is the `fork_test` user programme.', 0Dh, 0Ah, 0Ah, 0Ah, 0
    finishbye db  0Ah, 'The fork test is finished. Press ESC to quit.', 0Dh, 0Ah, 0
    parent_say db 'This is PARENT', 0Dh, 0Ah, 0
    son_say db 'This is SON', 0Dh, 0Ah, 0
    error_fork db '[-] Error in fork!', 0Dh, 0Ah, 0
    result_1 db 'Letter number = ', 0
