BITS 16
[global Timer]
Timer:
    push ax
    push ds
    push gs
    push si

    mov ax,cs
    mov ds,ax                   ; DS = CS
    mov	ax,0B800h               ; 文本窗口显存起始地址
    mov	gs,ax                   ; GS = B800h

    dec byte [count]            ; 递减计数变量
    jnz EndInt                  ; >0：跳转
    mov byte[count],delay       ; 重置计数变量=初值delay
    mov si, hotwheel            ; 风火轮首字符地址
    add si, [wheel_offset]      ; 风火轮字符偏移量
    mov al, [si]                ; al=要显示的字符
    mov ah, 0Ch                 ; ah=黑底，淡红色
    mov [gs:((80*24+79)*2)], ax ; 更新显存
    inc byte[wheel_offset]      ; 递增偏移量
    cmp byte[wheel_offset], 4   ; 检查偏移量是否超过3
    jne EndInt                  ; 没有超过，中断返回
    mov byte[wheel_offset], 0   ; 超过3了，重置为0
EndInt:
    mov al,20h                  ; AL = EOI
    out 20h,al                  ; 发送EOI到主8529A
    out 0A0h,al                 ; 发送EOI到从8529A

    pop si
    pop gs
    pop ds
    pop ax
    iret                        ; 从中断返回


DataArea:
    delay equ 3                 ; 计时器延迟计数
    count db delay              ; 计时器计数变量，初值=delay
    hotwheel db '-\|/'          ; 风火轮字符
    wheel_offset dw 0           ; 风火轮字符偏移量，初值=0