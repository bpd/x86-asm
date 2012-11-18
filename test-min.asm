;
; this is a minimal executable that is equivalent to:
;   int main()
;   {
;     return 1;
;   }

format PE console
entry main

main:
  mov eax, dword 1   ; set return value of main in eax (to 1)
  ret