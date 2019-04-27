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

int current_process_id = 0;
int Program_Num = 0;

void PCBinit(int id, int seg) {
    if(id > 0 && id < MAX_PROCESS_NUM) {
        PCB_table[id].regimg.gs = 0xb800;
        PCB_table[id].regimg.ss = seg;
        PCB_table[id].regimg.es = seg;
        PCB_table[id].regimg.ds = seg;
        PCB_table[id].regimg.cs = seg;
        PCB_table[id].regimg.fs = seg;
        PCB_table[id].regimg.ip = 0;
        PCB_table[id].regimg.sp = -4;
        PCB_table[id].regimg.ax = 0;
        PCB_table[id].regimg.bx = 0;
        PCB_table[id].regimg.cx = 0;
        PCB_table[id].regimg.dx = 0;
        PCB_table[id].regimg.di = 0;
        PCB_table[id].regimg.si = 0;
        PCB_table[id].regimg.bp = 0;
        PCB_table[id].regimg.flags = 512;
        PCB_table[id].status = P_NEW;
    }
}

void PCBsave(int gs,int fs,int es,int ds,int di,int si,int bp, int sp,int dx,int cx,int bx,int ax,int ss,int ip,int cs,int flags) {
	PCB_table[current_process_id].regimg.ax = ax;
	PCB_table[current_process_id].regimg.bx = bx;
	PCB_table[current_process_id].regimg.cx = cx;
	PCB_table[current_process_id].regimg.dx = dx;
	PCB_table[current_process_id].regimg.ds = ds;
	PCB_table[current_process_id].regimg.es = es;
	PCB_table[current_process_id].regimg.fs = fs;
	PCB_table[current_process_id].regimg.gs = gs;
	PCB_table[current_process_id].regimg.ss = ss;
	PCB_table[current_process_id].regimg.ip = ip;
	PCB_table[current_process_id].regimg.cs = cs;
	PCB_table[current_process_id].regimg.flags = flags;
	PCB_table[current_process_id].regimg.di = di;
	PCB_table[current_process_id].regimg.si = si;
	PCB_table[current_process_id].regimg.sp = sp;
	PCB_table[current_process_id].regimg.bp = bp;
}

/* 用程序编号创建进程 */
void process_create(int progid) {
    int id;
    processLoadProg(getUsrProgCylinder(progid), getUsrProgHead(progid), getUsrProgSector(progid), getUsrProgSize(progid)/512, getUsrProgAddrSeg(progid), getUsrProgAddrOff(progid));
    PCBinit(id, getUsrProgAddrSeg(progid));
    Program_Num++;
}

void PCBscheduler() {
	PCB_table[current_process_id].status = P_READY;

	current_process_id ++;
	if( current_process_id > Program_Num )
		current_process_id = 1;

	if( PCB_table[current_process_id].status != P_NEW )
		PCB_table[current_process_id].status = P_RUNNING;
}

PCB* getCurrentRegImg() {
    return &PCB_table[current_process_id];
}

void special()
{
	if(PCB_table[current_process_id].status == P_NEW)
		PCB_table[current_process_id].status=P_RUNNING;
}