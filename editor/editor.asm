;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; This is not an editor 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


call clearScreen
mov ax,vidmem
mov es,ax

mov bx,0x0f00
mov si,mystr
mov ah,0x0e  

call writeto_vidmem
;mov si,word [mystr]

;mov [bx],si

;mov si,mystr

mov ax,0x8000
mov es,ax

mov cx,0
mov si,0
htop:
mov di,0
 ; this is gonna be used as counter for num of characters per each line 
h:
call getchar
cmp al,0x11
je quit

cmp al,0x13
je save

cmp al,0x08 ;process delete character
je proc_del

mov byte [buffer+di],al
inc di
inc cx

cmp al,0x0d
je printnewline

call pchar

jmp h

printnewline:
;mov bx,cx
;call printHex
dec cx
mov byte [cursor_line+si],cl
inc si
;mov bx,cx
;call printHex


mov byte [buffer+di],0x0A
inc di
mov cx,0

call newLine
call pchar
jmp h


quit:

call jtokernel




save:

;mov si,buffer
;call printn


mov ax,vidmem
mov es,ax
    
mov bx,0x0e60

mov si,save_str
mov ah,0x0e    

call writeto_vidmem

mov ax,0x8000
mov es,ax
; move cursor
mov ah,0x02    ;int 0x10 /AH = 0x02 :move cursor
mov bh,0    ;BH = display page (usually, if not always 0)
mov dh,23    ;DH = row
mov dl,len    ;DL = column
int 0x10    ;int 0x10


mov di,0
kkk:
call getchar

cmp al,0x11
je quit

cmp al,0x08
je savedelproc

cmp al,0x0D
je addfileto_filetable


mov byte [filename+di],al 
inc di
call pchar

jmp kkk

savedelproc:

cmp byte [filename] , 0 ;did  we delete all command characters ?
je kkk

dec di

mov byte [filename+di],0



mov ah,0x0e ;print a backspace which will move the cursor one char to the left
mov al,0x08
int 0x10

mov ah,0x0e ;print a space
mov al," "
int 0x10

mov ah,0x0e ;print a space which will move the cursor one char to the right
mov al,0x08
int 0x10



jmp kkk

proc_del:

cmp byte [buffer] , 0 ;did  we delete all command characters ?
je htop

dec di
dec cx
mov byte [buffer+di],0



mov ah,0x0e ;print a backspace which will move the cursor one char to the left
mov al,0x08
int 0x10

mov ah,0x0e ;print a space
mov al," "
int 0x10

mov ah,0x0e ;print a backspace which will move the cursor one char to the left
mov al,0x08
int 0x10

cmp byte [buffer+di-1],0x0d
je movecursortopreviousline

jmp h

movecursortopreviousline:
; Get Cursor Data

;    AH = 0x03
;    BH = display page (usually, if not always 0) 

;The return values:

;    CH = start scanline
;    CL = end scanline
;    DH = row
;    DL = column 
;push bx   ===============>here
mov ah,0x03
mov bh,0
int 0x10  ;returns dh=row , dl=column


dec di
mov byte [buffer+di],0

;mov bx,dx
;call printHex

mov ah,0x02    ;int 0x10 /AH = 0x02 :move cursor
mov bh,0    ;BH = display page (usually, if not always 0)
dec dh  ;DH = row

dec si
mov dl,byte [cursor_line+si]    ;DL = column
int 0x10    ;int 0x10



;call pause

jmp h


addfileto_filetable:


mov ax,0x1000
mov es,ax
mov ax,0

anotherlabelhere:

cmp byte [es:bx],0xed

je anotherfuckinglabel
inc bx
jmp anotherlabelhere

anotherfuckinglabel:
;;; now we're in the bottom of the file table,i know you liked the word bottom you sickkunt

mov dl,byte [es:bx-2] ; starting sector
mov dh,byte [es:bx-1] ;last file size

;push dx


mov si,filename

thisisnotalablemate:

lodsb

cmp al,0
je overthere

mov byte [es:bx],al
inc bx
jmp thisisnotalablemate

overthere:

mov byte [es:bx],0
add bx,1

mov word [es:bx],"da"
add bx,2

mov byte [es:bx],"t"
inc bx

mov word [es:bx],0x0000
add bx,2


;pop dx

;push dx
;mov bx,dx
;call printHex
;call pause

add dh,dl



mov byte [es:bx],dh
inc bx

mov byte [es:bx],0x01
inc bx

mov byte [es:bx],0xed

writefilecontentodisk:

;mov si,buffer
;call printn

;call pause
mov bx,0x8000
mov es,bx

lea bx,buffer;    ES:BX -> buffer

;call printHex

;call pause
;mov es,bx
;mov bx,0


mov ah,0x03;    Set AH = 2 to read , ah = 3 to write to disk
mov al,dl;    number of sectors
mov ch,0;    CH = cylinder & 0xff
mov cl,dh;    starting sector;
mov dh,0;    DH = Head -- may include two more cylinder bits

mov dl,0
int 0x13

jc writefilecontentodisk

;    Set DL = "drive number" -- typically 0x80, for the "C" drive
;    Issue an INT 0x13. 

;The carry flag will be set if there is any error during the read. AH should be set to 0 on success.

;To write: set AH to 3, instead. 
updatefiletableonthedisk:
mov bx,0x1000
mov es,bx
mov bx,0

mov ah,0x03;    Set AH = 2 to read , ah = 3 to write to disk
mov al,0x01;    number of sectors
mov ch,0;    CH = cylinder & 0xff
mov cl,0x06;    starting sector
mov dh,0;    DH = Head -- may include two more cylinder bits

mov dl,0
int 0x13

jc updatefiletableonthedisk


call jtokernel





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; include files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include  "../functions/osfuncs.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

vidmem:  equ    0x0B800
filename:  db  50  dup 0
cursor_line:   db 23  dup 0  ;cursor column num for everyline
counter:   db     0
mystr:  db   "^Press Ctrl+s to save the file     |    ^Press Ctrl+q to quit",0
save_str:  db   "Save file as (input file name then press enter): ",0
len: equ $-save_str-1

buffer:   db    ""


times 2048-($-$$) db 0


