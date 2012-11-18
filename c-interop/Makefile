
default: test-printf test-io

test-printf: test-printf.asm
	fasm test-printf.asm test-printf.exe

test-io: test-io.asm
	fasm test-io.asm test-io.exe

clean:
	rm test-io.exe test-printf.exe