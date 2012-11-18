;
; playing with SSE instructions
;
; Architectures Notes:
; Streaming SIMD Extensions (SSE) registers (xmm0 - xmm7) are 128-bit
;  and separate from the FPU (unlike MMX registers).
;
; They allow SIMD (single instruction, multiple data) operations
;  on packed single-precision floating point (MMX just works on integers),
;  and (as of SSE2) integers.
;
; SSE supports a lot of the same instructions as the MMX registers.
; 
; 

format PE console
entry main

main:
  ; we can't load directly to an MMX 64-bit register,
  ; so we'll need to load up a general purpose 32-bit register,
  ; and then move it to the MMX register twice
  
  mov eax, dword 00420042h ; load eax with our value

  movd xmm0, eax       ; and then move the value from eax to mm0 (lower dword)
  
  psllq xmm0, 32       ; shift mm0 left by one dword
                      ; this pushes the 42h value we just loaded to the
                      ; higher dword so we can load the lower dword again
  
  ; we can't just movd another dword to mm0, since that
  ; will zero out the higher dword (apparently)...
  
  movd xmm1, eax       ; so move the 42h to the lower dword of mm1
  
  por xmm0,xmm1         ; and then OR mm0 and mm1  (result goes in mm0)
  
  ; mm0 is now populated with 0042004200420042h  (four packed 42h words)
  
  ; now let's do some stuff to mm0
  ; first, let's add 2h to the two rightmost packed words
  
  mov eax, 00020002h    ; move value we're going to add into mm1 (through eax)
  movd xmm1, eax
  
  paddw xmm0, xmm1        ; add mm1 to mm0

  mov eax, dword 1   ; set return value of main in eax (to 1)
  ret