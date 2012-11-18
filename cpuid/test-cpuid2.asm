;
; CPUID
;
; the 'cpuid' instructions tells us a little about the processor,
; so we know whether the processor supports more advanced instructions
;
; the basic interface is:
;  - set the 'level' of cpuid that you want executed in eax
;  - after execution the GPRs will be filled with strings
; 
; example:
;   on my machine, setting eax=0 populates these registers:
;      eax 00000001      (maximum supported standard level)
;      ebx 68747541      => h t u A
;      edx 69746e65      => i t n e
;      ecx 444d4163      => D M A c
;                        => "AuthenticAMD"
;
; Settings 
;
; (full details: http://www.sandpile.org/x86/cpuid.htm)
;

format PE console
entry main

include 'macro/import32.inc'

;============================================
section '.data' data readable writeable

msg db "cpuid: %s",0

cpu_string db 13 dup 0  ; create room for a 12-character null-terminated string

;============================================
section '.code' code readable executable

main:

  ; execute cpuid instruction
  ;
  xor eax, eax        ; set eax to 0
  cpuid
  
  ; build string of CPUID result in 'cpu_string' storage
  ; defined above
  
  ; move ebx,edx,ecx registers to 'cpu_string' memory location
  ; 
  ; Note: the byte order will be reversed when the register
  ;       is copied to memory, so:
  ;
  ;       ebx = 68 74 75 41   ( h t u A => 'Auth' of 'AuthenticAMD' )
  ;
  ;       becomes:
  ;       [some-mem-loc] = 41 75 74 68   ( A u t h )
  ;
  mov dword [cpu_string],ebx
  mov dword [cpu_string+4],edx
  mov dword [cpu_string+8],ecx
  
  ; call prologue
  push ebp       ; save the value of ebp
  mov ebp, esp   ; ebp now points to the top of the stack
  sub esp, 8     ; allocate space on the stack for locals

  ; setup args for printf and call
  mov dword [esp + 4], cpu_string  ; arg 2 of printf
  mov dword [esp], msg             ; arg 1 of printf
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
       printf,'printf',\
       system,'system',\
       exit,'exit'
