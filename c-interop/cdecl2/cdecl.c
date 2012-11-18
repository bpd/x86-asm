
#include <stdio.h>
#include <stdint.h>

extern _cdecl int32_t add( int32_t a, int32_t b, int32_t c );


_cdecl void say_hello( int32_t val )
{
  printf("Called from assembly: %d \n", val);
}

// main() simply calls our external function and prints the result
//
int main()
{
  int32_t result = add( 1, 2, 3 );
  
  printf("result: %d", result);

  return 0;
}
