; @Author: Jed
; @Description: 内核的汇编函数部分
; @Date: 2019-03-21
; @LastEditTime: 2019-03-23
BITS 16
%include "macro.asm"

[global clearScreen]
[global printInPos]
; [global putchar]
[global putchar_c]
[global getch]
[global powerOff]
[global getUsrProgNum]
[global getUsrProgName]
[global getUsrProgSize]
[global getUsrProgCylinder]
[global getUsrProgHead]
[global getUsrProgSector]
[global getUsrProgAddr]
[global loadAndRun]
[global getDateYear]
[global getDateMonth]
[global getDateDay]
[global getDateHour]
[global getDateMinute]
[global getDateSecond]
[global switchHotwheel]
[global syscaller]


clearScreen:                    ; 函数：清屏
    push ax
    mov ax, 0003h
    int 10h                     ; 中断调用，清屏
    pop ax
    retf


printInPos:                     ; 函数：在指定位置显示字符串
    pusha                       ; 保护现场（压栈16字节）
    mov si, sp                  ; 由于代码中要用到bp，因此使用si来为参数寻址
    add si, 16+4                ; 首个参数的地址
    mov	ax, cs                  ; 置其他段寄存器值与CS相同
    mov	ds, ax                  ; 数据段
    mov	bp, [si]                ; BP=当前串的偏移地址
    mov	ax, ds                  ; ES:BP = 串地址
    mov	es, ax                  ; 置ES=DS
    mov	cx, [si+4]              ; CX = 串长（=9）
    mov	ax, 1301h               ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov	bx, 0007h               ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, [si+8]              ; 行号=0
    mov	dl, [si+12]             ; 列号=0
    int	10h                     ; BIOS的10h功能：显示一行字符
    popa                        ; 恢复现场（出栈16字节）
    retf


    ; putchar:                   ; 函数：在光标处打印一个字符
    ; pusha
    ; mov bp, sp
    ; add bp, 16+4           ; 参数地址
    ; mov al, [bp]           ; al=要打印的字符
    ; mov bh, 0              ; bh=页码
    ; mov ah, 0Eh            ; 功能号：打印一个字符
    ; int 10h                ; 打印字符
    ; popa
    ; retf


putchar_c:                      ; 函数：在光标处打印一个彩色字符
    pusha
    push ds
    push es
    mov bx, 0                   ; 页号=0
    mov ah, 03h                 ; 功能号：获取光标位置
    int 10h                     ; dh=行，dl=列
    mov ax, cs
    mov ds, ax                  ; ds = cs
    mov es, ax                  ; es = cs
    mov bp, sp
    add bp, 20+4                ; 参数地址，es:bp指向要显示的字符
    mov cx, 1                   ; 显示1个字符
    mov ax, 1301h               ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov bh, 0                   ; 页号
    mov bl, [bp+4]              ; 颜色属性
    int 10h                     ; 显示字符串（1个字符）
    pop es
    pop ds
    popa
    retf

getch:                          ; 函数：读取一个字符到tempc（无回显）
    mov ah, 0                   ; 功能号
    int 16h                     ; 读取字符，al=读到的字符
    mov ah, 0                   ; 为返回值做准备
    retf


powerOff:                       ; 函数：强制关机
    mov ax, 2001H
    mov dx, 1004H
    out dx, ax


getUsrProgNum:
    mov al, [offset_upinfo]
    mov ah, 0
    retf


getUsrProgName:
    push bp
    push bx
    mov bp, sp
    add bp, 4+4
    mov al, [bp]                ; al=pid
    add al, -1                  ; al=pid-1
    mov bl, 24                  ; 每个用户程序的信息块大小为24字节
    mul bl                      ; ax = (pid-1) * 24
    add ax, 1                   ; ax = 1 + (pid-1) * 24
    add ax, 1                   ; 加上name在用户程序信息中的偏移
    add ax, offset_upinfo       ; 不用方括号，因为就是要访问字符串所在的地址
    pop bx
    pop bp
    retf


getUsrProgSize:
    push bp
    push bx
    mov bp, sp
    add bp, 4+4
    mov al, [bp]                ; al=pid
    add al, -1                  ; al=pid-1
    mov bl, 24                  ; 每个用户程序的信息块大小为24字节
    mul bl                      ; ax = (pid-1) * 24
    add ax, 1                   ; ax = 1 + (pid-1) * 24
    add ax, 17                  ; 加上size在用户程序信息中的偏移
    mov bx, ax
    add bx, offset_upinfo
    mov ax, [bx]
    pop bx
    pop bp
    retf


getUsrProgCylinder:
    push bp
    push bx
    mov bp, sp
    add bp, 4+4
    mov al, [bp]                ; al=pid
    add al, -1                  ; al=pid-1
    mov bl, 24                  ; 每个用户程序的信息块大小为24字节
    mul bl                      ; ax = (pid-1) * 24
    add ax, 1                   ; ax = 1 + (pid-1) * 24
    add ax, 19                  ; 加上cylinder在用户程序信息中的偏移
    mov bx, ax
    add bx, offset_upinfo
    mov al, [bx]
    mov ah, 0
    pop bx
    pop bp
    retf


getUsrProgHead:
    push bp
    push bx
    mov bp, sp
    add bp, 4+4
    mov al, [bp]                ; al=pid
    add al, -1                  ; al=pid-1
    mov bl, 24                  ; 每个用户程序的信息块大小为24字节
    mul bl                      ; ax = (pid-1) * 24
    add ax, 1                   ; ax = 1 + (pid-1) * 24
    add ax, 20                  ; 加上head在用户程序信息中的偏移
    mov bx, ax
    add bx, offset_upinfo
    mov al, [bx]
    mov ah, 0
    pop bx
    pop bp
    retf


getUsrProgSector:
    push bp
    push bx
    mov bp, sp
    add bp, 4+4
    mov al, [bp]                ; al=pid
    add al, -1                  ; al=pid-1
    mov bl, 24                  ; 每个用户程序的信息块大小为24字节
    mul bl                      ; ax = (pid-1) * 24
    add ax, 1                   ; ax = 1 + (pid-1) * 24
    add ax, 21                  ; 加上sector在用户程序信息中的偏移
    mov bx, ax
    add bx, offset_upinfo
    mov al, [bx]
    mov ah, 0
    pop bx
    pop bp
    retf


getUsrProgAddr:
    push bp
    push bx
    mov bp, sp
    add bp, 4+4
    mov al, [bp]                ; al=pid
    add al, -1                  ; al=pid-1
    mov bl, 24                  ; 每个用户程序的信息块大小为24字节
    mul bl                      ; ax = (pid-1) * 24
    add ax, 1                   ; ax = 1 + (pid-1) * 24
    add ax, 22                  ; 加上addr在用户程序信息中的偏移
    mov bx, ax
    add bx, offset_upinfo
    mov ax, [bx]
    pop bx
    pop bp
    retf


loadAndRun:                     ; 函数：从软盘中读取扇区到内存并运行用户程序
    pusha
    mov bp, sp
    add bp, 16+4                ; 参数地址
    LOAD_TO_MEM [bp+12], [bp], [bp+4], [bp+8], [bp+16]
    call dword pushCsIp         ; 用此技巧来手动压栈CS、IP; 此方法详见文档的“实验总结”栏目
    pushCsIp:
    mov si, sp                  ; si指向栈顶
    mov word[si], afterrun      ; 修改栈中IP的值，这样用户程序返回回来后就可以继续执行了
    jmp [bp+16]
    afterrun:
    popa
    retf


getDateYear:                    ; 函数：从CMOS获取当前年份
    mov al, 9
    out 70h, al
    in al, 71h
    mov ah, 0
    retf


getDateMonth:                   ; 函数：从CMOS获取当前月份
    mov al, 8
    out 70h, al
    in al, 71h
    mov ah, 0
    retf

getDateDay:                     ; 函数：从CMOS获取当前日期
    mov al, 7
    out 70h, al
    in al, 71h
    mov ah, 0
    retf

getDateHour:                    ; 函数：从CMOS获取当前小时
    mov al, 4
    out 70h, al
    in al, 71h
    mov ah, 0
    retf


getDateMinute:                  ; 函数：从CMOS获取当前分钟
    mov al, 2
    out 70h, al
    in al, 71h
    mov ah, 0
    retf

getDateSecond:                  ; 函数：从CMOS获取当前秒钟
    mov al, 0
    out 70h, al
    in al, 71h
    mov ah, 0
    retf


[extern Timer]
switchHotwheel:                 ; 函数：打开或关闭风火轮
    push es
    mov ax, 0
    mov es, ax
    mov ax, [es:08h*4]          ; ax=08h号中断处理程序的偏移地址
    cmp ax, Timer               ; 检查08h号中断处理程序是否是风火轮
    je turnoff                  ; 如果是，则关闭
    WRITE_INT_VECTOR 08h, Timer ; 如果不是，则打开
    mov ax, 1                   ; 返回1表示风火轮已打开
    jmp switchDone
    turnoff:
    MOVE_INT_VECTOR 38h, 08h
    mov	ax, 0B800h              ; 文本窗口显存起始地址
    mov	gs, ax                  ; GS = B800h
    mov ah, 0Fh                 ; 黑色背景
    mov al, ' '                 ; 显示空格
    mov [gs:((80*24+79)*2)], ax ; 更新显存
    mov ax, 0                   ; 返回0表示风火轮已关闭
    switchDone:
    pop es
    retf

[extern sys_showOuch]
[extern sys_toUpper]
[extern sys_toLower]
[extern sys_atoi]
[extern sys_itoa]
[extern sys_printInPos]
syscaller:
    push ds
    push si                     ; 用si作为内部临时寄存器
    mov si, cs
    mov ds, si                  ; ds = cs
    mov si, ax
    shr si, 8                   ; si = 功能号
    add si, si                  ; si = 2 * 功能号
    call [sys_table+si]         ; 系统调用函数
    pop si
    pop ds
    iret                        ; int 21h中断返回
    sys_table:                  ; 存放功能号与系统调用函数映射的表
        dw sys_showOuch, sys_toUpper, sys_toLower
        dw sys_atoi, sys_itoa, sys_printInPos