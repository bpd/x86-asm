;
;

format MS COFF

section '.text' code readable executable 

; note that we are exporting '_add' (as opposed to 'add', since apparently that
; is what the compiler translates the function definition to when it builds
; the symbol table while compiling 'cdecl.c'
;
public _add

; int32_t add( int32_t a, int32_t b )
;
_add:

  ; normally we would create an activation record / stack frame here,
  ; but since we're performing such a simple operation we can operate
  ; directly on 'esp'
  
  mov eax, dword [esp + 4] ; a
  mov ebx, dword [esp + 8] ; b
  
  add eax,ebx
  
  ; normally we tear down the activation record / stack frame here,
  ; but since we're performing a simple add it's not necessary

  ret
