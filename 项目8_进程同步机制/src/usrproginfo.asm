; @Author: Jed
; @Description: 用户车呢光绪信息表。放在软盘第2个扇区。
; @Date: 2019-03-29
; @LastEditTime: 2019-06-06

%include "macro.asm"
%macro UsrProgInfoBlock 8    ; 参数：(ProgID,程序名,字节数,柱面,磁头,扇区,内存地址)
    progid%1 db %1           ; 程序编号ProgID；相对偏移0
    name%1 db %2             ; 程序名（至多32字节）；相对偏移1
    times 16-($-name%1) db 0 ; 程序名占6字节
    size%1 dw %3             ; 程序大小；相对偏移17
    cylinder%1 db %4         ; 柱面；相对偏移19
    head%1 db %5             ; 磁头；相对偏移20
    sector%1 db %6           ; 扇区；相对偏移21
    addr_seg%1 dw %7         ; 内存地址段值；相对偏移22
    addr_off%1 dw %8         ; 内存地址偏移量；相对偏移24
%endmacro                    ; 共26个字节

UsrProgNumber:               ; 用户程序数量
    db (SectorEnding-UserProgInfo) / 24

UserProgInfo:
    UsrProgInfoBlock 1, 'stone_topleft',    1024, 1, 0, 1,  addr_usrprog1 >> 4 & 0F000h,    addr_usrprog1 & 0FFFFh
    UsrProgInfoBlock 2, 'stone_topright',   1024, 1, 0, 3,  addr_usrprog2 >> 4 & 0F000h,    addr_usrprog2 & 0FFFFh
    UsrProgInfoBlock 3, 'stone_botleft',    1024, 1, 0, 5,  addr_usrprog3 >> 4 & 0F000h,    addr_usrprog3 & 0FFFFh
    UsrProgInfoBlock 4, 'stone_botright',   1024, 1, 0, 7,  addr_usrprog4 >> 4 & 0F000h,    addr_usrprog4 & 0FFFFh
    UsrProgInfoBlock 5, 'fork_test',        1024,  1, 0, 13, addr_forktest >> 4 & 0F000h, addr_forktest & 0FFFFh

SectorEnding:
    times 512-($-$$) db 0