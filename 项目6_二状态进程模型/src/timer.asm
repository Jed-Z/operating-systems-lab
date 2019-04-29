BITS 16
[global Timer]
[extern PCBsave]
[extern PCBscheduler]
[extern getCurrentRegImg]
[extern special]
[extern Program_Num]

; debug
extern debug_printreg
extern debug_printpcb
; debugend

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

Timer:
    cmp word[cs:Program_Num], 0
    je No_Progress

Save:
; inc word[Finite]
; cmp word[Finite],1600
; jnz Lee
; mov word[Finite],0
; mov word[Program_Num],0
; jmp Pre

Lee:
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
    push ss
    push 0
    push ax
    push 0
    push bx
    push 0
    push cx
    push 0
    push dx
    push 0
    push sp
    push 0
    push bp
    push 0
    push si
    push 0
    push di
    push 0
    push ds
    push 0
    push es
    push 0
    push fs
    push 0
    push gs


    call dword PCBsave
    ; add sp, 4*16
    call dword PCBscheduler

Pre:
    mov ax, cs
    mov es, ax

    call dword getCurrentRegImg
    mov bp, ax

    mov ss, [cs:bp+0]
    mov sp, [cs:bp+16]

    cmp word[cs:bp+32],0  ; state == 0 ?
    jnz No_First_Time

Restart:
    call dword special    ; if P_NEW: then set to P_RUNNING

    push word[cs:bp+2*15] ; flags
    push word[cs:bp+2*14] ; cs
    push word[cs:bp+2*13] ; ip

    push word[cs:bp+2]
    push word[cs:bp+4]
    push word[cs:bp+6]
    push word[cs:bp+8]
    push word[cs:bp+10]
    push word[cs:bp+12]
    push word[cs:bp+14]
    push word[cs:bp+18]
    push word[cs:bp+20]
    push word[cs:bp+22]
    push word[cs:bp+24]
    pop ax
    pop cx
    pop dx
    pop bx
    pop bp
    pop si
    pop di
    pop ds
    pop es
    pop fs
    pop gs

    push ax
    mov al,20h
    out 20h,al
    out 0A0h,al
    pop ax
    iret

No_First_Time:
    add sp,16*4
    jmp Restart

No_Progress:
    push ax
    mov al,20h
    out 20h,al
    out 0A0h,al
    pop ax
    iret

    temppsw dw 0
    tempcs dw 0
    tempip dw 0
    Finite dw 0