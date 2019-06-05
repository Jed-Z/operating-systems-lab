#include <stdint.h>
#define PROCESS_NUM 8

extern void goBackToKernel();
extern void copyStack();
extern uint16_t current_process_id;  // 当前进程ID，定义在multiprocess.asm中
extern uint16_t stack_length;
extern uint16_t from_seg, to_seg;

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

enum PCB_STATE {P_NEW, P_READY, P_RUNNING, P_BLOCKED};
extern PCB pcb_table[PROCESS_NUM];             // PCB表，定义在内核kernel.c中

void pcb_init() {
	for(int i = 0; i < PROCESS_NUM; i++) {
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
	uint16_t privious_id = current_process_id;
	getCurrentPcb()->state = P_READY;
	do {
		current_process_id++;
		if(current_process_id>7) current_process_id = 1;
	} while(getCurrentPcb()->state != P_READY);
	getCurrentPcb()->state = P_RUNNING;

	// 没有发现其它处于就绪态的进程，返回内核
	// if(current_process_id == privious_id) {
	// 	goBackToKernel();
	// }
}

void initSubPcb(uint16_t sid) {
	pcb_table[sid].id = sid;
	pcb_table[sid].state = P_READY;  // 设置子进程为就绪态
	pcb_table[sid].regimg.ax = 0;    // 子进程的fork返回值=0
	pcb_table[sid].regimg.cx = getCurrentPcb()->regimg.cx;
	pcb_table[sid].regimg.dx = getCurrentPcb()->regimg.dx;
	pcb_table[sid].regimg.bx = getCurrentPcb()->regimg.bx;
	pcb_table[sid].regimg.sp = getCurrentPcb()->regimg.sp;
	pcb_table[sid].regimg.bp = getCurrentPcb()->regimg.bp;
	pcb_table[sid].regimg.si = getCurrentPcb()->regimg.si;
	pcb_table[sid].regimg.di = getCurrentPcb()->regimg.di;
	pcb_table[sid].regimg.ds = getCurrentPcb()->regimg.ds;
	pcb_table[sid].regimg.es = getCurrentPcb()->regimg.es;
	pcb_table[sid].regimg.fs = getCurrentPcb()->regimg.fs;
	pcb_table[sid].regimg.gs = getCurrentPcb()->regimg.gs;
	pcb_table[sid].regimg.ss = sid * 0x1000;  // 子进程的堆栈段
	pcb_table[sid].regimg.ip = getCurrentPcb()->regimg.ip;
	pcb_table[sid].regimg.cs = getCurrentPcb()->regimg.cs;
	pcb_table[sid].regimg.flags = getCurrentPcb()->regimg.flags;

	stack_length = 0xFE00 - pcb_table[sid].regimg.sp;
	from_seg = getCurrentPcb()->regimg.ss;
	to_seg = pcb_table[sid].regimg.ss;
}


void do_fork() {
	uint16_t sid = 1;  // 子进程ID
	for(sid = 1; sid < PROCESS_NUM; sid++) {
		if(pcb_table[sid].state == P_NEW) break;
	}
	if(sid >= PROCESS_NUM || sid <= 0) {
		getCurrentPcb()->regimg.ax = -1;  // fork失败，给父进程返回-1
	}
	else {
		getCurrentPcb()->regimg.ax = sid;  // fork成功，给父进程返回子进程ID
		initSubPcb(sid);  // 为子进程初始化PCB
		copyStack();      // 拷贝父进程的栈到子进程的栈
		pcb_table[sid].regimg.ax = 0;
		pcb_table[sid].id = current_process_id;
	}
}

void do_wait() {
	PCB* to_be_blocked = getCurrentPcb();
	pcbSchedule();
	to_be_blocked->state = P_BLOCKED;
}

void do_exit() {
	PCB* to_exit = getCurrentPcb();
	getCurrentPcb()->state = P_NEW;
	pcb_table[getCurrentPcb()->id].state = P_READY;
	pcbSchedule();
	to_exit->state = P_NEW;
}