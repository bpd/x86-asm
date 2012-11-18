
void rex_prefix()
{
  /** some x86-64 instructions, all 3-byte (w/ REX prefix) */

                             /**REX      OPCODE   MOD/RM   */
  __asm__("mov %rax,%r8");   /* 01001001 10001001 11000000 */
                             /**                  ^^ register addressing mode */
                             /**^^^^     REX signature found in all REX bytes */
                             /**    ^    REX.w=1: 64-bit operands             */
                             /**       ^ REX.b=1: MODRM.rm targets r8-r15     */

  __asm__("mov %r8,%rax");   /* 01001100 10001001 11000000 */
                             /**         ^^^^^^^^ MOV r/m64,r64               */

  /** x86 instructions with 32-bit operands, all 2 bytes (no REX prefix) */

                             /**OPCODE   MOD/RM   */
  __asm__("mov %eax,%ebx");  /* 10001001 11000011 */
                             /**^^^^^^^^ MOV reg32,reg32                      */

                             /**OPCODE   IMMEDIATE (32-bit)   */
  __asm__("mov $0x1,%eax");  /* 10111000 00000001 00000000 00000000 00000000 */
                             /**^^^^^^^^ MOV reg32,imm32                      */
}

/**
 * move some values between general purpose registers
 */
void gpr_moves()
{
                             /**REX      OPCODE   MOD/RM   */
  __asm__("mov %rax,%rcx");  /* 01001000 10001001 11000001 */
                             /**^^^^     REX signature found in all REX bytes */
                             /**    ^    REX.w=1: 64-bit operands             */
                             /**       ^ REX.b=0: MODRM.rm targets rax-rdx    */
  __asm__("mov %rax,%rdx");  /* 01001000 10001001 11000010 */
  __asm__("mov %rax,%rbx");  /* 01001000 10001001 11000011 */
                             /**                  ^^ register addressing mode */
                             /**                       ^^^ MODRM.rm: dst=rbx  */
  
  __asm__("mov %rax,%r8");   /* 01001001 10001001 11000000 */
                             /**       ^ REX.b = 1:  MODRM.rm targets r8-r15  */
                             /**                       ^^^ MODRM.rm: dst=r8   */
  __asm__("mov %rax,%r9");   /* 01001001 10001001 11000001 */
                             /**                       ^^^ MODRM.rm: dst=r9   */
  /** ... r10-r14 ... */
  __asm__("mov %rax,%r15");  /* 01001001 10001001 11000111 */
                             /**                       ^^^ MODRM.rm: dst=r15  */
  
  __asm__("mov %r8,%rax");   /* 01001100 10001001 11000000 */
                             /**    ^    REX.w=1: 64-bit operand size is used */
                             /**     ^   REX.r=1: MODRM.reg targets r8-r15    */
  __asm__("mov %r9,%rax");   /* 01001100 10001001 11001000 */
                             /**                    ^^^ MODRM.reg: r9         */
  /** ... */
  __asm__("mov %r15,%rax");  /* 01001100 10001001 11111000 */
                             /*                     ^^^    */

  __asm__("mov %r8,%r9");    /* 01001101 10001001 11000001 */
                             /**    ^    REX.w=1: 64-bit operand size is used */
                             /**     ^   REX.r=1: MODRM.reg targets r8-r15    */
                             /**       ^ REX.b=1: MODRM.rm targets r8-r15     */
                             /**                    ^^^    MODRM.reg: r8      */
                             /**                       ^^^ MODRM.rm:  r9      */
}

void gpr_mem_moves()
{
                                  /**REX      OPCODE   MOD/RM   DISPLACEMENT  */
  __asm__("mov -0x1(%rax),%rbx"); /* 01001000 10001011 01011000 11111111 */
                                  /**                  ^^ 1-byte displacement */
                                  /**                       ^^^ MODRM.rm: rax */
                                  /**                    ^^^    MODRM.reg:rbx */
                                  
}

int main(int argc, const char* argv[] )
{
  return 1;
}