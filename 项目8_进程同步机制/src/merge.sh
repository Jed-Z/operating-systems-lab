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
nasm fork_test.asm -o ../temp/fork_test.bin
cd ..

cd lib
nasm -f elf32 systema.asm -o ../temp/systema.o
gcc -fno-pie -c -m16 -march=i386 -masm=intel -ffreestanding -mpreferred-stack-boundary=2 -shared systemc.c -o ../temp/systemc.o
cd ..

nasm -f elf32 osstarter.asm -o ./temp/osstarter.o
nasm -f elf32 liba.asm -o ./temp/liba.o
nasm -f elf32 multiprocess.asm -o ./temp/multiprocess.o
gcc -fno-pie -c -m16 -march=i386 -masm=intel -ffreestanding -mpreferred-stack-boundary=2 -shared kernel.c -o ./temp/kernel.o
ld -m elf_i386 -N -Ttext 0x8000 --oformat binary ./temp/osstarter.o ./temp/liba.o ./temp/kernel.o ./temp/systema.o ./temp/systemc.o ./temp/multiprocess.o -o ./temp/kernel.bin
rm ./temp/*.o

dd if=./temp/bootloader.bin of=JedOS_v1.6.img bs=512 count=1 2> /dev/null
dd if=./temp/usrproginfo.bin of=JedOS_v1.6.img bs=512 seek=1 count=1 2> /dev/null
dd if=./temp/kernel.bin of=JedOS_v1.6.img bs=512 seek=2 count=34 2> /dev/null
dd if=./temp/stone_topleft.bin of=JedOS_v1.6.img bs=512 seek=36 count=2 2> /dev/null
dd if=./temp/stone_topright.bin of=JedOS_v1.6.img bs=512 seek=38 count=2 2> /dev/null
dd if=./temp/stone_bottomleft.bin of=JedOS_v1.6.img bs=512 seek=40 count=2 2> /dev/null
dd if=./temp/stone_bottomright.bin of=JedOS_v1.6.img bs=512 seek=42 count=2 2> /dev/null
dd if=./temp/fork_test.bin of=JedOS_v1.6.img bs=512 seek=48 count=2 2> /dev/null


echo "[+] Done."