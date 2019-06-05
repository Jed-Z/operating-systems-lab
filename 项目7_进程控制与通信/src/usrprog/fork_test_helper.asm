BITS 16
%include "../macro.asm"
[global _start]

_start:
    mov ax, 0003h
    int 10h         ; 中断调用，清屏
    PRINTLN welcome ; 打印欢迎信息

    int 22h
    cmp ax, 0
    jl ForkFailure
    cmp ax, 0
    jg ForkParent
    cmp ax, 0
    je ForkSon

    jmp continue


ForkFailure:
    PRINTLN error_fork
    jmp continue

ForkParent:
    PRINTLN parent_say
    jmp continue

ForkSon:
    PRINTLN son_say
    jmp continue


continue:
    PRINTLN finishbye
    jmp $

countLetter:
    mov ax, 8
    ret

DataArea:
    the_str db '129djwqhdsajd128dw9i39ie93i8494urjoiew98kdkd', 0
    letter_count dw 0

    welcome db 'This is the `fork_test` user programme.', 0Dh, 0Ah, 0
    finishbye db 'The fork test is finished. Press ESC to quit.', 0Dh, 0Ah, 0
    parent_say db 'This is PARENT', 0Dh, 0Ah, 0
    son_say db 'This is SON', 0Dh, 0Ah, 0
    error_fork db '[-] Error in fork!', 0Dh, 0Ah, 0
    result_1 db 'Letter number = ', 0
