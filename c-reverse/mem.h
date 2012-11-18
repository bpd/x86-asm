#ifndef MEM_H
#define MEM_H

#include <stdint.h>


void* vm_alloc( uint32_t length );

void vm_free( void* addr, uint64_t length );


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
