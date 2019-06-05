; @Author: Jed
; @Description: 多进程相关代码（纯汇编）
; @Date: 2019-05-01
; @LastEditTime: 2019-05-06
BITS 16
%include "macro.asm"

[global Timer]
[global timer_flag]
[global loadProcessMem]
[global current_process_id]
[global goBackToKernel]
[extern getCurrentPcb]
[extern getPcbTable]
[extern pcbSchedule]

Timer:                             ; 08h号时钟中断处理程序
    cmp word[cs:timer_flag], 0
    je QuitTimer
    push ss
    push gs
    push fs
    push es
    push ds
    push di
    push si
    push bp
    push sp
    push bx
    push dx
    push cx
    push ax

    mov ax, cs
    mov ds, ax                     ; ds=cs，因为函数中可能要用到ds
    mov es, ax                     ; es=ax，原因同上。注意此时尚未发生栈切换

    call pcbSave                   ; 将寄存器的值保存在PCB中
    add sp, 16*2                   ; 丢弃参数

CheckEscKey:
    mov ah, 01h                    ; 功能号：查询键盘缓冲区但不等待
    int 16h
    jz ContinucSchedule            ; 无键盘按下，继续调度
    mov ah, 0                      ; 功能号：查询键盘输入
    int 16h
    cmp al, 27                     ; 是否按下ESC
    jne ContinucSchedule           ; 若按下的不是ESC，继续调度

    call goBackToKernel     ; 清理PCB
    jmp PcbRestart                 ; 通过恢复返回内核

ContinucSchedule:
    call dword pcbSchedule         ; 进程调度
; pusha
; mov ax, [cs:current_process_id]
; add al, '0'
; mov bh, 0                          ; bh=页码
; mov ah, 0Eh                        ; 功能号：打印一个字符
; int 10h                            ; 打印字符
; popa

PcbRestart:                        ; 不是函数
    call dword getCurrentPcb
    mov si, ax
    mov ax, [cs:si+0]
    mov cx, [cs:si+2]
    mov dx, [cs:si+4]
    mov bx, [cs:si+6]
    mov sp, [cs:si+8]
    mov bp, [cs:si+10]
    mov di, [cs:si+14]
    mov ds, [cs:si+16]
    mov es, [cs:si+18]
    mov fs, [cs:si+20]
    mov gs, [cs:si+22]
    mov ss, [cs:si+24]
    add sp, 11*2                   ; 恢复正确的sp
    push word[cs:si+30]            ; 新进程flags
    push word[cs:si+28]            ; 新进程cs
    push word[cs:si+26]            ; 新进程ip
    push word[cs:si+12]
    pop si                         ; 恢复si

QuitTimer:
    push ax
    mov al, 20h
    out 20h, al
    out 0A0h, al
    pop ax
    iret

    timer_flag dw 0
    current_process_id dw 0

pcbSave:                           ; 函数：现场保护
    pusha
    mov bp, sp
    add bp, 16+2                   ; 参数首地址

    call dword getCurrentPcb
    mov di, ax


    mov ax, [bp]
    mov [cs:di], ax
    mov ax, [bp+2]
    mov [cs:di+2], ax
    mov ax, [bp+4]
    mov [cs:di+4], ax
    mov ax, [bp+6]
    mov [cs:di+6], ax
    mov ax, [bp+8]
    mov [cs:di+8], ax
    mov ax, [bp+10]
    mov [cs:di+10], ax
    mov ax, [bp+12]
    mov [cs:di+12], ax
    mov ax, [bp+14]
    mov [cs:di+14], ax
    mov ax, [bp+16]
    mov [cs:di+16], ax
    mov ax, [bp+18]
    mov [cs:di+18], ax
    mov ax, [bp+20]
    mov [cs:di+20], ax
    mov ax, [bp+22]
    mov [cs:di+22], ax
    mov ax, [bp+24]
    mov [cs:di+24], ax
    mov ax, [bp+26]
    mov [cs:di+26], ax
    mov ax, [bp+28]
    mov [cs:di+28], ax
    mov ax, [bp+30]
    mov [cs:di+30], ax

    popa
    ret


loadProcessMem:                    ; 函数：将某个用户程序加载入内存并初始化其PCB
    pusha
    mov bp, sp
    add bp, 16+4                   ; 参数地址
    LOAD_TO_MEM [bp+12], [bp], [bp+4], [bp+8], [bp+16], [bp+20]

    call dword getPcbTable
    mov si, ax
    mov ax, 34
    mul word[bp+24]                ; progid_to_run
    add si, ax

    mov ax, [bp+24]                ; ax=progid_to_run
    mov byte[cs:si+32], al         ; id
    mov ax, [bp+16]                ; ax=用户程序的段值
    mov word[cs:si+8], 0FE00h      ; sp
    mov word[cs:si+16], ax         ; ds
    mov word[cs:si+18], ax         ; es
    mov word[cs:si+20], ax         ; fs
    mov word[cs:si+24], ax         ; ss
    mov word[cs:si+28], ax         ; cs
    mov word[cs:si+30], 512        ; flags
    mov byte[cs:si+33], 1          ; state设其状态为就绪态

    popa
    retf

goBackToKernel:
    push cx
    push si
    mov cx, 7                      ; 共8个PCB
    call dword getPcbTable
    mov si, ax
    add si, 34                     ; 从pcb_table[1]开始
    loop1:
        mov word[cs:si+0], 0       ; ax
        mov word[cs:si+2], 0       ; cx
        mov word[cs:si+4], 0       ; dx
        mov word[cs:si+6], 0       ; bx
        mov word[cs:si+8], 0FE00h  ; sp
        mov word[cs:si+10], 0      ; bp
        mov word[cs:si+12], 0      ; si
        mov word[cs:si+14], 0      ; di
        mov word[cs:si+16], 0      ; ds
        mov word[cs:si+18], 0      ; es
        mov word[cs:si+20], 0      ; fs
        mov word[cs:si+22], 0B800h ; gs
        mov word[cs:si+24], 0      ; ss
        mov word[cs:si+26], 0      ; ip
        mov word[cs:si+28], 0      ; cs
        mov word[cs:si+30], 512    ; flags
        mov byte[cs:si+32], 0      ; id
        mov byte[cs:si+33], 0      ; state=新建态
        add si, 34                 ; si指向下一个PCB
        loop loop1
    mov word[cs:current_process_id], 0
    mov word[cs:timer_flag], 0     ; 禁止时钟中断处理多进程
    pop si
    pop cx
    ret


[global copyStack]
copyStack:
    pusha
    push ds
    push es

    mov ax, word[to_seg]           ; 子进程 ss
    mov es,ax
    mov di, 0
    mov ax, word[from_seg]         ; 父进程 ss
    mov ds, ax
    mov si, 0
    mov cx, word[stack_length]     ; 栈的大小
    cld
    rep movsw                      ; ds:si->es:di

    pop es
    pop ds
    popa
    retf

    
[global stack_length]
[global from_seg]
[global to_seg]
stack_length dw 0
from_seg dw 0
to_seg dw 0

[global sys_fork]
[extern do_fork]
sys_fork:
    push ss
    push gs
    push fs
    push es
    push ds
    push di
    push si
    push bp
    push sp
    push bx
    push dx
    push cx
    push ax
    mov ax, cs
    mov ds, ax                     ; ds=cs，因为函数中可能要用到ds
    mov es, ax                     ; es=ax，原因同上。注意此时尚未发生栈切换
    call pcbSave                   ; 将寄存器的值保存在PCB中
    add sp, 16*2                   ; 丢弃参数
    call dword do_fork

PcbRestart2:                       ; 不是函数
    call dword getCurrentPcb
    mov si, ax
    mov ax, [cs:si+0]
    mov cx, [cs:si+2]
    mov dx, [cs:si+4]
    mov bx, [cs:si+6]
    mov sp, [cs:si+8]
    mov bp, [cs:si+10]
    mov di, [cs:si+14]
    mov ds, [cs:si+16]
    mov es, [cs:si+18]
    mov fs, [cs:si+20]
    mov gs, [cs:si+22]
    mov ss, [cs:si+24]
    add sp, 11*2                   ; 恢复正确的sp
    push word[cs:si+30]            ; 新进程flags
    push word[cs:si+28]            ; 新进程cs
    push word[cs:si+26]            ; 新进程ip
    push word[cs:si+12]
    pop si                         ; 恢复si

    iret                           ; 退出sys_fork

[global sys_wait]
[extern do_wait]
sys_wait:
    push ss
    push gs
    push fs
    push es
    push ds
    push di
    push si
    push bp
    push sp
    push bx
    push dx
    push cx
    push ax
    mov ax, cs
    mov ds, ax                     ; ds=cs，因为函数中可能要用到ds
    mov es, ax                     ; es=ax，原因同上。注意此时尚未发生栈切换
    call pcbSave                   ; 将寄存器的值保存在PCB中
    add sp, 16*2                   ; 丢弃参数
    call dword do_wait

PcbRestart3:                       ; 不是函数
    call dword getCurrentPcb
    mov si, ax
    mov ax, [cs:si+0]
    mov cx, [cs:si+2]
    mov dx, [cs:si+4]
    mov bx, [cs:si+6]
    mov sp, [cs:si+8]
    mov bp, [cs:si+10]
    mov di, [cs:si+14]
    mov ds, [cs:si+16]
    mov es, [cs:si+18]
    mov fs, [cs:si+20]
    mov gs, [cs:si+22]
    mov ss, [cs:si+24]
    add sp, 11*2                   ; 恢复正确的sp
    push word[cs:si+30]            ; 新进程flags
    push word[cs:si+28]            ; 新进程cs
    push word[cs:si+26]            ; 新进程ip
    push word[cs:si+12]
    pop si                         ; 恢复si

    iret                           ; 退出sys_wait


[global sys_exit]
[extern do_exit]
sys_exit:
    push ss
    push gs
    push fs
    push es
    push ds
    push di
    push si
    push bp
    push sp
    push bx
    push dx
    push cx
    push ax
    mov ax, cs
    mov ds, ax                     ; ds=cs，因为函数中可能要用到ds
    mov es, ax                     ; es=ax，原因同上。注意此时尚未发生栈切换
    call pcbSave                   ; 将寄存器的值保存在PCB中
    add sp, 16*2                   ; 丢弃参数
    call dword do_exit

PcbRestart4:                       ; 不是函数
    call dword getCurrentPcb
    mov si, ax
    mov ax, [cs:si+0]
    mov cx, [cs:si+2]
    mov dx, [cs:si+4]
    mov bx, [cs:si+6]
    mov sp, [cs:si+8]
    mov bp, [cs:si+10]
    mov di, [cs:si+14]
    mov ds, [cs:si+16]
    mov es, [cs:si+18]
    mov fs, [cs:si+20]
    mov gs, [cs:si+22]
    mov ss, [cs:si+24]
    add sp, 11*2                   ; 恢复正确的sp
    push word[cs:si+30]            ; 新进程flags
    push word[cs:si+28]            ; 新进程cs
    push word[cs:si+26]            ; 新进程ip
    push word[cs:si+12]
    pop si                         ; 恢复si

    iret                           ; 退出sys_exit