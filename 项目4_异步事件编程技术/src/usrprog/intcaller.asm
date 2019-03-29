%include "header.asm"
org offset_intcaller

Start:
    WRITE_INT_VECTOR 33, Int33

Keyboard:
    mov ah, 0
    int 16h
    cmp al, '3'       ; 按下3
    je callInt33      ; 执行int 33
    cmp al, '4'       ; 按下4
    je callInt34      ; 执行int 34
    cmp al, '5'       ; 按下5
    je callInt35      ; 执行int 35
    cmp al, '6'       ; 按下6
    je callInt36      ; 执行int 36
    cmp al, 27        ; 按下ESC
    je QuitUsrProg
    jmp Keyboard      ; 无效按键，重新等待用户按键

callInt33:
    int 33
    jmp QuitUsrProg
callInt34:
    int 34
    jmp QuitUsrProg
callInt35:
    int 35
    jmp QuitUsrProg
callInt36:
    int 36
    jmp QuitUsrProg

QuitUsrProg:
    retf

Footer:
    hint_msg1 db 'This is the Interrupt Caller Programme.'
    hint_msg1_len db $-hint_msg1
    hint_msg2 db 'Press 3/4/5/6 to call int 33/34/35/36.'
    hint_msg2_len db $-hint_msg2
    %include "interrupt/int33.asm"