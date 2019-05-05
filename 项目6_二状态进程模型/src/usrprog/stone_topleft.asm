okhaha:
    ; mov al, '-'           ; al=要打印的字符
    ; mov bh, 0              ; bh=页码
    ; mov ah, 0Eh            ; 功能号：打印一个字符
    ; int 10h                ; 打印字符
    jmp okhaha