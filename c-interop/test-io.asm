format PE console
entry main

include 'macro/import32.inc'

section '.data' data readable writeable
msg db "hello world!",0
p db "pause>nul",0

section '.code' code readable executable

main:
int 3h        ; send debugger interrupt

push ebp      ; setup stack frame
mov ebp,esp
sub ebp,4     ; allocate 4 bytes on stack

mov dword [esp],msg  ; 
call [printf]

;mov dword [esp],p
;call [system]

mov dword [esp],0
call [exit]

section '.idata' import data readable

library msvcrt,'msvcrt.dll'
import msvcrt,\
       printf,'printf',\
       system,'system',\
       exit,'exit'