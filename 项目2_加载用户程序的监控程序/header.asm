offset_oskernel equ 0A100h

offset_usrprog1 equ 0A300h
offset_usrprog2 equ 0A700h
offset_usrprog3 equ 0AB00h
offset_usrprog4 equ 0AF00h

; 用于在指定位置显示字符串，参数：(字符串首地址, 字符串字节数, 行数, 列数)
%macro PRINT_IN_POS 4
    pusha            ; 保护现场
    mov	ax, cs       ; 置其他段寄存器值与CS相同
    mov	ds, ax       ; 数据段
    mov	bp, %1       ; BP=当前串的偏移地址
    mov	ax, ds       ; ES:BP = 串地址
    mov	es, ax       ; 置ES=DS
    mov	cx, %2       ; CX = 串长（=9）
    mov	ax, 1301h    ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov	bx, 0007h    ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, %3       ; 行号=0
    mov	dl, %4       ; 列号=0
    int	10h          ; BIOS的10h功能：显示一行字符
    popa             ; 恢复现场
%endmacro