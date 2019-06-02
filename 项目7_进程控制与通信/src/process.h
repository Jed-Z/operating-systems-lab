#include <stdint.h>

typedef struct RegisterImage{
	uint16_t ax;     // 0
	uint16_t cx;     // 2
	uint16_t dx;     // 4
	uint16_t bx;     // 6
	uint16_t sp;     // 8
	uint16_t bp;     // 10
	uint16_t si;     // 12
	uint16_t di;     // 14
	uint16_t ds;     // 16
	uint16_t es;     // 18
	uint16_t fs;     // 20
	uint16_t gs;     // 22
	uint16_t ss;     // 24
	uint16_t ip;     // 26
	uint16_t cs;     // 28
	uint16_t flags;  // 30
}RegisterImage;

typedef struct PCB{
	RegisterImage regimg;
	uint8_t id;     // 32
    uint8_t state;  // 33
}PCB;

extern PCB pcb_table[9];             // PCB表，定义在内核kernel.c中
extern uint16_t current_process_id;  // 当前进程ID，定义在multiprocess.asm中

void pcb_init() {
	for(int i = 0; i < 9; i++) {
		pcb_table[i].id = i;
		pcb_table[i].state = 0;
		pcb_table[i].regimg.ax = 0;
		pcb_table[i].regimg.cx = 0;
		pcb_table[i].regimg.dx = 0;
		pcb_table[i].regimg.bx = 0;
		pcb_table[i].regimg.sp = 0xFE00;
		pcb_table[i].regimg.bp = 0;
		pcb_table[i].regimg.si = 0;
		pcb_table[i].regimg.di = 0;
		pcb_table[i].regimg.ds = 0;
		pcb_table[i].regimg.es = 0;
		pcb_table[i].regimg.fs = 0;
		pcb_table[i].regimg.gs = 0xB800;
		pcb_table[i].regimg.ss = 0;
		pcb_table[i].regimg.ip = 0;
		pcb_table[i].regimg.cs = 0;
		pcb_table[i].regimg.flags = 512;
	}
}

/* 获取当前进程的PCB指针 */
PCB* getCurrentPcb() {
    return &pcb_table[current_process_id];
}

/* 获取PCB表的首地址 */
PCB* getPcbTable() {
    return &pcb_table[0];
}

/* 进程调度 */
void pcbSchedule() {
	getCurrentPcb()->state = 1;
	do {
		current_process_id++;
		if(current_process_id>7) current_process_id = 1;
	} while(getCurrentPcb()->state != 1);
	getCurrentPcb()->state = 2;
}

