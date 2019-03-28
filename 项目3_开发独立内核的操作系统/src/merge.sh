#!/bin/bash
rm -rf temp
mkdir temp
rm *.img

nasm bootloader.asm -o ./temp/bootloader.bin
nasm usrproginfo.asm -o ./temp/usrproginfo.bin

cd usrprog
nasm stone_topleft.asm -o ../temp/stone_topleft.bin
nasm stone_topright.asm -o ../temp/stone_topright.bin
nasm stone_bottomleft.asm -o ../temp/stone_bottomleft.bin
nasm stone_bottomright.asm -o ../temp/stone_bottomright.bin
cd ..

nasm -f elf32 oskernel.asm -o ./temp/oskernel.o
nasm -f elf32 liba.asm -o ./temp/liba.o
gcc -c -m16 -march=i386 -masm=intel -nostdlib -ffreestanding -mpreferred-stack-boundary=2 -lgcc -shared libc.c -o ./temp/libc.o
ld -m elf_i386 -N -Ttext 0x8000 --oformat binary ./temp/oskernel.o ./temp/liba.o ./temp/libc.o -o ./temp/kernel.bin
rm ./temp/*.o

dd if=./temp/bootloader.bin of=JedOS_v1.1.img bs=512 count=1 2>/dev/null
dd if=./temp/usrproginfo.bin of=JedOS_v1.1.img bs=512 seek=1 count=1 2>/dev/null
dd if=./temp/kernel.bin of=JedOS_v1.1.img bs=512 seek=2 count=16 2>/dev/null
dd if=./temp/stone_topleft.bin of=JedOS_v1.1.img bs=512 seek=18 count=2 2>/dev/null
dd if=./temp/stone_topright.bin of=JedOS_v1.1.img bs=512 seek=20 count=2 2>/dev/null
dd if=./temp/stone_bottomleft.bin of=JedOS_v1.1.img bs=512 seek=22 count=2 2>/dev/null
dd if=./temp/stone_bottomright.bin of=JedOS_v1.1.img bs=512 seek=24 count=2 2>/dev/null

echo "[+] Done."