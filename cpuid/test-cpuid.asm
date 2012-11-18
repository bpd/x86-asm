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

main:

  xor eax, eax        ; set eax to 0
  cpuid

  mov eax, dword 1   ; set return value of main in eax (to 1)
  ret