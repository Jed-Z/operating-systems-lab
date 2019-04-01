offset_upinfo equ 7E00h         ; 用户程序信息表被装入的位置


%macro WRITE_INT_VECTOR 2       ; 写中断向量表；参数：（中断号，中断处理程序地址）
    push ax
    push es
    mov ax, 0
    mov es, ax                  ; ES = 0
    mov word[es:%1*4], %2       ; 设置中断向量的偏移地址
    mov ax,cs
    mov word[es:%1*4+2], ax     ; 设置中断向量的段地址=CS
    pop es
    pop ax
%endmacro

%macro MOVE_INT_VECTOR 2        ; 将参数1的中断向量转移至参数2处
    push ax
    push es
    push si
    mov ax, 0
    mov es, ax
    mov si, [es:%1*4]
    mov [es:%2*4], si
    mov si, [es:%1*4+2]
    mov [es:%2*4+2], si
    pop si
    pop es
    pop ax
%endmacro

