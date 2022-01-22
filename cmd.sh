#!/bin/bash
cd source &&
nasm bootsec.asm -fbin -o ../bootsec.bin  && 
nasm kernel.asm -fbin -o ../kernel.bin &&
nasm program.asm -fbin -o ../program.bin &&
cd .. &&
nasm file-system/filetable.asm -fbin -o filetable.bin &&
cd tools &&
nasm mce.asm -fbin -o ../mce.bin  &&
cd ../editor &&

nasm editor.asm -fbin -o ../editor.bin &&
cd .. &&

cat bootsec.bin kernel.bin filetable.bin program.bin mce.bin editor.bin  > tmp.bin &&
dd if=/dev/zero of=os.img bs=512 count=2880 &&
dd if=tmp.bin of=os.img conv=notrunc &&

rm -f *.bin  &&
qemu-system-x86_64  -fda os.img  

