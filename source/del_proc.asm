;;;;;;;;;;;;;;;;;;;;;;;
;process delete character
;;;;;;;;;;;;;;;;;;;;;;;
deleteProcess:

;cmp byte [bx-1],0
;je hshell

dec bx

mov byte [bx],0

;call newLine
;mov si,cmd
;call printn
;call newLine

mov ah,0x0e
mov al,0x0D
int 0x10

mov si,shellstr
call printn

mov si,cmd
call printn

mov ah,0x0e
mov al," "
int 0x10

ret
