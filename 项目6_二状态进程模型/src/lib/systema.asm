BITS 16
[global sys_showOuch]
[global sys_toUpper]
[global sys_toLower]
[global sys_atoi]
[global sys_itoa]
[global sys_printInPos]

sys_showOuch:
    pusha             ; 保护现场
    push ds
    push es
    mov	ax, cs        ; 置其他段寄存器值与CS相同
    mov	ds, ax        ; 数据段
    mov	bp, ouch_str  ; BP=当前串的偏移地址
    mov	ax, ds        ; ES:BP = 串地址
    mov	es, ax        ; 置ES=DS
    mov	cx, 4         ; CX = 串长
    mov	ax, 1301h     ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov	bx, 0038h     ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, 12        ; 行号
    mov	dl, 38        ; 列号
    int	10h           ; BIOS的10h功能：显示一行字符
    pop es
    pop ds
    popa              ; 恢复现场
    ret
    ouch_str db 'OUCH'

[extern toupper]
sys_toUpper:
    push es           ; 传递参数
    push dx           ; 传递参数
    call dword toupper
    pop dx            ; 丢弃参数
    pop es            ; 丢弃参数
    ret

[extern tolower]
sys_toLower:
    push es           ; 传递参数
    push dx           ; 传递参数
    call dword tolower
    pop dx            ; 丢弃参数
    pop es            ; 丢弃参数
    ret

[extern atoi]
sys_atoi:
    push es           ; 传递参数
    push dx           ; 传递参数
    call dword atoi
    pop dx            ; 丢弃参数
    pop es            ; 丢弃参数
    ret

[extern itoa_buf]
sys_itoa:
    push es           ; 传递参数buf
    push dx           ; 传递参数buf
    mov ax, 0
    push ax           ; 传递参数base
    mov ax, 10        ; 10进制
    push ax           ; 传递参数base
    mov ax, 0
    push ax           ; 传递参数val
    push bx           ; 传递参数val
    call dword itoa_buf
    pop bx            ; 丢弃参数
    pop ax            ; 丢弃参数
    pop ax            ; 丢弃参数
    pop ax            ; 丢弃参数
    pop dx            ; 丢弃参数
    pop es            ; 丢弃参数
    ret

[extern strlen]
sys_printInPos:
    pusha
    mov bp, dx        ; es:bp=串地址
    push es           ; 传递参数
    push bp           ; 传递参数
    call dword strlen ; 返回值ax=串长
    pop bp            ; 丢弃参数
    pop es            ; 丢弃参数
    mov bl, 07h       ; 颜色
    mov dh, ch        ; 行号
    mov dl, cl        ; 列号
    mov cx, ax        ; 串长
    mov bh, 0         ; 页码
    mov al, 0         ; 光标不动
    mov ah, 13h       ; BIOS功能号
    int 10h
    popa
    ret