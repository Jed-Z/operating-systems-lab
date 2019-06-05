BITS 16
%include "../macro.asm"
[global _start]

_start:
    mov ax, 0003h
    int 10h                    ; 清屏
    PRINTLN welcome            ; 打印欢迎信息

    int 22h                    ; 调用fork()，ax=fork的结果
    cmp ax, 0
    jl ForkFailure
    cmp ax, 0
    jg ForkParent
    cmp ax, 0
    je ForkSon

    jmp QuitUsrProg


ForkFailure:                   ; ------ fork失败 ------
    PRINTLN error_fork
    jmp QuitUsrProg


ForkParent:                    ; ------ 父进程 ------
    PRINTLN parent_say
    int 23h                    ; 调用wait()

    PRINTLN result_1
    PRINTLN the_str
    PRINTLN result_2
    call printLetterCount
    PRINTLN finishbye
    int 24h                    ; 调用exit()，退出父进程

    jmp QuitUsrProg

ForkSon:                       ; ------ 子进程 ------
    PRINTLN son_say
    call countLetter           ; 统计字母个数
    int 24h                    ; 调用exit()，退出子进程
    jmp QuitUsrProg



QuitUsrProg:
    jmp $

countLetter:                   ; 函数：统计the_str中的字母个数并保存在letter_count中
    pusha
    mov si, the_str
    loopCheck:
        cmp byte[si], 0
        je quitCountLetter
        cmp byte[si], 'a'
        jl loopContinue
        cmp byte[si], 'z'
        jg loopContinue
        inc word[letter_count] ; 如果是小写字母则递增
    loopContinue:
        inc si
        jmp loopCheck
    quitCountLetter:
    popa
    ret

printLetterCount:              ; 函数：打印letter_count（默认为两位数）
    pusha
    mov ax, [letter_count]
    mov bl, 10
    div bl                     ; al = ax/ah, ah = ax%ah
    add al, '0'                ; 十位数的ASCII
    add ah, '0'                ; 个位数的ASCII
    PUTCHAR al                 ; 打印十位数
    PUTCHAR ah                 ; 打印个位数
    popa
    ret

DataArea:
    the_str db '129djwqhdsajd128dw9i39ie93i8494urjoiew98kdkd', 0
    letter_count dw 0          ; 用于存放字母个数的全局变量

    welcome db 'This is the `fork_test` user programme.', 0Dh, 0Ah, 0Ah, 0Ah, 0
    error_fork db '[-] Error in fork! Press ESC to quit.', 0Dh, 0Ah, 0
    parent_say db '[+] Parent process entered.', 0Dh, 0Ah, 0
    son_say db '[+] Son process entered.', 0Dh, 0Ah, 0
    result_1 db 0Dh, 0Ah, 'The string is: ', 0
    result_2 db  0Dh, 0Ah, 'Letter number is: ', 0
    finishbye db  0Dh, 0Ah, 0Dh, 0Ah,
        db '[+] The fork test is finished! Press ESC to quit.', 0Dh, 0Ah, 0