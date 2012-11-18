
default: test-cpuid test-cpuid2 test-cpuid3

test-cpuid: test-cpuid.asm
	fasm test-cpuid.asm test-cpuid.exe

test-cpuid2: test-cpuid2.asm
	fasm test-cpuid2.asm test-cpuid2.exe

test-cpuid3: test-cpuid2.asm
	fasm test-cpuid3.asm test-cpuid3.exe

clean:
	rm test-cpuid.exe test-cpuid2.exe test-cpuid3.exe