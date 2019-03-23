; @Author: Jed
; @Description: 操作系统内核文件；程序入口_start也在这里
; @Date: 2019-03-22
; @LastEditTime: 2019-03-23
BITS 16

[extern showHelp]

global _start
_start:
    call dword showHelp ; 清屏

    mov	ax, cs              ; 置其他段寄存器值与CS相同
    mov	ds, ax              ; 数据段
    mov	bp, str_title        ; BP=当前串的偏移地址
    mov	ax, ds              ; ES:BP = 串地址
    mov	es, ax              ; 置ES=DS
    mov	cx, titlelen    ; CX = 串长（=9）
    mov	ax, 1301h           ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov	bx, 0007h           ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, 0               ; 行号=0
    mov	dl, 0               ; 列号=0
    int	10h                 ; BIOS的10h功能：显示一行字符

    jmp $



DataArea:
    str_title db 'JedOS V1.1'
    titlelen equ ($-str_title)