#include "pcb.h"
#define bool int
#define true 1
#define false 0

extern uint16_t getUsrProgSize(uint16_t progid);
extern uint8_t getUsrProgCylinder(uint16_t progid);
extern uint8_t getUsrProgHead(uint16_t progid);
extern uint8_t getUsrProgSector(uint16_t progid);
extern uint16_t getUsrProgAddrSeg(uint16_t progid);
extern uint16_t getUsrProgAddrOff(uint16_t progid);
extern void processLoadProg(uint8_t cylinder, uint8_t head, uint8_t sector, uint16_t len, uint16_t seg, uint16_t offset);
//--------调试用函数，最后应删掉
extern void print(const char* str);
extern char* itoa(int val, int base);
extern void putchar(char c);
#define NEWLINE putchar('\r');putchar('\n')
void debug_printpcb();
//--------
PCB PCB_table[MAX_PROCESS_NUM + 1];  // 进程表
bool PCB_valid[MAX_PROCESS_NUM + 1] = {false};

int current_process_id = 0;

void PCBinit(int id, int seg) {
    if(id > 0 && id < MAX_PROCESS_NUM) {
        PCB_valid[id] = true;

        PCB_table[id].id = id;
        PCB_table[id].status = P_READY;
        PCB_table[id].regimg.gs = seg;
        PCB_table[id].regimg.es = seg;
        PCB_table[id].regimg.ds = seg;
        PCB_table[id].regimg.fs = seg;
        PCB_table[id].regimg.ss = seg;
        PCB_table[id].regimg.cs = seg;
        PCB_table[id].regimg.di = 0;
        PCB_table[id].regimg.si = 0;
        PCB_table[id].regimg.bp = 0;
        PCB_table[id].regimg.sp = 0xFFFC;
        PCB_table[id].regimg.bx = 0;
        PCB_table[id].regimg.ax = 0;
        PCB_table[id].regimg.cx = 0;
        PCB_table[id].regimg.dx = 0;
        PCB_table[id].regimg.ip = 0;
        PCB_table[id].regimg.flags = 512;
    }
}

void PCBsave(int ax, int bx, int cx, int dx, int bp, int si, int di, int ds, int es, int fs, int gs, int ss, int sp, int ip, int cs, int flags) {
	PCB_table[current_process_id].regimg.ss = ss;
	PCB_table[current_process_id].regimg.gs = gs;
	PCB_table[current_process_id].regimg.fs = fs;
	PCB_table[current_process_id].regimg.es = es;
	PCB_table[current_process_id].regimg.ds = ds;
	PCB_table[current_process_id].regimg.di = di;
	PCB_table[current_process_id].regimg.si = si;
	PCB_table[current_process_id].regimg.sp = sp;
	PCB_table[current_process_id].regimg.bp = bp;
	PCB_table[current_process_id].regimg.bx = bx;
	PCB_table[current_process_id].regimg.dx = dx;
	PCB_table[current_process_id].regimg.cx = cx;
	PCB_table[current_process_id].regimg.ax = ax;
	PCB_table[current_process_id].regimg.ip = ip;
	PCB_table[current_process_id].regimg.cs = cs;
	PCB_table[current_process_id].regimg.flags = flags;
    debug_printpcb();
}

/* 用程序编号创建进程 */
int process_create(int progid) {
    int id;
    for(id = 1; id <= MAX_PROCESS_NUM; id++) {
        if(PCB_valid[id] == false) break;  //找到进程表中的一个空位
    }
    if(id > MAX_PROCESS_NUM) return -1;  // 进程表中没有空位
    processLoadProg(getUsrProgCylinder(progid), getUsrProgHead(progid), getUsrProgSector(progid), getUsrProgSize(progid)/512, getUsrProgAddrSeg(progid), getUsrProgAddrOff(progid));
    PCBinit(id, getUsrProgAddrSeg(progid));
    return id;  // 返回进程标识符
}

void PCBscheduler() {
    for(int i = 0; i < MAX_PROCESS_NUM; i++) {  // i仅用于计数
        current_process_id = (current_process_id) % MAX_PROCESS_NUM + 1;
        if(PCB_valid[current_process_id] == true) {
            break;  // return
        }
    }
}

struct RegisterImage* getCurrentRegImg() {
    return &PCB_table[current_process_id].regimg;
}

void debug_printreg(int ax, int bx, int cx, int dx, int bp, int si, int di, int ds, int es, int fs, int gs, int ss, int cs, int sp) {
    char* pro = "***debug_printreg***\r\ncurrent_process_id=";
    print(pro);
    print(itoa(current_process_id, 10)); NEWLINE;
    char* reg = "***reg begin***\r\n";
    print(reg);
    print(itoa(cs, 16)); putchar(' ');
    print(itoa(ss, 16)); putchar(' ');
    print(itoa(gs, 16)); putchar(' ');
    print(itoa(fs, 16)); putchar(' ');
    print(itoa(es, 16)); putchar(' ');
    print(itoa(ds, 16)); NEWLINE;

    print(itoa(di, 16)); putchar(' ');
    print(itoa(si, 16)); putchar(' ');
    print(itoa(bp, 16)); putchar(' ');
    print(itoa(sp+16, 16)); NEWLINE;

    print(itoa(dx, 16)); putchar(' ');
    print(itoa(cx, 16)); putchar(' ');
    print(itoa(bx, 16)); putchar(' ');
    print(itoa(ax, 16)); NEWLINE;
    
    char* end = "***reg end***\r\n\r\n";
    print(end);
}

void debug_printpcb() {
    char* pro = "###debug_printPCB###\r\ncurrent_process_id=";
    print(pro);
    print(itoa(current_process_id, 10)); NEWLINE;
    char* reg = "###reg begin###\r\n";
    print(reg);
    print(itoa(PCB_table[current_process_id].regimg.cs, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.ss, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.gs, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.fs, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.es, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.ds, 16)); NEWLINE;

    print(itoa(PCB_table[current_process_id].regimg.di, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.si, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.bp, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.sp, 16)); NEWLINE;

    print(itoa(PCB_table[current_process_id].regimg.dx, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.cx, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.bx, 16)); putchar(' ');
    print(itoa(PCB_table[current_process_id].regimg.ax, 16)); NEWLINE;
    
    char* end = "###reg end###\r\n\r\n";
    print(end);
}