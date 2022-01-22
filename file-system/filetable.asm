;;;; 
;;;; file table entries
;;;; ________                       _________
;;;; bytes                          purpose
;;;; ________                       _________
;;;; *               * bytes        File name                     
;;;; *               3 bytes        file type
;;;; n-3              1 bytes        "Directory entry", 0 based ,number of file table entries
;;;; n-2              1 bytes        Starting sector ,1 based
;;;; n-1              1 bytes        number of sectors
;;;;

db	"bootsec",0,"ins",0,00h,01h,01h
db  "kernel",0,"ins",0,00h,02h,06h
db  "filetable",0,"ent",0,00h,08h,01h
db  "program",0,"ins",0,00h,09h,02h
db  "mce",0,"ins",0,00h,0bh,02h
db  "editor",0,"ins",0,00h,0dh,04h
db  0xed
;
times 512-($-$$)  db 0
