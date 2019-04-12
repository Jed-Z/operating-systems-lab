; @Author: Jed
; @Description: 键盘中断处理程序，按下任意按键时显示"OUCH! OUCH!"
; @Date: 2019-04-03
; @LastEditTime: 2019-04-12

IntOuch:
    pusha
    push ds
    push es

    mov	ax, cs           ; 置其他段寄存器值与CS相同
    mov	ds, ax           ; 数据段
    mov	bp, ouch_msg     ; BP=当前串的偏移地址
    mov	ax, ds           ; ES:BP = 串地址
    mov	es, ax           ; 置ES=DS
    mov	cx, ouch_msg_len ; CX = 串长
    mov	ax, 1300h        ; AH = 13h（功能号）、AL = 01h（光标不动）
    mov	bx, 0007h        ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, 20           ; 行号=0
    mov	dl, 40           ; 列号=0
    int	10h              ; BIOS的10h功能：显示一行字符

    call Delay

    mov	ax, cs           ; 置其他段寄存器值与CS相同
    mov	ds, ax           ; 数据段
    mov	bp, ouch_clear   ; BP=当前串的偏移地址
    mov	ax, ds           ; ES:BP = 串地址
    mov	es, ax           ; 置ES=DS
    mov	cx, ouch_msg_len ; CX = 串长
    mov	ax, 1300h        ; AH = 13h（功能号）、AL = 01h（光标不动）
    mov	bx, 0007h        ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, 20           ; 行号=0
    mov	dl, 40           ; 列号=0
    int	10h              ; BIOS的10h功能：显示一行字符

    int 39h              ; 原来的BIOS int 09h

    mov al,20h           ; AL = EOI
    out 20h,al           ; 发送EOI到主8529A
    out 0A0h,al          ; 发送EOI到从8529A

    pop es
    pop ds
    popa
    iret                 ; 从中断返回

Delay:                   ; 延迟一段时间
    push ax
    push cx
    mov ax, 580
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


    ouch_msg db 'OUCH! OUCH!'
    ouch_msg_len equ $-ouch_msg
    ouch_clear db '           '