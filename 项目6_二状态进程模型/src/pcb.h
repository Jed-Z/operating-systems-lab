/*
 * @Author: Jed
 * @Description: 进程控制块
 * @Date: 2019-04-21
 * @LastEditTime: 2019-04-27
 */
#ifndef _PCB_H_
#define _PCB_H_

#include <stdint.h>
#define MAX_PROCESS_NUM  8  // 支持的最大进程数

typedef struct RegisterImage{  // 逻辑CPU模拟
	uint16_t ss;     //0
	uint16_t gs;     //1
	uint16_t fs;     //2
	uint16_t es;     //3
	uint16_t ds;     //4
	uint16_t di;     //5
	uint16_t si;     //6
	uint16_t sp;     //7
	uint16_t bp;     //8
	uint16_t dx;     //9
	uint16_t cx;     //10
	uint16_t bx;     //11
	uint16_t ax;     //12
	uint16_t ip;     //13
	uint16_t cs;     //14
	uint16_t flags;  //15
} RegisterImage;

typedef enum PCBStatus {P_RUNNING, P_READY} PCBStatus;

typedef struct PCB {
	int id;           // 进程标识符
	RegisterImage regimg;  //逻辑CPU模拟
	PCBStatus status;      // 进程状态
} PCB;

int process_create(int progid);

#endif