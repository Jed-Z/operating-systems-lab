BITS 16
[global Timer]
[extern PCBsave]
[extern PCBscheduler]
[extern getCurrentRegImg]

[global process_timer]

[extern debug_printreg]
[extern debug_printpcb]
%macro debug 0
pusha                     ; sp -= 16bytes
    push 0
    push sp
    push 0
    push cs
    push 0
    push ss
    push 0
    push gs
    push 0
    push fs
    push 0
    push es
    push 0
    push ds
    push 0
    push di
    push 0
    push si
    push 0
    push bp
    push 0
    push dx
    push 0
    push cx
    push 0
    push bx
    push 0
    push ax
    call dword debug_printreg
    add sp, 4*14
popa
%endmacro

Timer:                    ; debug:sp=346h
    cli
    cmp byte[cs:process_timer], 0
    je EndTimer           ; 未设置进程计时器

    pop word[cs:tempip]
    pop word[cs:tempcs]
    pop word[cs:temppsw]
    push 0
    push word[cs:temppsw] ; 原进程的psw
    push 0
    push word[cs:tempcs]  ; 原进程的cs
    push 0
    push word[cs:tempip]  ; 原进程的ip
    push 0
    push sp
    push 0
    push ss
    push 0
    push gs
    push 0
    push fs
    push 0
    push es
    push 0
    push ds
    push 0
    push di
    push 0
    push si
    push 0
    push bp
    push 0
    push dx
    push 0
    push cx
    push 0
    push bx
    push 0
    push ax
    call dword PCBsave
    add sp, 4*16          ; 丢弃参数

    call dword PCBscheduler
    ; destroy reg begin
    ; destroy end

    call dword getCurrentRegImg
    mov si, ax            ; si指向即将运行进程的PCB

    mov ss, word[cs:si]   ; 栈切换
    mov sp, word[cs:si+2*7]
    add sp, 0Eh           ; 使sp指向正确的位置
    mov ax, word[cs:si+2*12]
    mov bx, word[ds:si+2*11]
    mov cx, word[ds:si+2*10]
    mov dx, word[ds:si+2*9]
    mov bp, word[ds:si+2*8]
    mov di, word[ds:si+2*5]
    mov ds, word[ds:si+2*4]
    mov es, word[ds:si+2*3]
    mov fs, word[ds:si+2*2]
    mov gs, word[ds:si+2*1]
    push word[cs:si+2*15] ; 下一进程的psw
    push word[cs:si+2*14] ; 下一进程的cs
    push word[cs:si+2*13] ; 下一进程的ip
    mov si, word[ds:si+2*6]

EndTimer:
    push ax
    mov al, 20h           ; AL = EOI
    out 20h, al           ; 发送EOI到主8529A
    out 0A0h, al          ; 发送EOI到从8529A
    pop ax
    sti
    iret                  ; 从中断返回

    temppsw dw 0
    tempcs dw 0
    tempip dw 0
    process_timer db 0


debugfuck:
mov ax, 2001H
mov dx, 1004H
out dx, ax