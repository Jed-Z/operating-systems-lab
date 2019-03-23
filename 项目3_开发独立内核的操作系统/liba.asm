; @Author: Jed
; @Description: 汇编库；以nasm汇编格式编写的库文件，包含了多个函数，可供asm或C调用
; @Date: 2019-03-21
; @LastEditTime: 2019-03-23

BITS 16
[global clearScreen]
[global printInPos]
[global putchar]
[global getch]

[extern tempc]

clearScreen:        ; 函数：清屏
    push ax
    mov ax, 0003h
    int 10h         ; 中断调用，清屏
    pop ax
    retf

printInPos:         ; 函数：在指定位置显示字符串
    pusha           ; 保护现场（压栈16字节）
    mov si, sp      ; 由于代码中要用到bp，因此使用si来为参数寻址
    add si, 16+4    ; 首个参数的地址
    mov	ax, cs      ; 置其他段寄存器值与CS相同
    mov	ds, ax      ; 数据段
    mov	bp, [si]    ; BP=当前串的偏移地址
    mov	ax, ds      ; ES:BP = 串地址
    mov	es, ax      ; 置ES=DS
    mov	cx, [si+4]  ; CX = 串长（=9）
    mov	ax, 1301h   ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov	bx, 0007h   ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, [si+8]  ; 行号=0
    mov	dl, [si+12] ; 列号=0
    int	10h         ; BIOS的10h功能：显示一行字符
    popa            ; 恢复现场（出栈16字节）
    retf

putchar:            ; 函数：在光标处打印一个字符
    pusha
    mov bp, sp
    add bp, 16+4    ; 参数地址
    mov al, [bp]    ; al=要打印的字符
    mov bh, 0       ; bh=页码
    mov ah, 0Eh     ; 功能号：打印一个字符
    int 10h         ; 打印字符
    popa
    retf

getch:            ; 函数：读取一个字符（无回显）
    push ax
    mov ah, 0       ; 功能号
    int 16h         ; 读取字符，al=读到的字符
    mov [tempc], al
    pop ax
    retf

    ; readToBuf:          ; 函数：读取键盘输入到缓冲区buf中
    ; pusha
    ; mov cx, 15
    ; lea bx, [buf]
    ; loop1:
    ; mov ah, 0
    ; int 16h
    ; cmp al, 0Dh     ; 是否按下回车
    ; je done1        ; 若按下回车，则输入过程结束
    ; mov ah, 0Eh     ; 功能号：电传打字机显示字符
    ; int 10h         ; 回显刚刚按下的字符
    ; mov [bx], al    ; 存入buf
    ; inc bx          ; 递增buf指针
    ; dec cx          ; 递减计数
    ; jnz loop1       ; 计数不为0，可以继续输入
    ; done1:

    ; popa
    ; retf