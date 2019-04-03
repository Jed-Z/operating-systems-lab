; @Author: Jed
; @Description: int 33h/34h/35h/36h的中断处理程序
; @Date: 2019-03-28
; @LastEditTime: 2019-04-03

Int33~36:
    push ax
    push si
    push ds
    push gs

    mov ax,cs
    mov ds,ax                 ; DS = CS
    mov	ax,0B800h             ; 文本窗口显存起始地址
    mov	gs,ax                 ; GS = B800h
    mov ax, [start_row]       ; ax=start_row
    mov ah, 2*80              ; ah=2*80
    mul ah                    ; ax=start_row * 2 * 80
    mov si, ax                ; si初始化为起始位置指针
disploop:
    mov al, [temp_char]       ; 要显示的字符
    mov [gs:si], al           ; 显示字符
    inc si                    ; 递增指针
    mov ah, [temp_color]      ; 字符颜色属性
    mov [gs:si], ah           ; 显示颜色属性
    inc si                    ; 递增指针
    add byte[temp_color], 11h ; 改变颜色
    call Delay                ; 延时

    mov ah, 01h               ; 功能号：查询键盘缓冲区但不等待
    int 16h
    jz NoEsc                  ; 无键盘按下，继续
    mov ah, 0                 ; 功能号：查询键盘输入
    int 16h
    cmp al, 27                ; 是否按下ESC
    je QuitInt                ; 若按下ESC，退出用户程序
NoEsc:
    mov ax, [end_row]         ; al=end_row，ah实际上无用
    mov ah, 2*80
    mul ah                    ; ax=end_row * 2 * 80
    add ax, [start_row]       ; ax=start_row + end_row*2*80
    cmp si, ax
    jne disploop              ; 范围全部显示完，中断返回

QuitInt:
    pop gs
    pop ds
    pop si
    pop ax
    iret                      ; 中断返回

Delay:                        ; 延迟一段时间
    push ax
    push cx
    mov ax, 100
delay_outer:
    mov cx, 50000
delay_inner:
    loop delay_inner
    dec ax
    cmp ax, 0
    jne delay_outer
    pop cx
    pop ax
    ret

DataArea:
    start_row dw 0
    end_row dw 0
    temp_color db 0
    temp_char db ' '