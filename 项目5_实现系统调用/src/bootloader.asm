; @Author: Jed
; @Description: 引导程序；独立编译
; @Date: 2019-03-21
; @LastEditTime: 2019-04-12

BITS 16
%include "macro.asm"
org 7c00h

global _start
_start:
    mov ax, cs
    mov ds, ax              ; ds=cs
    PRINT_IN_POS msg, msg_len, 0, 0

LoadOsKernel:               ; 加载操作系统内核
    mov ax,cs               ; 段地址; 存放数据的内存基地址
    mov es,ax               ; 设置段地址（不能直接mov es,段地址）
    mov bx, offset_oskernel ; 偏移地址; 存放数据的内存偏移地址
    mov ah,2                ; 功能号
    mov al,16               ; 扇区数
    mov dl,0                ; 驱动器号; 软盘为0，硬盘和U盘为80H
    mov dh,0                ; 磁头号; 起始编号为0
    mov ch,0                ; 柱面号; 起始编号为0
    mov cl,3                ; 起始扇区号 ; 起始编号为1
    int 13H                 ; 调用读磁盘BIOS的13h功能

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

EnterOs:
    jmp offset_oskernel     ; 跳转到操作系统内核

DataArea:
    msg db 'Bootloader is loading operating system...'
    msg_len equ ($-msg)

    times 510-($-$$) db 0
    db 0x55,0xaa            ; 主引导记录标志