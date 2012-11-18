
#include "mem.h"

static volatile int64_t alignment = -1;
static volatile int64_t page_size;

static uint64_t round_up(uint64_t base)
{
  uint64_t over = base % page_size;
  return base + (over > 0 ? page_size - over : 0);
}

// Implementation is from "Hacker's Delight" by Henry S. Warren, Jr.,
// figure 3-3, page 48, where the function is called clp2.
static uint64_t next_power_of_2(uint64_t base)
{
  base -= 1;

  base = base | (base >> 1);
  base = base | (base >> 2);
  base = base | (base >> 4);
  base = base | (base >> 8);
  base = base | (base >> 16);

  // assume 64-bit
  base = base | (base >> 32);

  return base + 1;
}

#ifdef KJIT_WINDOWS

  /** Window Memory Manager **/

  #include <windows.h>

  static void init_vm_system()
  {
    SYSTEM_INFO info;
    GetSystemInfo(&info);
    
    alignment = info.dwAllocationGranularity;
    page_size = next_power_of_2(info.dwPageSize);
  }

  void* vm_alloc( uint32_t length )
  {
    if( alignment == -1 )
    {
      init_vm_system();
    }
    // VirtualAlloc rounds allocated size to page size automatically.
    uint64_t msize = round_up(length);

    // Windows XP SP2 / Vista allows Data Excution Prevention (DEP).
    return VirtualAlloc(NULL,
                        msize, 
                        MEM_COMMIT | MEM_RESERVE,
                        PAGE_EXECUTE_READWRITE);
  }

  void vm_free( void* addr, uint64_t length )
  {
    VirtualFree(addr, 0, MEM_RELEASE);
  }


#else

  /** POSIX Memory Manager **/

  #include <sys/types.h>
  #include <sys/mman.h>
  #include <unistd.h>

  // MacOS uses MAP_ANON instead of MAP_ANONYMOUS
  #ifndef MAP_ANONYMOUS
  # define MAP_ANONYMOUS MAP_ANON
  #endif

  static void init_vm_system()
  {
    alignment = page_size = getpagesize();
  }

  void* vm_alloc( uint32_t length )
  {
    if( alignment == -1 )
    {
      init_vm_system();
    }
    uint64_t msize = round_up(length, page_size);
    
    return mmap(NULL,
                msize,
                PROT_READ | PROT_WRITE | PROT_EXEC,
                MAP_PRIVATE | MAP_ANONYMOUS,
                -1,
                0 );
  }

  void vm_free( void* addr, uint64_t length )
  {
    munmap(addr, length);
  }
  
  
#endif
