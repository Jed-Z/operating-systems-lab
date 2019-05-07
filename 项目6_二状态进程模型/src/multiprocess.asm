; @Author: Jed
; @Description: 多进程相关代码（纯汇编）
; @Date: 2019-05-01
; @LastEditTime: 2019-05-06
BITS 16
%include "macro.asm"

[global Timer]
[global timer_flag]
[global loadProcessMem]

Timer:                        ; 08h号时钟中断处理程序
    cli                       ; 关中断，不允许时钟中断嵌套
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
    call pcbSave              ; 将寄存器的值保存在PCB中
    add sp, 16+2              ; 丢弃参数

    call pcbSchedule          ; 进程调度

pcbRestart:                   ; 不是函数
    mov si, pcb_table
    mov ax, 34
    mul word[cs:current_process_id]
    add si, ax                ; si指向调度后的PCB的首地址

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
    add sp, 11*2              ; 恢复正确的sp

    push word[cs:si+30]       ; 新进程flags
    push word[cs:si+28]       ; 新进程cs
    push word[cs:si+26]       ; 新进程ip

    push word[cs:si+12]
    pop si                    ; 恢复si

QuitTimer:
    push ax
    mov al, 20h
    out 20h, al
    out 0A0h, al
    pop ax
    sti                       ; 开中断
    iret

    timer_flag dw 0
    current_process_id dw 0

%macro ProcessControlBlock 1
    dw 0                      ; ax，偏移量=+0
    dw 0                      ; cx，偏移量=+2
    dw 0                      ; dx，偏移量=+4
    dw 0                      ; bx，偏移量=+6
    dw 0FE00h                 ; sp，偏移量=+8
    dw 0                      ; bp，偏移量=+10
    dw 0                      ; si，偏移量=+12
    dw 0                      ; di，偏移量=+14
    dw %1                     ; ds，偏移量=+16
    dw %1                     ; es，偏移量=+18
    dw %1                     ; fs，偏移量=+20
    dw 0B800h                 ; gs，偏移量=+22
    dw %1                     ; ss，偏移量=+24
    dw 0                      ; ip，偏移量=+26
    dw %1                     ; cs，偏移量=+28
    dw 512                    ; flags，偏移量=+30
    db 0                      ; id，进程ID，偏移量=+32
    db 0                      ; state，{0:新建态; 1:就绪态; 2:运行态}，偏移量=+33
%endmacro

pcb_table:                    ; 定义PCB表
pcb_0: ProcessControlBlock 0  ; 存放内核寄存器的值
pcb_1: ProcessControlBlock 1000h
pcb_2: ProcessControlBlock 2000h
pcb_3: ProcessControlBlock 3000h
pcb_4: ProcessControlBlock 4000h
pcb_5: ProcessControlBlock 0
pcb_6: ProcessControlBlock 0
pcb_7: ProcessControlBlock 0

pcbSave:                      ; 函数：现场保护
    pusha
    mov bp, sp
    add bp, 16+2              ; 参数首地址
    mov di, pcb_table

    mov ax, 34
    mul word[cs:current_process_id]
    add di, ax                ; di指向当前PCB的首地址

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

pcbSchedule:                  ; 函数：进程调度
    pusha
    mov si, pcb_table
    mov ax, 34
    mul word[cs:current_process_id]
    add si, ax                ; si指向当前PCB的首地址
    mov byte[cs:si+33], 1     ; 将当前进程设置为就绪态

    try_next_pcb:             ; 循环地寻找下一个处于就绪态的进程
        inc word[cs:current_process_id]
        add si, 34            ; si指向下一PCB的首地址
        cmp word[cs:current_process_id], 7
        jna pcb_not_exceed    ; 若id递增到8，则将其恢复为1
        mov word[cs:current_process_id], 1
        mov si, pcb_table+34  ; si指向1号进程的PCB的首地址

    pcb_not_exceed:
        cmp byte[cs:si+33], 1 ; 判断下一进程是否处于就绪态
        jne try_next_pcb      ; 不是就绪态，则尝试下一个进程
        mov byte[cs:si+33], 2 ; 是就绪态，则设置为运行态。调度完毕
    popa
    ret


loadProcessMem:               ; 函数：将某个用户程序加载入内存并初始化其PCB
    pusha
    mov bp, sp
    add bp, 16+4              ; 参数地址
    LOAD_TO_MEM [bp+12], [bp], [bp+4], [bp+8], [bp+16], [bp+20]

    mov si, pcb_table
    mov ax, 34
    mul word[bp+24]           ; progid_to_run
    add si, ax                ; si指向新进程的PCB
    mov byte[cs:si+33], 1     ; 设其状态为就绪态
    popa
    retf