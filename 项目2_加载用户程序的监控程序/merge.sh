#!/bin/bash

output_file="JedOS_v1.0.img"
asm_files=("bootloader" "oskernel" "stone_topleft" "stone_topright" "stone_bottomleft" "stone_bottomright")


rm -f ${output_file}

for asm_file in ${asm_files[@]}
do
	nasm ${asm_file}.asm -o ${asm_file}.img
    cat ${asm_file}.img >> "${output_file}"
    rm -f ${asm_file}.img
    echo "[+] ${asm_file} done"
done

echo "[+] ${output_file} generated successfully."