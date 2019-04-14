; @Author: Jed
; @Description: 系统调用函数库
; @Date: 2019-04-12
; @LastEditTime: 2019-04-12

BITS 16
[global sys_clearScreen]
[global sys_powerOff]
[global sys_reBoot]
[global sys_putchar]
[global sys_print]
[global sys_getch]
[global sys_getDate]
[global sys_getTime]

sys_clearScreen:     ; 清屏
    push ax
    mov ax, 0003h
    int 10h          ; 中断调用，清屏
    pop ax
    ret

sys_powerOff:        ; 强制关机
    mov ax, 2001H
    mov dx, 1004H
    out dx, ax
    ret              ; 为了代码统一性

sys_reBoot:          ; 重新启动系统
    int 19h
    ret              ; 为了代码统一性

sys_putchar:         ; 显示一个字符；参数：al=字符，bl=颜色
    pusha
    push ds
    push es
    mov cx, cs       ; 由于参数在al中，此处不能用ax
    mov ds, cx       ; ds = cs
    mov es, cx       ; es = cs
    mov [tempc], al  ; 保存参数：字符
    mov [tempa], bl  ; 保存参数：颜色
    mov bx, 0        ; 页号=0
    mov ah, 03h      ; 功能号：获取光标位置
    int 10h          ; dh=行，dl=列
    mov bp, tempc
    mov cx, 1        ; 显示1个字符
    mov ax, 1301h    ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov bh, 0        ; 页号
    mov bl, [tempa]
    int 10h          ; 显示字符串（1个字符）
    pop es
    pop ds
    popa
    ret
    tempc db 0       ; 字符
    tempa db 07h     ; 字符颜色

sys_print:           ; 显示以'\0'结尾的字符串；参数：ds:dx=串首地址，bl=颜色
    pusha
    mov ah, 03h      ; 系统调用功能号（显示一个字符）
    mov si, dx
    loop_putchar:
        mov al, [si] ; al=字符
        cmp al, 0
        je print_end
        int 21h      ; 系统调用
        inc si       ; 指向下一个字符
        jmp loop_putchar
print_end:
    popa
    ret

sys_getch:           ; 读入一个字符（无回显）到al
    mov ah, 0        ; 功能号
    int 16h          ; 读取字符，al=读到的字符
    ret

[extern bcd2decimal]
sys_getDate:         ; 获取当前日期；返回：cx=年，dh=月，dl=日
    mov al, 9
    out 70h, al
    in al, 71h       ; al=年
    mov ah, 0
    push ax          ; 传递参数
    call dword bcd2decimal
    mov cx, ax
    pop ax           ; 丢弃参数

    mov al, 8
    out 70h, al
    in al, 71h       ; al=月
    mov ah, 0
    push ax          ; 传递参数
    call dword bcd2decimal
    mov dh, al
    pop ax           ; 丢弃参数

    mov al, 7
    out 70h, al
    in al, 71h       ; al=日
    mov ah, 0
    push ax          ; 传递参数
    call dword bcd2decimal
    mov dl, al
    pop ax           ; 丢弃参数
    ret


sys_getTime:         ; 获取当前时间；返回：ch=时，cl=分，dh=秒
    mov al, 4
    out 70h, al
    in al, 71h       ; al=时
    mov ah, 0
    push ax          ; 传递参数
    call dword bcd2decimal
    mov ch, al
    pop ax           ; 丢弃参数

    mov al, 2
    out 70h, al
    in al, 71h       ; al=分
    mov ah, 0
    push ax          ; 传递参数
    call dword bcd2decimal
    mov cl, al
    pop ax           ; 丢弃参数

    mov al, 0
    out 70h, al
    in al, 71h       ; al=秒
    mov ah, 0
    push ax          ; 传递参数
    call dword bcd2decimal
    mov dh, al
    pop ax           ; 丢弃参数
    ret