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
    mov ds, ax                               ; ds=cs
    PRINT_IN_POS msg, msg_len, 0, 0          ; 调用宏，显示字符串

LoadOsKernel:
    LOAD_TO_MEM 16, 0, 0, 3, offset_oskernel ; 调用宏，加载操作系统内核

LoadUsrProgInfo:
    LOAD_TO_MEM 1, 0, 0, 2, offset_upinfo    ; 调用宏，加载用户程序信息表

EnterOs:
    jmp offset_oskernel                      ; 跳转到操作系统内核

DataArea:
    msg db 'Bootloader is loading operating system...'
    msg_len equ ($-msg)

    times 510-($-$$) db 0
    db 0x55, 0xaa                            ; 主引导记录标志