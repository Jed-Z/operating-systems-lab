
Int33:
    pusha
    mov	ax, cs            ; 置其他段寄存器值与CS相同
    mov	ds, ax            ; 数据段
    mov	bp, int33_msg     ; BP=当前串的偏移地址
    mov	ax, ds            ; ES:BP = 串地址
    mov	es, ax            ; 置ES=DS
    mov	cx, int33_msg_len ; CX = 串长
    mov	ax, 1301h         ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov	bx, 0007h         ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, 20            ; 行号=0
    mov	dl, 20            ; 列号=0
    int	10h               ; BIOS的10h功能：显示一行字符
    popa
    iret

    int33_msg db "int 33 is running"
    int33_msg_len  equ ($-int33_msg)