;;;;;;;;;;;;;;;;;;;;;;;
;graphics mode
;;;;;;;;;;;;;;;;;;;;;;;

graphics_mode:
pusha

push ax
mov ah,0x00  ; int 0x10 /ah = 0x00 = set video mode

mov al,0x13 ; 320x200 , 256 color graphics mode

int 0x10
pop ax
mov ah,0x0C ; int 0x10 / ah = 0x0C write graphics pixel


suquare_draw:


;mov dx,80; row 
;mov cx,100 ; column
;mov al,0x00
;mov al,6
mov bh,0x00 ; page

mov si,cx
mov word [square_row],dx
add word [square_row],di

mov word [square_column],cx
add word [square_column],di

square:
; blue

 
int 0x10

inc cx ; column

cmp cx,word [square_column]
jne square

inc dx ;row
cmp dx,word [square_row]

je retgraphicsmode
mov cx,si
;inc al
;pusha
;mov ax,0x00
;int 0x16
;popa
jmp square

retgraphicsmode:

;mov ax,0x00
;int 0x16



popa
ret

;;;;;;;;;;;;;;;;;;;;;;;
;data
;;;;;;;;;;;;;;;;;;;;;;;

square_length: db   2  dup 0
square_row:  db 2   dup 0
square_column:   db 2  dup 0
