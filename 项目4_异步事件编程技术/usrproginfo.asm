UsrProgNumber:
    dw 4                     ; 用户程序数量

UsrProg1:                    ; 每个用户程序信息占用40字节
    pid1 dw 1                ; 程序编号；相对偏移0
    name1 db 'stone_topleft' ; 程序名（至多32字节）；相对偏移2
    times 32-($-name1) db 0  ; 程序名要填满32字节
    size1 dw 1024            ; 程序大小；相对偏移34
    sector1 dw 1            ; 起始扇区；相对偏移36
    addr1 dw 0xA300          ; 内存中的地址；相对偏移38

UsrProg2:
    pid2 dw 2
    name2 db 'stone_topright'
    times 32-($-name2) db 0
    size2 dw 1024
    sector2 dw 3
    addr2 dw 0xA700          ; 内存中的地址

UsrProg3:
    pid3 dw 3
    name3 db 'stone_bottomleft'
    times 32-($-name3) db 0
    size3 dw 1024
    sector3 dw 5
    addr3 dw 0xAB00          ; 内存中的地址

UsrProg4:
    pid4 dw 4
    name4 db 'stone_bottomright'
    times 32-($-name4) db 0
    size4 dw 1024
    sector4 dw 7
    addr4 dw 0xAF00          ; 内存中的地址


SectorEnding:
    times 512-($-$$) db 0