#!/bin/bash

rm -f *.o
rm -f *.bin
rm -f *.img

nasm bootloader.asm -o bootloader.bin
nasm -f elf32 oskernel.asm -o oskernel.o
nasm -f elf32 liba.asm -o liba.o
gcc -c -m16 -march=i386 -masm=intel -nostdlib -ffreestanding -mpreferred-stack-boundary=2 -lgcc -shared libc.c -o libc.o

ld -m elf_i386 -N -Ttext 0xA100 --oformat binary oskernel.o liba.o libc.o -o kernel.bin

cat bootloader.bin >> JedOS_v1.1.img
cat kernel.bin >> JedOS_v1.1.img

echo "[+] Done."

rm *.o
rm *.bin