;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;si   has the command address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
asm:
pusha

;call getchar

mov bx,0
;;;; is the assembler being called ?
asm_hloop:
lodsb

cmp al,[asm_command+bx]
jne jll

inc bx
jmp asm_hloop

jll:
cmp bx,3

je ccb
jmp asm_ret

checkspaces:

lodsb


ccb: ;;;;;; skip spaces
inc bx
cmp al,space

je checkspaces

cmp al,0
je noarg_error ;;;; asm cmd with no arg, rise err
;;;;;;;;;;; lets check if file exists in filetable
sub cx,bx

mov bx,cx
inc cx
;call printHex
;call pause
dec si

;call printn

;call pause

call load_f
;mov cx,10

;fgho:
mov bx,0x8000
mov es,bx
mov bx,0



;line counter
;;;;;;;;;;;; lets process  our dear source file
skip_spacesonfirstline:

cmp byte [es:bx],space

jne checkinst
inc bx

jmp skip_spacesonfirstline

checkinst:

mov si,mov_in
;call printn

mov cx,0
;;;;;;;;;;;;;;is it  mov in ? mov instruction processing
movinstl:

lodsb

cmp al,byte [es:bx]

jne checkvald

inc bx
inc cx
jmp movinstl

checkvald:

cmp cx,3
je pmov
;;;;;;;;;;;;;;;;;
;process other instructions 




;;;;;;;;;;;;;;;;;
jmp asm_ret


pmov:
;;;;;;;;;;;; here we're sure it is a mov ins
;lets  skip spaces

mov cx,0
skip_spacess:

cmp byte [es:bx],space

jne check_inst
inc bx
inc cx
jmp skip_spacess



check_inst:
cmp cx,0

je error ; mov only ? rise er



;;;;;;;;;;;;;;check register
mov si,registers
mov di,0
mov cx,16

.loly:
mov ax,word [registers + di]
cmp  word [es:bx],ax
je p_al
add di,2
loop .loly

jmp badargerror

p_al:

add bx,2

skip_spaces_al:

cmp byte [es:bx],space

jne check_in_al
inc bx

jmp skip_spaces_al              

check_in_al:
cmp byte [es:bx],","
jne error




inc bx
skip_spaces_al_aftecomma:

cmp byte [es:bx],space

jne check_in_al_arg
inc bx

jmp skip_spaces_al_aftecomma

check_in_al_arg:

cmp word [es:bx],"0x"
je arg_hex_proc
;;;;;;;here process arg as hex

arg_hex_proc:


add bx,2

push bx
mov si,0
hell:
xor cx,cx

xor ax,ax

checkifvalidhex:

cmp byte [es:bx],48
jl afterhell

cmp byte [es:bx],102
jg afterhell


cmp byte [es:bx],57
cmovbe ax,[one]

cmp byte [es:bx],97
cmovge cx,[one]

add ax,cx

cmp ax,0

je afterhell

inc bx
inc si

cmp si,4
jg afterhell

jmp hell

afterhell:
;;;;;;;;;;;lets check that after the arg there is nothing
cmp si,0
je badargerror
looks:

cmp byte [es:bx],space

jne alife
inc bx

jmp looks

alife:
;skip new lines 
;check if 
cmp byte [es:bx],0x0D
je good_inst


cmp byte [es:bx],0

je good_inst


jmp badargerror
;good_inst1:

;mov byte [endofprog],1
;mov ah,1
good_inst:


;xor bx,bx
;mov bl,byte [endofprog]
;call printHex
;call pause
;;;;;;;;;;;;;;;; lets decide if the arg is 2 or 4 bytes

xor dx,dx
mov ax,di
mov cx,2
div cx
mov bx,ax

mov di,ax
pop bx

cmp di,7
jg ptwobytes

;mov bx,si
;call printHex
;call pause
cmp si,2
jg arglenerror

;call test
;;;;;;;start of processing one byte arg
;push dx
;push di
;pusha
push bx

;call test
call atohex

;mov bx,dx
;call printHex
;call pause
;jmp asm_ret

xor bx,bx
mov bl,byte [offsetcounter]

add di,0xb0
mov ax,di
;call printHex
;call pause
;mov ax,di ; ax  has first byte

  
mov byte [buffer+bx],al
inc bx
mov  byte [buffer+bx],dl
inc bx

mov byte [offsetcounter],bl

pop bx

add bx,2
jmp aaa
;mov bx,offsetcounter
;inc bx
;add offsetcounter,1

;xor bx,bx
;mov bl,byte [buffer]
;call printHex

;mov bl,byte [buffer+1]
;call printHex

;xor bx,bx
;mov bl,byte [buffer+1]
;call printHex

;mov bl,byte [buffer+1]
;call printHex

;call pause


;xor bx,bx
;xor ah,ah
;mov bx,ax
;call printHex
;call pause



;;;;;;;start of processing two bytes arg


ptwobytes:

mov cx,2
add bx,2



push bx
xor bx,bx
mov bl,byte [offsetcounter]

add di,0xb0
mov ax,di
;call printHex
;call pause
;mov ax,di ; ax  has first byte

  
mov byte [buffer+bx],al
inc bx
mov ax,bx


pop bx
cocksbecauewhynot:

;call printHex
call atohex
push bx
mov bx,ax
mov  byte [buffer+bx],dl
inc bx

mov byte [offsetcounter],bl
mov ax,bx

pop bx
cmp cx,0
je aaa0
sub bx,3

loop cocksbecauewhynot
aaa0:
add bx,6
aaa:

;;;;;;;;;;;was this the last instruction



cmp byte [es:bx],0x0D

je inc_lcounter

cmp byte [es:bx],0
je prog_end

cmp byte [es:bx],space
je sksp

;;;;;;;;;next instruction
;mov al,byte [es:bx]
;call pchar

jmp checkinst

inc_lcounter:
add byte [linecounter],1   
add bx,2
jmp aaa

sksp:
inc bx
jmp aaa

;;;;;;;;;

prog_end:
;call test
call newLine
xor cx,cx

mov cl,byte [offsetcounter]
xor di,di
ph:

xor bx,bx
mov bl,byte [buffer+di]
call printHexOneByte
mov al,space
call pchar
inc di
loop ph

jmp asm_ret
;mov bx,ax
;call printHex
;call pause


;xor bx,bx
;mov bl,byte [buffer]
;call printHex

;mov bl,byte [buffer+1]
;call printHex

;mov bl,byte [buffer+2]
;call printHex

;call pause


arglenerror:

mov si,lener
call newLine


call printn
mov al,[linecounter]
add al,48
call pchar

jmp asm_ret


badargerror:
;pop bx
mov si,arg_er
call newLine


call printn
mov al,[linecounter]
add al,48
call pchar

jmp asm_ret



error:
mov si,er_msg
call newLine


call printn
mov al,[linecounter]
add al,48
call pchar

jmp asm_ret

noarg_error:
mov si,noargs_error_str
call newLine
call printn



asm_ret:
;reset variables
mov byte [linecounter],1

mov byte [offsetcounter],0
;offset:   db  50 dup   0 

mov cx,0

resetbuffer:
mov bx,cx
mov byte [buffer+bx],0
inc cx
cmp cx,500
jne resetbuffer

popa
ret


one:   dw  0x01
two:    dw  0x02

asm_command:    db   "asm"
space:  equ      " "
;filename:   db  50 dup   0
noargs_error_str:   db    "Missing file name argument",0
mov_in:   db    "mov"
er_msg:    db    "Error in line ",0

arg_er:    db   "Instruction arg error in line ",0
lener:  db  "Instruction Arg length error in line ",0

registers:  db "al" ;b0
            db "cl"
            db "dl"
            db "bl"
            db "ah" 
            db "ch"
            db "dh"
            db "bh"
            db "ax"
            db "cx"
            db "dx"
            db "bx"
            db "sp"
            db "bp"
            db "si"
            db "di";bf
            
;;;;;;;;variables;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;endofprog:  db      0
linecounter:       db       1            
offsetcounter:   db   0
;offset:   db  50 dup   0            
buffer:   db   500 dup   0    




















