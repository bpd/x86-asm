
#include <stdio.h>
#include <string.h>

#include "mem.h"

/**
From Intel's Optimisation Reference Manual:
"Assembler/Compiler Coding Rule 40. (ML impact, M generality)
 Avoid using complex instructions (for example, enter, leave, or loop) that
 have more than 4 uops and require multiple cycles to decode. 
 Use sequences of simple instructions instead.

 Complex instructions may save architectural registers, but incur a penalty
 of 4 uops to set up parameters for the microcode ROM."
**/
static const char fun_buf[] = {
  0x55,                           /* push %rbp */
  0x48, 0x89, 0xe5,               /* mov %rsp,%rbp */
                                  /* no locals (no rsp sub) */
  0xb8, 0x01, 0x00, 0x00, 0x00,   /* mov $0x1,%eax */
                                  /* no locals (no rsp add) */
  0x5d,                           /* pop %rbp */
  0xc3                            /* retq */
};


int ret_one(void)
{
  return 1;
}

void print_value(int i)
{
  printf("the value is: %d", i);
}
 
int main(int argc, char** argv)
{
  //print_value(2);
  //print_value(3);
  
  VirtualMemory vm;
  
  init_vm( &vm );
  uint32_t code_length = sizeof(fun_buf);
  
  void* code_mem = vm.alloc( code_length ); // allocate 4k of writable/executable memory
  
  memcpy( code_mem, fun_buf, code_length );
  
  int (*ret_one_ptr)(void) = (void*)code_mem;
  
  int i = ret_one();
  printf("the value is: %d", i);
  
  i = ret_one_ptr();
  printf("the value is: %d", i);
  
  vm.free( code_mem, code_length );

  return 0;
}