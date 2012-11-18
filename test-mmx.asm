;
; playing with MMX instructions
;
; Architectures Notes:
; MMX registers (mm0 - mm7) occupy the lower 64-bits of the 80-bit
; FPU registers... so they can't be used at the same time as the FPU.
;
; They allow SIMD (single instruction, multiple data) operations
;  on packed integers, so:
;
;   packed bytes: 8|8|8|8|8|8|8|8
;   packed words: 16|16|16|16
;   packed double words: 32|32
;
; Data can only be loaded to MMX registers through general purpose
; registers or from memory locations (you can't "mov mm0 42h")
;
; Some MMX instructions:
;   S (size): b = byte, w = word, d = double word, q = quad word
;
;   mov[b|w|d]    
;
;   padd[b|w|d]   add packed values
;   psub[b|w|d]   subtract packed values
;
;   padd[u*]s[b|w]    add packed values with signed/unsigned saturation
;   psub[u*]s[b|w]    subtract packed values with signed/unsigned saturation
;
;   pmul[h|l]w    signed multication of packed words, stores the
;                   high or low (h|l) words of the results in the dest operand
;
;  pmaddwd   performs a multiply of packed words and adds the four intermediate
;            double word products in pairs to produce results as a packed dword
;
;  pand
;  por
;  pxor
;
; pandn  logical negation of destinatino operand before performing and
;
; pcmpeq[b|w|d] compare for equality
;               sets destination operand bits to (1=equal  0=not equal)
;              
; pcmpgt[b|w|d] compare, 'greater than' 
;
; pack[u|s][wb,dw]  convert packed signed words/double words into packed
;                   signed/unsigned bytes
;
; psll[w|d|q] logical shift left of packed values
; psrl[w|d|q] logical shift right of packed values
; psra[w|d]   arithmetic shift of packed values
;
;     destination: MMX reg  source: MMX reg, 64-bit mem, 8-bit imm
; 
; 

format PE console
entry main

main:
  ; we can't load directly to an MMX 64-bit register,
  ; so we'll need to load up a general purpose 32-bit register,
  ; and then move it to the MMX register twice
  
  mov eax, dword 00420042h ; load eax with our value

  movd mm0, eax       ; and then move the value from eax to mm0 (lower dword)
  
  psllq mm0, 32       ; shift mm0 left by one dword
                      ; this pushes the 42h value we just loaded to the
                      ; higher dword so we can load the lower dword again
  
  ; we can't just movd another dword to mm0, since that
  ; will zero out the higher dword (apparently)...
  
  movd mm1, eax       ; so move the 42h to the lower dword of mm1
  
  por mm0,mm1         ; and then OR mm0 and mm1  (result goes in mm0)
  
  ; mm0 is now populated with 0042004200420042h  (four packed 42h words)
  
  ; now let's do some stuff to mm0
  ; first, let's add 2h to the two rightmost packed words
  
  mov eax, 00020002h    ; move value we're going to add into mm1 (through eax)
  movd mm1, eax
  
  paddw mm0, mm1        ; add mm1 to mm0

  mov eax, dword 1   ; set return value of main in eax (to 1)
  ret