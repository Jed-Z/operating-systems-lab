%include "header.asm"
org  7C00h                     ; BIOS将把引导扇区加载到0:7C00h处，并开始执行

start:
    mov	ax, cs                 ; 置其他段寄存器值与CS相同
    mov	ds, ax                 ; 数据段
    mov	bp, Message            ; BP=当前串的偏移地址
    mov	ax, ds                 ; ES:BP = 串地址
    mov	es, ax                 ; 置ES=DS
    mov	cx, msglen             ; CX = 串长（=9）
    mov	ax, 1301h              ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov	bx, 0007h              ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, 0                  ; 行号=0
    mov	dl, 0                  ; 列号=0
    int	10h                    ; BIOS的10h功能：显示一行字符

LoadOsKernel:                  ; 读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
    mov ax,cs                  ; 段地址 ; 存放数据的内存基地址
    mov es,ax                  ; 设置段地址（不能直接mov es,段地址）
    mov bx, offset_oskernel    ; 偏移地址; 存放数据的内存偏移地址
    mov ah,2                   ; 功能号
    mov al,1                   ; 扇区数
    mov dl,0                   ; 驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,0                   ; 磁头号 ; 起始编号为0
    mov ch,0                   ; 柱面号 ; 起始编号为0
    mov cl,2                   ; 起始扇区号 ; 起始编号为1
    int 13H                    ; 调用读磁盘BIOS的13h功能

LoadUsrProg1:
    mov ax,cs                  ; 段地址 ; 存放数据的内存基地址
    mov es,ax                  ; 设置段地址（不能直接mov es,段地址）
    mov bx, offset_usrprog1    ; 偏移地址; 存放数据的内存偏移地址
    mov ah,2                   ; 功能号
    mov al,2                   ; 扇区数
    mov dl,0                   ; 驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,0                   ; 磁头号 ; 起始编号为0
    mov ch,0                   ; 柱面号 ; 起始编号为0
    mov cl,3                   ; 起始扇区号 ; 起始编号为1
    int 13H                    ; 调用读磁盘BIOS的13h功能

LoadUsrProg2:
    mov ax,cs                  ; 段地址 ; 存放数据的内存基地址
    mov es,ax                  ; 设置段地址（不能直接mov es,段地址）
    mov bx, offset_usrprog2    ; 偏移地址; 存放数据的内存偏移地址
    mov ah,2                   ; 功能号
    mov al,2                   ; 扇区数
    mov dl,0                   ; 驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,0                   ; 磁头号 ; 起始编号为0
    mov ch,0                   ; 柱面号 ; 起始编号为0
    mov cl,5                   ; 起始扇区号 ; 起始编号为1
    int 13H                    ; 调用读磁盘BIOS的13h功能

LoadUsrProg3:
    mov ax,cs                  ; 段地址 ; 存放数据的内存基地址
    mov es,ax                  ; 设置段地址（不能直接mov es,段地址）
    mov bx, offset_usrprog3    ; 偏移地址; 存放数据的内存偏移地址
    mov ah,2                   ; 功能号
    mov al,2                   ; 扇区数
    mov dl,0                   ; 驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,0                   ; 磁头号 ; 起始编号为0
    mov ch,0                   ; 柱面号 ; 起始编号为0
    mov cl,7                   ; 起始扇区号 ; 起始编号为1
    int 13H                    ; 调用读磁盘BIOS的13h功能

LoadUsrProg4:
    mov ax,cs                  ; 段地址 ; 存放数据的内存基地址
    mov es,ax                  ; 设置段地址（不能直接mov es,段地址）
    mov bx, offset_usrprog4    ; 偏移地址; 存放数据的内存偏移地址
    mov ah,2                   ; 功能号
    mov al,2                   ; 扇区数
    mov dl,0                   ; 驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,0                   ; 磁头号 ; 起始编号为0
    mov ch,0                   ; 柱面号 ; 起始编号为0
    mov cl,9                   ; 起始扇区号 ; 起始编号为1
    int 13H                    ; 调用读磁盘BIOS的13h功能

EnterOs:
    jmp offset_oskernel        ; 跳转到操作系统内核执行

AfterRun:
    jmp $                      ; 无限循环

DataArea:
    Message db 'Bootloader is loading operating system and user programmes...'
    msglen  equ ($-Message)

SectorEnding:
    times 510-($-$$) db 0
    db 0x55,0xaa