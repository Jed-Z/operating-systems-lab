addr_upinfo equ 07E00h      ; 用户程序信息表被装入的位置
addr_oskernel equ 08000h    ; 操作系统内核被装入的位置

addr_usrprog1 equ 10000h    ; 四个普通用户程序的物理地址
addr_usrprog2 equ 20000h    ; 四个普通用户程序的物理地址
addr_usrprog3 equ 30000h    ; 四个普通用户程序的物理地址
addr_usrprog4 equ 40000h    ; 四个普通用户程序的物理地址
addr_intcaller equ 50000h
addr_syscalltest equ 0B500h
addr_forktest equ 60000h

%macro WRITE_INT_VECTOR 2   ; 写中断向量表；参数：（中断号，中断处理程序地址）
    push ax
    push es
    mov ax, 0
    mov es, ax              ; ES = 0
    mov word[es:%1*4], %2   ; 设置中断向量的偏移地址
    mov ax,cs
    mov word[es:%1*4+2], ax ; 设置中断向量的段地址=CS
    pop es
    pop ax
%endmacro

%macro MOVE_INT_VECTOR 2    ; 转移中断向量；参数：（源中断号，目的中断号）
    push ax
    push es
    push si
    mov ax, 0
    mov es, ax              ; es=0
    mov si, [es:%1*4]
    mov [es:%2*4], si
    mov si, [es:%1*4+2]
    mov [es:%2*4+2], si
    pop si
    pop es
    pop ax
%endmacro

%macro PRINT_IN_POS 4       ; 在指定位置打印字符串；参数：（串地址，串长，行号，列号）
    pusha                   ; 保护现场
    push ds
    push es
    mov	ax, cs              ; 置其他段寄存器值与CS相同
    mov	ds, ax              ; 数据段
    mov	bp, %1              ; BP=当前串的偏移地址
    mov	ax, ds              ; ES:BP = 串地址
    mov	es, ax              ; 置ES=DS
    mov	cx, %2              ; CX = 串长（=9）
    mov	ax, 1301h           ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov	bx, 0007h           ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, %3              ; 行号=0
    mov	dl, %4              ; 列号=0
    int	10h                 ; BIOS的10h功能：显示一行字符
    pop es
    pop ds
    popa                    ; 恢复现场
%endmacro

%macro LOAD_TO_MEM 6        ; 读软盘到内存；参数：（扇区数，柱面号，磁头号，扇区号，内存段值，内存偏移量）
    pusha
    push es
    mov ax, %5              ; 段地址; 存放数据的内存基地址
    mov es, ax              ; 设置段地址（不能直接mov es,段地址）
    mov bx, %6              ; 偏移地址; 存放数据的内存偏移地址
    mov ah, 2               ; 功能号
    mov al, %1              ; 扇区数
    mov dl, 0               ; 驱动器号; 软盘为0，硬盘和U盘为80H
    mov dh, %3              ; 磁头号; 起始编号为0
    mov ch, %2              ; 柱面号; 起始编号为0
    mov cl, %4              ; 起始扇区号 ; 起始编号为1
    int 13H                 ; 调用读磁盘BIOS的13h功能
    pop es
    popa
%endmacro

%macro PUTCHAR 1
    pusha
    mov al, %1   ; al=要打印的字符
    mov bh, 0      ; bh=页码
    mov ah, 0Eh    ; 功能号：打印一个字符
    int 10h        ; 打印字符
    popa
%endmacro

%macro PRINTLN 1
    pusha
    mov si, %1
Loop1_%1:
    cmp byte[cs:si], 0
    je Quit1_%1
    PUTCHAR [cs:si]
    inc si
    jmp Loop1_%1
Quit1_%1:
    popa
%endmacro