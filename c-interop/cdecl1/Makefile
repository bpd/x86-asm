
default: cdecl

cdecl: cdecl.o cdecl_add.o
	gcc -m32 -Wall cdecl.o cdecl_add.o -o cdecl.exe

cdecl.o: cdecl.c
	gcc -m32 -Wall -c cdecl.c -o cdecl.o

cdecl_add.o: cdecl_add.asm
	fasm cdecl_add.asm cdecl_add.o

clean:
	rm cdecl.o cdecl_add.o cdecl.exe
