

#ifndef MEM_H
#define MEM_H

#include <stdint.h>

typedef struct VirtualMemory
{
  void* (*alloc)( uint32_t length );
  
  void (*free)( void* addr, uint32_t length );
}
VirtualMemory;

void init_vm( VirtualMemory *vm );

// [kjit - OS]
#if defined(WINDOWS) || defined(__WINDOWS__) || defined(_WIN32) || defined(_WIN64)
# define KJIT_WINDOWS
#elif defined(__linux__)     || defined(__unix__)    || \
      defined(__OpenBSD__)   || defined(__FreeBSD__) || defined(__NetBSD__) || \
      defined(__DragonFly__) || defined(__BSD__)     || defined(__FREEBSD__) || \
      defined(__APPLE__)
# define KJIT_POSIX
#else
# warning "kjit - Can't match operating system, using KJIT_POSIX"
# define KJIT_POSIX
#endif


#endif