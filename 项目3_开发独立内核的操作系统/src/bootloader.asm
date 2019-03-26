; @Author: Jed
; @Description: 引导程序；本文件独立编译为二进制程序，与其他asm或C程序无关
; @Date: 2019-03-21
; @LastEditTime: 2019-03-23

BITS 16
org 7c00h

offset_upinfo equ 7E00h     ; 用户程序信息表被装入的位置
offset_oskernel equ 8000h   ; 操作系统内核被装入的位置

global _start
_start:
    mov	ax, cs              ; 置其他段寄存器值与CS相同
    mov	ds, ax              ; 数据段
    mov	bp, load_msg        ; BP=当前串的偏移地址
    mov	ax, ds              ; ES:BP = 串地址
    mov	es, ax              ; 置ES=DS
    mov	cx, load_msg_len    ; CX = 串长
    mov	ax, 1301h           ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov	bx, 0007h           ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, 0               ; 行号=0
    mov	dl, 0               ; 列号=0
    int	10h                 ; BIOS的10h功能：显示一行字符

LoadUsrProgInfo:            ; 加载用户程序信息表
    mov ax,cs               ; 段地址; 存放数据的内存基地址
    mov es,ax               ; 设置段地址（不能直接mov es,段地址）
    mov bx, offset_upinfo   ; 偏移地址; 存放数据的内存偏移地址
    mov ah,2                ; 功能号
    mov al,1                ; 扇区数
    mov dl,0                ; 驱动器号; 软盘为0，硬盘和U盘为80H
    mov dh,0                ; 磁头号; 起始编号为0
    mov ch,0                ; 柱面号; 起始编号为0
    mov cl,2                ; 起始扇区号 ; 起始编号为1
    int 13H                 ; 调用读磁盘BIOS的13h功能

LoadOsKernel:               ; 加载操作系统内核
    mov ax,cs               ; 段地址; 存放数据的内存基地址
    mov es,ax               ; 设置段地址（不能直接mov es,段地址）
    mov bx, offset_oskernel ; 偏移地址; 存放数据的内存偏移地址
    mov ah,2                ; 功能号
    mov al,8                ; 扇区数（为内核预留8个扇区2~9号，共4KB）
    mov dl,0                ; 驱动器号; 软盘为0，硬盘和U盘为80H
    mov dh,0                ; 磁头号; 起始编号为0
    mov ch,0                ; 柱面号; 起始编号为0
    mov cl,3                ; 起始扇区号 ; 起始编号为1
    int 13H                 ; 调用读磁盘BIOS的13h功能

EnterOs:
    jmp offset_oskernel     ; 跳转到操作系统内核执行

AfterRun:
    jmp $                   ; 无限循环

DataArea:
    load_msg db 'Bootloader is loading operating system...'
    load_msg_len  equ ($-load_msg)

SectorEnding:
    times 510-($-$$) db 0
    db 0x55,0xaa            ; 主引导记录标志