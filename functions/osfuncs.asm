
;;;;;;;;;;;;;;;;;;;;;;;
;bios print null terminated string ;string parameter passed to si
;;;;;;;;;;;;;;;;;;;;;;;
printn: 
pusha

mov ah,0x0e ;function code to display a character  

printLoop:

lodsb
cmp al,0
je retprintLoop


int 0x10 ;bios video service

jmp printLoop
retprintLoop:
popa
ret
;;;;;;;;;;;;;;;;;;;;;;;
;print hex representation of an integer,integer should be in bx
;;;;;;;;;;;;;;;;;;;;;;;

printHex:
pusha

mov ah,0x0e
mov al,"0"
int 0x10

mov ah,0x0e
mov al,"x"
int 0x10

mov cl,0

mov dx,bx
printHexhead:

mov bx,dx

shl bx,cl
shr bx,12

cmp bx,9
jg alphab

add bx,48

mov ah,0x0e
mov al,bl
int 0x10

cmp cl,12
je retprintHex


add cl,4
jmp printHexhead
alphab:

add bx,87

mov ah,0x0e
mov al,bl
int 0x10

cmp cl,12
je retprintHex

add cl,4
jmp printHexhead

retprintHex:
popa
ret


;;;;;;;;;;;;;;;;;;;;;;;
;bios print new line
;;;;;;;;;;;;;;;;;;;;;;;
newLine:
pusha
mov ah,0x0e
mov al,0x0A
int 0x10

mov ah,0x0e
mov al,0x0D
int 0x10
popa
ret

;;;;;;;;;;;;;;;;;;;;;;;
;compare two strings ,string addresses are in bx,si
;;;;;;;;;;;;;;;;;;;;;;;
cmpstr:

lodsb


;call newLine
;mov ah,0x0e
;mov al,byte []
;int 0x10



cmp al,byte [bx]
jne noteq

checkNullByte:
cmp al,0

je retcmpstr
inc bx
jmp cmpstr
noteq:
mov al,1

ret
retcmpstr:
mov al,0

ret

;;;;;;;;;;;;;;;;;;;;;;;
;clear screen using text mode
;;;;;;;;;;;;;;;;;;;;;;;


clearScreen:
pusha

mov ah,0x00  ;code for video mode function
mov al,0x3 ; 80x25 , 16 color text mode :video mode  ,will clear the screen as well
int 0x10 ; bios video service

;;change bodrer color, change background color

mov ah,0x0B
mov bh,0x0 ;change background color
mov bl,0x4 ;black
int 0x10


popa
ret

;;;;;;;;;;;;;;;;;;;;;;;
;zeros cmd variable
;;;;;;;;;;;;;;;;;;;;;;;

fillcmdzeros:
pusha
;;fill cmd variable with zeros

mov cx,50
l1:
;cmp byte [cmd],0
;je ret_fillcmdzeros

mov byte [bx],0
inc bx

loop l1


ret_fillcmdzeros:
popa
ret

;;;;;;;;;;;;;;;;;;;;;;;
;display file table
;;;;;;;;;;;;;;;;;;;;;;;

displayft: ;

pusha

mov bx,0x1000
mov es,bx
mov bx,0

fb:

call newLine


mov dx,1
f:
mov al,[es:bx]

cmp al,0xed
je ret_dft

mov ah,0x0e
int 0x10

inc bx

cmp al,0
jne f

cmp dx,0
je prnt_hexvalues
mov al,"|"
int 0x10
mov dx,0
jmp f

prnt_hexvalues:
push ax
mov ah,0x0e
mov al,"|"
int 0x10
pop ax

push bx
xor bx,bx
mov bl,al
call printHex
pop bx

inc bx
inc dx
mov al,[es:bx]
cmp dx,3

je fb
jmp prnt_hexvalues

ret_dft:
popa
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;load program from file table;to memory address 0x8000; and jump to execute
;filename is in si
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load_file:

pusha
add cx,2

mov di,0x1000
mov es,di
mov di,0

;cx has command length
aids:
mov dx,0

push si

lfh:

mov al,byte [si]
mov bl,byte [es:di]

cmp bl,0xed
je ret_lf

inc di
inc si
inc dx
cmp al,bl
je lfh


;xor bx,bx
;mov bl,byte [es:di+4]
;call printHex

;jmp $
cmp cx,dx
je load_tomem

lk:

cmp byte [es:di],0
je hj
inc di
jmp lk
hj:

add di,8


pop si
jmp aids

load_tomem:


;jmp $
mov cl,byte [es:di+4] ; starting sector to read from loadFromDisk
mov al,byte [es:di+5] ;num of sectors to read

mov bx,0x8000
mov es,bx
mov bx,0

mov dh,0 ;head 0
mov dl,0 ;0x00 for first floppy dsik , 0x80 for first hard drive
mov ch,0 ;cylinder 0


mov ah,0x02 ;bios code funtion to read from disk/int 0x13

int 0x13 ; bios interrupt for disk services

jc load_tomem

mov ax,0x8000
mov ds,ax ;data segment
mov fs,ax ; extra segment
mov gs,ax
mov es,ax
mov ss,ax ;stack segment

jmp 0x8000:0

ret_lf:
pop si
popa
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;jump to kernel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

jtokernel:
pusha

mov ax,0x2000
mov ds,ax ;data segment
mov fs,ax ; extra segment
mov gs,ax
mov es,ax
mov ss,ax ;stack segment

jmp 0x2000:0

popa
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;pause and continue after a character is pressed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pause:

pusha
mov ax,0
int 0x16

popa
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;get character from stdin,char will be in al
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getchar:
mov ax,0
int 0x16
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;print char , chat should be in al
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pchar:

mov ah,0x0e
int 0x10

ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;write to video memory (text mode)
;bx :offset to write to
;si: string address
;ah: color
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

writeto_vidmem:      ;[mystr]     ;character
pusha      

mov di,0
mloop:

mov al,byte[si]    ;yellow

mov word [es:bx],ax

inc si
add bx,2
cmp byte [si],0
jne mloop

popa
ret

;;;;;;;;;;;;;;;;;;;;;;
;;;load file to memory address 0x8000
;;;;;;;;;;;;;;;;;;;;;;

load_f:

pusha
add cx,2

mov di,0x1000
mov es,di
mov di,0

;cx has command length
aidss:
mov dx,0

push si

lfhh:


mov al,byte [si]
mov bl,byte [es:di]


;mov al,bl
;call pchar

;call pause

cmp bl,0xed
je ret_file_notfound

inc di
inc si
inc dx
cmp al,bl
je lfhh


;xor bx,bx
;mov bl,byte [es:di+4]
;call printHex

;jmp $
cmp cx,dx
je load_tomemo

lkk:

cmp byte [es:di],0
je hjj
inc di
jmp lkk
hjj:

add di,8


pop si
jmp aidss

load_tomemo:



;jmp $
mov cl,byte [es:di+4] ; starting sector to read from loadFromDisk
mov al,byte [es:di+5] ;num of sectors to read

mov bx,0x8000
mov es,bx
mov bx,0

mov dh,0 ;head 0
mov dl,0 ;0x00 for first floppy dsik , 0x80 for first hard drive
mov ch,0 ;cylinder 0


mov ah,0x02 ;bios code funtion to read from disk/int 0x13

int 0x13 ; bios interrupt for disk services

jc load_tomemo

;mov ax,0x8000
;mov ds,ax ;data segment
;mov fs,ax ; extra segment
;mov gs,ax
;mov es,ax
;mov ss,ax ;stack segment

;jmp 0x8000:0

ret_f:

pop si
popa
ret

ret_file_notfound:
pop si
popa
call newLine
mov si,filenotf
call printn
ret

filenotf:    db    "File not found",0
;;;;;;;;;;;;;;;;;;;;
test:
pusha
mov al,"T"
call pchar
call pause
popa
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;ascii to integer procedure
;;;;;atohex(es:bx > pointer to string hex )
;;;;;return value in dx/dh ; 
atohex:

push di
push cx
push ax

mov di,48
mov cx,2

pargbyte:
mov ax,87
mov dl,byte [es:bx]

cmp dl,57
cmovbe ax,di
sub dl,al

;pusha


;xor bx,bx
;mov bl,dl
;call printHex
;call pause

;popa

cmp cx,1
je con
shl dx,12
inc bx


loop pargbyte

con:
or dl,dh
xor dh,dh

pop ax
pop cx
pop di

ret


;;;;;;;;;;;;;;;;;;;;;;;
;print hex representation of an integer,integer should be in bx ;  output in format :  0xYY
;;;;;;;;;;;;;;;;;;;;;;;

printHexOneByte:
pusha

mov ah,0x0e
mov al,"0"
int 0x10

mov ah,0x0e
mov al,"x"
int 0x10

mov cl,8

mov dx,bx
printHexOneBytehead:

mov bx,dx

shl bx,cl
shr bx,12

cmp bx,9
jg alphabOneByte

add bx,48

mov ah,0x0e
mov al,bl
int 0x10

cmp cl,12
je retprintHexOneByte


add cl,4
jmp printHexOneBytehead
alphabOneByte:

add bx,87

mov ah,0x0e
mov al,bl
int 0x10

cmp cl,12
je retprintHexOneByte

add cl,4
jmp printHexOneBytehead

retprintHexOneByte:
popa
ret
