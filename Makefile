
default: test-min test-mmx test-sse1

test-min: test-min.asm
	fasm test-min.asm test-min.exe

test-mmx: test-mmx.asm
	fasm test-mmx.asm test-mmx.exe

test-sse1: test-sse1.asm
	fasm test-sse1.asm test-sse1.exe

clean:
	rm test-min.exe test-mmx.exe test-sse1.exe