IntOuch:
    push ax
    push bx
    push cx
    push dx
	push bp
	push es
	push ds
	
    in al, 60h
    cmp al, 01h
    je powerOff

	mov ax, cs
	mov ds, ax
	mov es, ax
	
	inc byte [es:odd]
	cmp byte [es:odd], 1
	je print
	mov byte [es:odd], 0
	jmp final
	
print:
    mov ah,13h 	                    ; 功能号
	mov al,0                 		; 光标放到串尾
	mov bl,0ah 	                    ; 亮绿
	mov bh,0 	                	; 第0页
	mov dh,[es:cnn] 	    ; 第 cnn 行
	mov dl,[es:cnn]	    ; 第 cnn 列
	mov bp,  OUCH 	        ; BP=串地址
	mov cx,10  	                    ; 串长为 10
	int 10h 		                ; 调用10H号中断
    
	call Delay
	
	mov ax, 0601h					;清除OUCH!OUCH!
	mov bh, 0Fh
	mov ch, [es:cnn]
	mov cl, [es:cnn]
	mov dh, [es:cnn]
	mov dl, [es:cnn]
	add dl, 10
	int 10h
	
	inc byte [es:cnn]
	cmp byte  [es:cnn], 25
	jne final
	mov byte  [es:cnn], 0
	
final:
	in al,60h

	mov al,20h					    ; AL = EOI
	out 20h,al						; 发送EOI到主8529A
	out 0A0h,al					    ; 发送EOI到从8529A
	
	pop ds
	pop es
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	
	iret							; 从中断返回
Delay:
	push ax
	push cx
	
	mov ax, 400
loop11:
	mov cx, 50000
loop2:
	loop loop2
	dec ax
	cmp ax, 0
	jne loop11
	
	pop cx
	pop ax
	ret

powerOff:                  ; 函数：强制关机
    mov ax, 2001H
    mov dx, 1004H
    out dx, ax
OUCH:
    db "OUCH!OUCH!"
	cnn db 0
	odd db 1