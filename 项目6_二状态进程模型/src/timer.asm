BITS 16
[global Timer]
Timer:

EndTimer:
    mov al,20h                  ; AL = EOI
    out 20h,al                  ; 发送EOI到主8529A
    out 0A0h,al                 ; 发送EOI到从8529A
    iret                        ; 从中断返回