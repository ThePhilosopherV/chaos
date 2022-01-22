;;;;;
;;;;; machine code executor

call clearScreen
;;;;;;;  start code  ;;;;;;;
mov si,info_str
call printn

mov si,buffer
mov di,buffer
joker:
mov si,di
mov dx,0
ml:
call getchar

cmp al,"x"
je execute

cmp al,"q"
je quit

call pchar

cmp al,57
jle proc_num



sub al,87
cmp dx,1

je ml1
;xor bx,bx
;mov bl,al
;call printHex
c:
xor ah,ah
push ax

inc dx

jmp ml

ml1:

pop bx
shl bx,4
or al,bl

mov byte [si],al
inc si

;xor bx,bx
;mov bl,al
;call printHex

mov al," "
call pchar
mov dx,0
jmp ml

proc_num:
sub al,48
cmp dx,1

je ml1
jmp c

execute:
call newLine
mov si,exec_str

call printn
call pause

call clearScreen

call buffer

call newLine

mov si,q_str
call printn
;call newLine
mov si,back
call printn
call newLine

hh:
call getchar
cmp al,"q"
je quit1

cmp al,"b"
je joker

jmp hh

quit:
call newLine
mov si,quit_str
call printn
call pause
quit1:
call jtokernel






;;;;;;;;;;;;;;;;;;;;;;
;;;; include files
;;;;;;;;;;;;;;;;;;;;;;

%include "../functions/osfuncs.asm"

;;;;;;;;;;;;;;;;;;;;;;
;;;; data
;;;;;;;;;;;;;;;;;;;;;;
back:      db    "Press 'b' to write another program",0
exec_str:  db    "x: Press any key to execute...",0
quit_str:  db    "q: Press any key to quit...",0

info_str:   db   "Input machine code in hexadecimal", 0x0A,0x0D,\
                 "To execute type 'x' then enter", 0x0A,0x0D,
q_str:      db   "To quit type 'q' then enter", 0x0A,0x0D,0
buffer:     db      ""


times 1024-($-$$) db  0
