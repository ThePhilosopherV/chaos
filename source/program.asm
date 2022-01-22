


call newLine
mov si,progstr
call printn

mov ah,00
int 0x16

mov ax,0x2000
mov ds,ax ;data segment
mov fs,ax ; extra segment
mov gs,ax
mov es,ax
mov ss,ax ;stack segment

jmp 0x2000:0

;;;;;;include files;;;;;;
%include "../functions/osfuncs.asm"

;;;;;;;data;;;;;
progstr: db  "Program loaded successfully",0

times 1024-($-$$)  db 0
