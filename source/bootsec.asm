


[ORG 0x7C00] 

;;;;;;;;;;;;;;;;;;;;;;;
;load filetable to memory  address 0x1000
;;;;;;;;;;;;;;;;;;;;;;;

mov bx,0x1000
mov es,bx
mov bx,0


mov dh,0 ;head 0
mov dl,0 ;0x00 for first floppy dsik , 0x80 for first hard drive
mov ch,0 ;cylinder 0
mov cl,8 ; starting sector to read from loadFromDisk

readfiletable:

mov ah,0x02 ;bios code funtion to read from disk/int 0x13

mov al,0x01 ;num of sectors to read

int 0x13 ; bios interrupt for disk services

jc readfiletable ;cary flag is set if error accured when read disk

;;;;;;;;;;;;;;;;;;;;;;;
;load kernel to memory  address 0x2000
;;;;;;;;;;;;;;;;;;;;;;;

mov bx,0x2000
mov es,bx
mov bx,0


mov dh,0 ;head 0
mov dl,0 ;0x00 for first floppy dsik , 0x80 for first hard drive
mov ch,0 ;cylinder 0
mov cl,2 ; starting sector to read from 

readkernel:

mov ah,0x02 ;bios code funtion to read from disk/int 0x13

mov al,6 ;num of sectors to read 

int 0x13 ; bios interrupt for disk services

jc readkernel ;cary flag is set if error accured when read disk

;;set up segment registers when we will jump to our kernel

mov ax,0x2000
mov ds,ax ;data segment
mov fs,ax ; extra segment
mov gs,ax
mov es,ax
mov ss,ax ;stack segment

jmp 0x2000:0


times 510-($-$$) db 0

dw  0xaa55
