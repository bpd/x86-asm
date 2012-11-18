;
;

format MS COFF

section '.text' code readable executable 

; note that we are exporting '_add' (as opposed to 'add', since apparently that
; is what the compiler translates the function definition to when it builds
; the symbol table while compiling 'cdecl.c'
;
public _add


extrn _say_hello

; int32_t add( int32_t a, int32_t b, int32_t c )
;
_add:
  
  ; load our three values into registers
  mov eax, dword [esp + 4]   ; a
  mov ebx, dword [esp + 8]   ; b
  mov ecx, dword [esp + 12]  ; c
  
  sub esp, 4     ; grow our stack frame to include local
  
  ; sum the values, store the result in the local
  add eax,ebx
  add eax,ecx
  mov dword [esp], eax  ; save eax to local stack space
  
  ; prologue: call say_hello( summed_value )
  ;
  push ebp      ; save the value of ebp
  mov ebp, esp  ; ebp now points to the top of the stack
  sub esp, 4    ; grow stack for our argument (one 32-bit value)
  
    ; setup arguments and call
    mov dword [esp], eax     ; arg 1 => summed value (still in eax)
    call _say_hello
  
  ; epilogue: call say_hello( summed_value )
  mov esp,ebp  ; remove local variable space, revert esp to its old value
  pop ebp      ; restore old value of ebp
  
  ; who knows what the external function did with eax,
  ; so restore it from the stack
  mov eax, [esp]
  
  add esp, 4    ; shrink stack to remove space for local

  ret
