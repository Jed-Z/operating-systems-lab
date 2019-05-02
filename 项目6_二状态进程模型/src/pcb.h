#ifndef _PCB_
#define _PCB_

#define MAX_PCB_NUMBER 8

typedef enum PCB_STATUS{PCB_READY, PCB_EXIT, PCB_RUNNING, PCB_BLOCKED} PCB_STATUS;

typedef struct Register{
	int ss;
	int gs;
	int fs;
	int es;
	int ds;
	int di;
	int si;
	int sp;
	int bp;
	int bx;
	int dx;
	int cx;
	int ax;
	int ip;
	int cs;
	int flags;
} Register;

typedef struct PCB{
	Register regs;
	PCB_STATUS status;
	int ID;
} PCB;

PCB PCB_LIST[MAX_PCB_NUMBER];

PCB *current_process_PCB_ptr;

int first_time;
int kernal_mode = 1;
int process_number = 0;
int current_seg = 0x1000;

int current_process_number = 0;

PCB *get_current_process_PCB() {
	return &PCB_LIST[current_process_number];
}

void save_PCB(int ax, int bx, int cx, int dx, int sp, int bp, int si, int di, int ds, int es, int fs, int gs, int ss, int ip, int cs, int flags) {
	current_process_PCB_ptr = get_current_process_PCB();
	
	current_process_PCB_ptr->regs.ss = ss;
	current_process_PCB_ptr->regs.gs = gs;
	current_process_PCB_ptr->regs.fs = fs;
	current_process_PCB_ptr->regs.es = es;
	current_process_PCB_ptr->regs.ds = ds;
	current_process_PCB_ptr->regs.di = di;
	current_process_PCB_ptr->regs.si = si;
	current_process_PCB_ptr->regs.sp = sp;
	current_process_PCB_ptr->regs.bp = bp;
	current_process_PCB_ptr->regs.bx = bx;
	current_process_PCB_ptr->regs.dx = dx;
	current_process_PCB_ptr->regs.cx = cx;
	current_process_PCB_ptr->regs.ax = ax;
	current_process_PCB_ptr->regs.ip = ip;
	current_process_PCB_ptr->regs.cs = cs;
	current_process_PCB_ptr->regs.flags = flags;
}

void schedule() {
	if (current_process_PCB_ptr->status == PCB_READY) {
		first_time = 1;
		current_process_PCB_ptr->status = PCB_RUNNING;
		return;
	}
	current_process_PCB_ptr->status = PCB_BLOCKED;
	current_process_number++;
	if (current_process_number >= process_number) current_process_number = 0;
	current_process_PCB_ptr = get_current_process_PCB();
	if (current_process_PCB_ptr->status == PCB_READY) first_time = 1;
	current_process_PCB_ptr->status = PCB_RUNNING;
	return;
}

void PCB_initial(PCB *ptr, int process_ID, int seg) {
	ptr->ID = process_ID;
	ptr->status = PCB_READY;
	ptr->regs.gs = 0x0B800;
	ptr->regs.es = seg;
	ptr->regs.ds = seg;
	ptr->regs.fs = seg;
	ptr->regs.ss = seg;
	ptr->regs.cs = seg;
	ptr->regs.di = 0;
	ptr->regs.si = 0;
	ptr->regs.bp = 0;
	ptr->regs.sp = 0x0100 - 4;
	ptr->regs.bx = 0;
	ptr->regs.ax = 0;
	ptr->regs.cx = 0;
	ptr->regs.dx = 0;
	ptr->regs.ip = 0x0100;
	ptr->regs.flags = 512;
}

void create_new_PCB() {
	if (process_number > MAX_PCB_NUMBER) return;
	PCB_initial(&PCB_LIST[process_number], process_number, current_seg);
	process_number++;
	current_seg += 0x1000;
}

void initial_PCB_settings() {
	process_number = 0;
	current_process_number = 0;
	current_seg = 0x1000;
}

#endif