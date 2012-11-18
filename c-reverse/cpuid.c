
/**
 *
 * Sources: http://en.wikipedia.org/wiki/CPUID
 *          AsmJit: X86CpuInfo.h/cpp
 *
 */
 
#include <stdio.h>
#include <stdint.h>
#include <string.h>

void encode_cpuid()
{
  __asm__("cpuid");	/* 0x0f  0xa2 */
}

typedef struct
{
  uint32_t eax;
  uint32_t ebx;
  uint32_t ecx;
  uint32_t edx;
}
x86CpuId;

/**
 * CPU Info (and feature flags)
 *
 * IN: cpuid with EAX=1
 * OUT: EAX      <- stepping, model, family, etc
 *      ECX, EDX <- feature flags
 *      EBX      <- additional feature info
 *
 */
typedef struct
{
  uint32_t stepping;      /* eax[3:0]  */
  uint32_t model;         /* eax[7:4]  */
  uint32_t family;        /* eax[11:8] */
  uint32_t processorType; /* eax[13:12]*/
  uint32_t extendedModel; /* eax[19:16]*/
  uint32_t extendedFamily;/* eax[27:20]*/
}
x86CpuInfo;

void cpuid(int32_t param, x86CpuId *regs)
{
  
  regs->eax = param;
  __asm__ volatile (
    "mov %%ebx, %%edi;"   /* save ebx to edi */
    "cpuid;"              /* call cpuid, which overwrites ebx */
    "mov %%ebx, %%esi;"   /* move the cpuid->ebx to esi */
    "mov %%edi, %%ebx;"   /* move the saved ebx in edi back to ebx */
   : "+a"(regs->eax),          /* a is input/output (+) */
     "=S"(regs->ebx),          /* we stashed ebx in the instruction pointer (=S) */
     "=d"(regs->edx),"=c"(regs->ecx)/* edx and ecx are where we would expect them */
   :                      /* no separate output registers (+a is in/out)*/
   : "edi"                /* we clobbered edi so preserve ebx */
  );
}

/**
 * cpuid call with EAX=0: Get Vendor ID
 *
 * in: EAX=0
 * out: EBX,EDX,ECX <- VendorID
 *      EAX         <- Highest cpuid calling parameter
 * 
 * "AMDisbetter!" - early engineering samples of AMD K5 processor
 * "AuthenticAMD" - AMD
 * "CentaurHauls" - Centaur
 * "CyrixInstead" - Cyrix
 * "GenuineIntel" - Intel
 * "TransmetaCPU" - Transmeta
 * "GenuineTMx86" - Transmeta
 * "Geode by NSC" - National Semiconductor
 * "NexGenDriven" - NexGen
 * "RiseRiseRise" - Rise
 * "SiS SiS SiS " - SiS
 * "UMC UMC UMC " - UMC
 * "VIA VIA VIA " - VIA
 * "Vortex86 SoC" - Vortex
 *
 */
void cpu_vendorid(uint32_t *highest_param, char *vendor)
{
  /* the registers, in order they will be populated with vendor id */
  x86CpuId regs;
  cpuid( 0, &regs );
  
  memcpy( vendor, &regs.ebx, 4 );
  memcpy( vendor+4, &regs.edx, 4 );
  memcpy( vendor+8, &regs.ecx, 4 );
  
  *highest_param = regs.eax;
  vendor[12] = 0;
}

void cpu_info(x86CpuInfo *cpu)
{
  x86CpuId regs;
  
  cpuid( 1, &regs );
  
  //printf("%#x", regs.eax);
  
  cpu->stepping = regs.eax & 0x0f;
  cpu->model    = (regs.eax >> 4) & 0x0f;
  cpu->family   = (regs.eax >> 8) & 0x0f;
  
  // use extended family and model fields
  if( cpu->family == 0x0f )
  {
    cpu->family += (regs.eax >> 20) & 0xff;
    cpu->model += ((regs.eax >> 16) & 0xff) << 4;
  }
  
  // Note: 64-bit CPUs have the 'longmode-capable' bit, EDX[29] turned on
  
}


int main()
{
  uint32_t highest_param;
  char vendor[13];
  x86CpuInfo cpu;
  
  cpu_vendorid( &highest_param, vendor );
  
  printf("vendor: %s\n", vendor);
  printf("Highest EAX calling parameter: %#x \n", highest_param);
  
  cpu_info( &cpu );
  
  printf(" stepping: %d  model: %d   family: %d \n", cpu.stepping, cpu.model, cpu.family );
  
  //check_cpuid();
  
  return 1;
}
