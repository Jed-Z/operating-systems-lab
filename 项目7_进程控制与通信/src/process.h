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

PCB pcb_table[9];
extern uint16_t current_process_id;

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
		pcb_table[i].regimg.ds = i*0x1000;
		pcb_table[i].regimg.es = i*0x1000;
		pcb_table[i].regimg.fs = i*0x1000;
		pcb_table[i].regimg.gs = 0xB800;
		pcb_table[i].regimg.ss = i*0x1000;
		pcb_table[i].regimg.ip = 0;
		pcb_table[i].regimg.cs = i*0x1000;
		pcb_table[i].regimg.flags = 512;
	}
}

PCB* get_current_pcb() {
    return &pcb_table[current_process_id];
}

PCB* get_pcb_table() {
    return &pcb_table[0];
}

// uint16_t debugtest() {
//     return pcb_table[1].state;
// }

extern void powerOff();
void pcbSchedule() {
	get_current_pcb()->state = 1;
	do {
		current_process_id++;
		if(current_process_id>7) current_process_id = 1;
	} while(get_current_pcb()->state != 1);
	get_current_pcb()->state = 2;
}