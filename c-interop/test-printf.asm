;
; Calling printf() from the standard C library
;

format PE console
entry main

include 'macro/import32.inc'

;============================================
section '.data' data readable writeable

msg db "Hello World",0

;============================================
section '.code' code readable executable

main:
  
  ; call prologue
  push ebp      ; save the value of ebp
  mov ebp,esp   ; ebp now points to the top of the stack
  sub esp,4     ; allocate space on the stack for locals

  ; setup args for printf and call
  mov dword [esp],msg              ; 
  call [printf]
  
  ; call epilogue
  mov esp,ebp  ; remove local variable space, revert esp to its old value
  pop ebp      ; restore old value of ebp

  mov eax, dword 1   ; set return value of main in eax (to 1)
  ret

;============================================
section '.idata' import data readable

library msvcrt,'msvcrt.dll'

import msvcrt,\
       printf,'printf'
