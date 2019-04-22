/*
 * @Author: Jed
 * @Description: 进程控制块
 * @Date: 2019-04-21
 * @LastEditTime: 2019-04-22
 */
#ifndef _PCB_H_
#define _PCB_H_

#include <stdint.h>
#define MAX_PROCESS_NUM  8  // 支持的最大进程数

typedef struct RegisterImage{
	uint16_t ss;
	uint16_t gs;
	uint16_t fs;
	uint16_t es;
	uint16_t ds;
	uint16_t di;
	uint16_t si;
	uint16_t sp;
	uint16_t bp;
	uint16_t bx;
	uint16_t dx;
	uint16_t cx;
	uint16_t ax;
	uint16_t ip;
	uint16_t cs;
	uint16_t flags;
} RegisterImage;

typedef enum PCBStatus {P_RUNNING, P_READY} PCBStatus;
typedef struct PCB {
	uint16_t pid;          // 进程标识符
	RegisterImage regImg;  //逻辑CPU模拟
	PCBStatus status;      // 进程状态
} PCB;
PCB PCB_list[MAX_PROCESS_NUM];  // 进程控制块表

#endif