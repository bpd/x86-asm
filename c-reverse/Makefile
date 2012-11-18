
default: cpuid jit mov

jit: mem.c jit.c
	gcc -Wall mem.c jit.c -o jit.exe

cpuid: cpuid.c
	gcc -Wall cpuid.c -o cpuid.exe

mov: mov.c
	gcc -Wall mov.c -o mov.exe

clean:
	rm jit.exe cpuid.exe mov.exe
  