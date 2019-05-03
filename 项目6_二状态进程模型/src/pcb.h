#include "stringio.h"
extern uint16_t temppcb_ss;
extern uint16_t temppcb_gs;
extern uint16_t temppcb_fs;
extern uint16_t temppcb_es;
extern uint16_t temppcb_ds;
extern uint16_t temppcb_di;
extern uint16_t temppcb_si;
extern uint16_t temppcb_bp;
extern uint16_t temppcb_sp;
extern uint16_t temppcb_bx;
extern uint16_t temppcb_dx;
extern uint16_t temppcb_cx;
extern uint16_t temppcb_ax;
extern uint16_t temppcb_ip;
extern uint16_t temppcb_cs;
extern uint16_t temppcb_flags;

int timer_flag = 0;

typedef struct RegisterImage{
	int ss;     // 0
	int gs;     // 1
	int fs;     // 2
	int es;     // 3
	int ds;     // 4
	int di;     // 5
	int si;     // 6
	int bp;     // 7
	int sp;     // 8
	int bx;     // 9
	int dx;     // 10
	int cx;     // 11
	int ax;     // 12
	int ip;     // 13
	int cs;     // 14
	int flags;  // 15
} RegisterImage;

typedef struct PCB{
	RegisterImage regimg;
	int state;
} PCB;

PCB pcb_table[3];
int current_process_id = 0;


void debug_init() {
    pcb_table[0].regimg.ax = 0;
	pcb_table[0].regimg.bx = 0;
	pcb_table[0].regimg.cx = 0;
	pcb_table[0].regimg.dx = 0;
	pcb_table[0].regimg.ds = 0;
	pcb_table[0].regimg.es = 0;
	pcb_table[0].regimg.fs = 0;
	pcb_table[0].regimg.gs = 0;
	pcb_table[0].regimg.ss = 0;
	pcb_table[0].regimg.ip = 0;
	pcb_table[0].regimg.cs = 0;
	pcb_table[0].regimg.flags = 512;
	pcb_table[0].regimg.di = 0;
	pcb_table[0].regimg.si = 0;
	pcb_table[0].regimg.sp = 0;
	pcb_table[0].regimg.bp = 0;

	pcb_table[1].regimg.ax = 0;
	pcb_table[1].regimg.bx = 0;
	pcb_table[1].regimg.cx = 0;
	pcb_table[1].regimg.dx = 0;
	pcb_table[1].regimg.ds = 0x1000;
	pcb_table[1].regimg.es = 0x1000;
	pcb_table[1].regimg.fs = 0x1000;
	pcb_table[1].regimg.gs = 0x1000;
	pcb_table[1].regimg.ss = 0x1000;
	pcb_table[1].regimg.ip = 0x100;
	pcb_table[1].regimg.cs = 0x1000;
	pcb_table[1].regimg.flags = 512;
	pcb_table[1].regimg.di = 0;
	pcb_table[1].regimg.si = 0;
	pcb_table[1].regimg.sp = 0x100-4;
	pcb_table[1].regimg.bp = 0;

	pcb_table[2].regimg.ax = 0xaaaa;
	pcb_table[2].regimg.bx = 0;
	pcb_table[2].regimg.cx = 0;
	pcb_table[2].regimg.dx = 0;
	pcb_table[2].regimg.ds = 0x2000;
	pcb_table[2].regimg.es = 0x2000;
	pcb_table[2].regimg.fs = 0x2000;
	pcb_table[2].regimg.gs = 0x2000;
	pcb_table[2].regimg.ss = 0x2000;
	pcb_table[2].regimg.ip = 0x100;
	pcb_table[2].regimg.cs = 0x2000;
	pcb_table[2].regimg.flags = 512;
	pcb_table[2].regimg.di = 0;
	pcb_table[2].regimg.si = 0;
	pcb_table[2].regimg.sp = 0x100-4;
	pcb_table[2].regimg.bp = 0;
}

void pcbSave(int gs,int fs,int es,int ds,int di,int si,int bp, int sp,
            int dx,int cx,int bx,int ax,int ss,int ip,int cs,int flags) {
	pcb_table[current_process_id].regimg.ss = ss;
	pcb_table[current_process_id].regimg.gs = gs;
	pcb_table[current_process_id].regimg.fs = fs;
	pcb_table[current_process_id].regimg.es = es;
	pcb_table[current_process_id].regimg.ds = ds;
	pcb_table[current_process_id].regimg.di = di;
	pcb_table[current_process_id].regimg.si = si;
	pcb_table[current_process_id].regimg.bp = bp;
	pcb_table[current_process_id].regimg.sp = sp;
	pcb_table[current_process_id].regimg.bx = bx;
	pcb_table[current_process_id].regimg.dx = dx;
	pcb_table[current_process_id].regimg.cx = cx;
	pcb_table[current_process_id].regimg.ax = ax;
	pcb_table[current_process_id].regimg.ip = ip;
	pcb_table[current_process_id].regimg.cs = cs;
	pcb_table[current_process_id].regimg.flags = flags;
}

void schedule() {
	current_process_id = 0;
	temppcb_ss =  pcb_table[current_process_id].regimg.ss;
	temppcb_gs =  pcb_table[current_process_id].regimg.gs;
	temppcb_fs =  pcb_table[current_process_id].regimg.fs;
	temppcb_es =  pcb_table[current_process_id].regimg.es;
	temppcb_ds =  pcb_table[current_process_id].regimg.ds;
	temppcb_di =  pcb_table[current_process_id].regimg.di;
	temppcb_si =  pcb_table[current_process_id].regimg.si;
	temppcb_bp =  pcb_table[current_process_id].regimg.bp;
	temppcb_sp =  pcb_table[current_process_id].regimg.sp;
	temppcb_bx =  pcb_table[current_process_id].regimg.bx;
	temppcb_dx =  pcb_table[current_process_id].regimg.dx;
	temppcb_cx =  pcb_table[current_process_id].regimg.cx;
	temppcb_ax =  pcb_table[current_process_id].regimg.ax;
	temppcb_ip =  pcb_table[current_process_id].regimg.ip;
	temppcb_cs =  pcb_table[current_process_id].regimg.cs;
	temppcb_flags =  pcb_table[current_process_id].regimg.flags;
}

void debug_showreg(uint16_t reg) {
	print(itoa(reg, 16));
	char* end = "###reg end###\r\n\r\n";
	print(end);
}