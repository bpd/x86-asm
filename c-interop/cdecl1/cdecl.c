
#include <stdio.h>
#include <stdint.h>

// 'extern' means that it is up to the linker to find
// the symbol (which will be in the object file created
// by assembling cdecl_add.asm)
//
// '_cdecl' declares the calling convention of 'add', which
// means the arguments are pushed to the stack in reverse order
// (so it would look something like 'push [b];  push [a]')
//
extern _cdecl int32_t add( int32_t a, int32_t b );

// main() simply calls our external function and prints the result
//
int main()
{
  int32_t result = add( 1, 2 );
  
  printf("result: %d", result);

  return 0;
}
