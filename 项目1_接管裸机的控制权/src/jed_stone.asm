    ; jed_stone.asm
    ; 原作：凌应标 2014-03
    ; 改写：张怡昕（17341203） 2019-03
    ; 说明：本程序在文本方式显示器上从左边射出一个字符,以45度向右下运动，撞到边框后反射。

    Dn_Rt equ 1             ; D-Down,U-Up,R-right,L-Left
    Up_Rt equ 2
    Up_Lt equ 3
    Dn_Lt equ 4
    delay equ 50000         ; 计时器延迟计数,用于控制画框的速度
    ddelay equ 580          ; 计时器延迟计数,用于控制画框的速度

    org 7C00h               ; 程序装载到7C00h，这里存放的是主引导记录

start:
    mov ax,cs
    mov es,ax               ; ES = CS
    mov ds,ax               ; DS = CS
    mov es,ax               ; ES = CS
    mov ax,0B800h
    mov gs,ax               ; GS = B800h，指向文本模式的显示缓冲区
    mov byte[char],'X'

loop1:
    dec word[count]         ; 递减计数变量
    jnz loop1               ; >0：跳转;
    mov word[count],delay
    dec word[dcount]        ; 递减计数变量
    jnz loop1
    mov word[count],delay
    mov word[dcount],ddelay

    mov al,1
    cmp al,byte[rdul]
    jz  DnRt
    mov al,2
    cmp al,byte[rdul]
    jz  UpRt
    mov al,3
    cmp al,byte[rdul]
    jz  UpLt
    mov al,4
    cmp al,byte[rdul]
    jz  DnLt
    ; jmp $

DnRt:
    inc word[x]
    inc word[y]
    mov bx,word[x]
    mov ax,screenh
    sub ax,bx
    jz  dr2ur
    mov bx,word[y]
    mov ax,screenw
    sub ax,bx
    jz  dr2dl
    jmp show

dr2ur:
    mov word[x],paddingh
    mov byte[rdul],Up_Rt
    jmp show

dr2dl:
    mov word[y],paddingw
    mov byte[rdul],Dn_Lt
    jmp show


UpRt:
    dec word[x]
    inc word[y]
    mov bx,word[y]
    mov ax,screenw
    sub ax,bx
    jz  ur2ul
    mov bx,word[x]
    mov ax,-1
    sub ax,bx
    jz  ur2dr
    jmp show

ur2ul:
    mov word[y],paddingw
    mov byte[rdul],Up_Lt
    jmp show

ur2dr:
    mov word[x],1
    mov byte[rdul],Dn_Rt
    jmp show


UpLt:
    dec word[x]
    dec word[y]
    mov bx,word[x]
    mov ax,-1
    sub ax,bx
    jz  ul2dl
    mov bx,word[y]
    mov ax,-1
    sub ax,bx
    jz  ul2ur
    jmp show

ul2dl:
    mov word[x],1
    mov byte[rdul],Dn_Lt
    jmp show
ul2ur:
    mov word[y],1
    mov byte[rdul],Up_Rt
    jmp show

DnLt:
    inc word[x]
    dec word[y]
    mov bx,word[y]
    mov ax,-1
    sub ax,bx
    jz  dl2dr
    mov bx,word[x]
    mov ax,screenh
    sub ax,bx
    jz  dl2ul
    jmp show

dl2dr:
    mov word[y],1
    mov byte[rdul],Dn_Rt
    jmp show

dl2ul:
    mov word[x],paddingh
    mov byte[rdul],Up_Lt
    jmp show

show:
    xor ax,ax               ; 计算显存地址
    mov ax,word[x]
    mov bx,80
    mul bx
    add ax,word[y]
    mov bx,2
    mul bx
    mov bp,ax
    mov ah,[curcolor2]      ; 弹字符的背景色和前景色（默认值为07h，详见文档）
    inc byte[curcolor2]
    cmp byte[curcolor2], 0fh
    jnz skip
    mov byte[curcolor2], 1  ; 为了不改变背景色
skip:
    mov al,byte[char]       ; AL = 显示字符值（默认值为20h=空格符）
    mov word[gs:bp],ax      ; 显示字符的ASCII码值

    mov si, myinfo          ; 显示姓名和学号
    mov di, 2
    mov cx, word[infolen]
loop2:                      ; 显示myinfo中的每个字符
    mov al, byte[ds:si]
    inc si
    mov ah, [curcolor]      ; 背景色和前景色
    add byte[curcolor], 12h ; 变色，该数字可随意调节以达到不错的效果
    mov word [gs:di],ax
    add di,2
    loop loop2

    jmp loop1

end:
    jmp $                   ; 停止画框，无限循环

DataArea:
    count dw delay
    dcount dw ddelay
    rdul db Dn_Rt           ; 向右下运动
    char db 0

    screenw equ 80          ; 屏幕宽度字符数
    screenh equ 25          ; 屏幕高度字符数
    x dw 7                  ; 起始行数
    y dw 0                  ; 起始列数
    paddingw equ screenw-2
    paddingh equ screenh-2

    myinfo db '                             Zhang Yixin, 17341203                            '
    infolen dw $-myinfo     ; myinfo字符串的长度
    curcolor db 80h         ; 保存当前字符颜色属性，用于myinfo
    curcolor2 db 09h        ; 保存当前字符颜色属性，用于移动的字符

    times 510-($-$$) db 0   ; 填充0，一直到第510字节
    db 55h, 0AAh            ; 扇区末尾两个字节为0x55和0xAA