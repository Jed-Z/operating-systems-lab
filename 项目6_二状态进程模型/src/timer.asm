BITS 16
[global Timer]
[extern PCBsave]
[extern PCBscheduler]
[extern getCurrentRegImg]
[extern special]
[extern Program_Num]

Timer:                    ; debug:sp=346h
    cmp word[cs:Program_Num], 0
    jnz Save
    jmp No_Progress

Save:
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

    mov ax,cs
    mov ds, ax
    mov es, ax

    call dword PCBsave
    ; add sp, 4*16

    call dword PCBscheduler

Pre:
    mov ax, cs
    mov ds, ax
    mov es, ax

    call dword getCurrentRegImg
    mov bp, ax

    mov ss, [ds:bp+0]
    mov sp, [ds:bp+16]

    cmp word[ds:bp+32],0
    jnz No_First_Time

Restart:
    call dword special

    push word[ds:bp+30]   ; flags
    push word[ds:bp+28]   ; cs
    push word[ds:bp+26]   ; ip

    push word[ds:bp+2]
    push word[ds:bp+4]
    push word[ds:bp+6]
    push word[ds:bp+8]
    push word[ds:bp+10]
    push word[ds:bp+12]
    push word[ds:bp+14]
    push word[ds:bp+18]
    push word[ds:bp+20]
    push word[ds:bp+22]
    push word[ds:bp+24]

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
	add sp,16*2
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