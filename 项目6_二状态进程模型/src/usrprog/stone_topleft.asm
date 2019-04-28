org 100h
START:
	mov ax,cs
	mov ds,ax
	mov ax,0b800h 
	mov es,ax
	cmp byte[run],1
	jz BEGIN
	mov word[x1],-1 ;字符坐标初始化为（-1，-1），这样字符将从最左上角运动
	mov word[y1],-1
	mov byte[state],bottomR	;运动方向初始化为往右下方向
	mov byte[color1],03h	;字符颜色初始化
	mov byte[count],0
	mov byte[run],1
BEGIN:
	mov ax,0100h
	int 16h
	jnz READKEY		;ZF不等于0时跳转
	jmp NOTREAD
READKEY:
	mov ax,0
	int 16h
	cmp al,'1'
	jz RETURN
NOTREAD:
	inc byte[count]         ;循环次数
	cmp byte[count],0ffh    ;count-offh=0时；ZF置1，jz跳转
	jz RETURN      
	jmp	Select
RETURN:
	mov ax,0
	mov es,ax
	mov word[es:600h],0
	mov byte[run],0
	ret

Select:

	;根据字符当前状态跳转至相应的标号位置
	cmp byte[state],1
	jz DnR
	cmp byte[state],2
	jz DnL
	cmp byte[state],3
	jz UpR
	cmp byte[state],4
	jz UpL
	jmp START
DnR:
	mov byte[state],bottomR	;将状态修改为朝右下方向运动
	mov byte[color1],03h	;修改此时字符颜色
	cmp word[x1],11 ;判断是否到达下边界，到达则跳转到朝右上方向运动
	jz UpR
	cmp word[y1],39 ;判断是否到达右边界，到达则跳转到朝左下方向运动
	jz DnL
	
	inc word[x1] ;否则继续向右下方向运动
	inc word[y1]
	
	jmp Show	;跳转至字符显示的部分
DnL:
	mov byte[state],bottomL
	mov byte[color1],04h
	cmp word[x1],11
	jz UpL
	cmp word[y1],0
	jz DnR
	
	inc word[x1]
	dec word[y1]
	
	jmp Show
UpR:
	mov byte[state],topR
	mov byte[color1],05h
	cmp word[x1],0
	jz DnR
	cmp word[y1],39
	jz UpL
	
	dec word[x1]
	inc word[y1]
	
	jmp Show
UpL:
	mov byte[state],topL
	mov byte[color1],06h
	cmp word[x1],0
	jz DnL
	cmp word[y1],0
	jz UpR
	
	dec word[x1]
	dec word[y1]

	jmp Show

Show:
	mov ax,[x1]
	mov cx,80
	mul cx
	add ax,[y1]
	mov cx,2
	mul cx
	mov bx,ax ;由于显示界面大小设为了80*25，用（80*x1+y1)*2得到字符的偏移地址
	cmp byte[state],bottomR ;根据运动状态选择显示的字符
	jz CharA
	cmp byte[state],topR
	jz CharB
	cmp byte[state],topL
	jz CharC
	cmp byte[state],bottomL
	jz CharD

CharA:
	mov al,'A'
	mov ah,byte[color1]
	mov[es:bx],ax
	jmp ShowID ;跳转至显示学号的部分

CharB:
	mov al,'B'
	mov ah,byte[color1]
	mov[es:bx],ax
	jmp ShowID
CharC:
	mov al,'C'
	mov ah,byte[color1]
	mov[es:bx],ax
	jmp ShowID
	
CharD:
	mov al,'D'
	mov ah,byte[color1]
	mov[es:bx],ax
	jmp ShowID

ShowID:
	mov word[x2],5 ;选择中间的位置开始显示字符串
	mov word[y2],11
	mov si,0	;用于记录字符串显示到第几位
	mov cx,18	;循环次数
L1:	
	call Calp	;调用Calp计算偏移地址
	mov al,byte[id1+si] ;显示字符串的第si位
	mov byte[es:bx],al
	mov byte[es:bx+1],70h
	inc word[y2]
	inc si
	loop L1
	
	mov word[x2],6 
	mov word[y2],11
	mov si,0
	mov cx,18
;显示第二行字符串
L2:	
	call Calp
	mov al,byte[id2+si]
	mov byte[es:bx],al
	mov byte[es:bx+1],70h
	inc word[y2]
	inc si
	loop L2
	push es
	mov ax,0
	mov es,ax
	cmp word [es:600h],1
	pop es
	jz FENSHI
	mov cx,0f0h
	call DELAY
	jmp BEGIN
FENSHI:
	mov cx,090h
	call DELAY
	ret
Calp:mov ax,word[x2]
	mov bx,80
	mul bx
	add ax,word[y2]
	mov bx,2
	mul bx
	mov bx,ax
	ret
DELAY:
DELAY1:
	push cx
	mov cx,0ffffh
DELAY2:
	loop DELAY2
	pop cx
	loop DELAY1
	ret	
end:
	jmp $
	
Define:
	bottomR equ 1
	bottomL equ 2
	topR equ 3
	topL equ 4
	x1 dw 0
	y1 dw 0
	x2 dw 0
	y2 dw 0
	count db 0
	run db 0
	state db bottomR
	color1 dw 03h 
	id1 db '15352405  15352406'
	id2 db '15352407  15352408'
	times 1022-($-$$) db 0 
    db 0x55,0xaa