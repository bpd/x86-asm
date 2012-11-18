/**
 * 
 * http://wiki.osdev.org/X86-64_Instruction_Encoding
 *
 * some discussion on function perilogues:
 * http://homepage.ntlworld.com/jonathan.deboynepollard/FGA/function-perilogues.html
 *
 * Discussion of LuaJIT design:
 * http://www.reddit.com/r/programming/comments/badl2/luajit_2_beta_3_is_out_support_both_x32_x64/c0lrus0
 *
 * Intel 80386 Reference Programmer's Manual:
 * http://pdos.csail.mit.edu/6.828/2010/readings/i386/toc.htm
 *
 * Overview of x86-64:
 * http://x86asm.net/articles/x86-64-tour-of-intel-manuals/
 *
 *
 * x86-64 added eight additional general purpose registers:
 *
 * r8 through r15
 *  r8d, r8w, r8b (lower 32-bit double-word, 16-bit word, 8-bit byte)
 *
 *
 * Architectures Notes:
 * Streaming SIMD Extensions (SSE) registers (xmm0 - xmm7) are 128-bit
 *  and separate from the FPU (unlike MMX registers).
 * xmm8 through xmm15
 *
 */

/**
 * Some quick notes about Intel vs AT&T/UNIX assembly syntax:
 *
 * GCC uses AT&T assembly syntax
 *
 * 1. Source-Destination Ordering
 *      Intel syntax: opcode dst src
 *      AT&T syntax:  opcode src dst
 *
 * 2. Register names are prefixed by %, i.e. eax is written %eax
 *
 * 3. Immediate Operands
 *      Intel: 23h
 *      AT&T:  $0x23
 *
 * 4. Operand Size.
 *    In AT&T syntax the size of memory operands is determined from the last 
 *    character of the op-code name. Op-code suffixes of ’b’, ’w’, and ’l’ 
 *    specify byte(8-bit), word(16-bit), and long(32-bit) memory references. 
 *    Intel syntax accomplishes this by prefixing memory operands 
 *    (not the op-codes) with ’byte ptr’, ’word ptr’, and ’dword ptr’.
 *
 *      Intel: mov al, byte ptr foo 
 *      AT&T:  movb foo, %al
 *
 * 5. Memory Operands.
 *    In Intel syntax the base register is enclosed in ’[’ and ’]’ where as in 
 *    AT&T they change to ’(’ and ’)’. Additionally, in Intel syntax an indirect 
 *    memory reference is like
 * 
 *      Intel: section:[base + index*scale + disp]
 *      AT&T:  section:disp(base, index, scale)
 * 
 *    One point to bear in mind is that, when a constant is used for disp/scale, 
 *    ’$’ shouldn’t be prefixed.
 *
 */
 
/**
 * x86-64 (AMD64/Intel 64/x64) Registers
 *
 * General Purpose:
 * =============================
 * 64-bit lower32 lower16 lower8
 * ====== ======= ======= ======
 * rax    eax     ax      al
 * rbx    ebx     bx      bl
 * rcx    ecx     cx      cl
 * rdx    edx     dx      dl
 * rsi    esi     si      sil
 * rdi    edi     di      dil
 * rbp    ebp     bp      bpl    base pointer, holds current stack frame address
 * rsp    esp     sp      spl    stack pointer, points to top of the stack
 * r8     r8d     r8w     r8b
 * r9     r9d     r9w     r9b
 * r10    r10d    r10w    r10b
 * r11    r11d    r11w    r11b
 * r12    r12d    r12w    r12b
 * r13    r13d    r13w    r13b
 * r14    r14d    r14w    r14b
 * r15    r15d    r15w    r15b
 *
 * xmm0-xmm15 are 128-bit SIMD (Single Instruction Multiple Data) registers
 *
 *   The MMX implementation (pre-SSE) on x86 'shared' the MMX registers with
 *     the FPU, so it required a lot of careful coding to make sure SIMD
 *     instructions weren't stepping on floating point values.
 *   SSE corrected this and made each xmm register distinct from any other
 *     processing unit.
 * 
 *                  ============================= =======
 *                  64-bit lower32 lower16 lower8 higher8
 *                  ======|=======|=======|======|=======
 * General Purpose        |       |
 * ===============        |       |
 * A,B,C,D          R?X   |E?X    |?X     |?H    | ?L
 * R8 - R15         ?     |?D     |?W     |?B    |
 *                        |       |       |      |
 * Segment                |                      |
 * =======                |
 * C,D,S,E,F,G            |       |?S     |      |
 *
 * Pointer                |       |       |      |
 * =======                |       |       |      |
 * S B              R?P   |E?P    |?P     | ?PL  |
 *
 *
 * Index Register
 * S,D              R?I    E?I     ?I       ?IL
 *
 * Instr Pointer
 * I                R?P    E?P     ?P 
 * 
 */
 
 /**
 * REX Prefix Byte
 *
 * enables 64-bit specific features
 *
 *   7                           0
 * +---+---+---+---+---+---+---+---+
 * | 0   1   0   0 | w | r | x | b |
 * +---+---+---+---+---+---+---+---+
 *
 * REX.w
 *  w=0: default operand size (32-bit for most but not all instructions)
 *  w=1: 64-bit operand size is used
 *
 * REX.r is an extension to the MODRM.reg field
 *   REX.r=0: MODRM.rm targets rax-rdx
 *   REX.r=1: MODRM.rm targets r8-r15
 *
 * REX.x is an extension to the SIB.index field
 *
 * REX.b is an extension to the MODRM.rm field or the SIB.base field
 *   when used to extend the MODRM.rm field:
*      REX.b=0: MODRM.rm targets rax-rdx
 *     REX.b=1: MODRM.rm targets r8-r15
 *
 */

/**
 * MOD-REG-R/M Byte
 * 
 *   7                           0
 * +---+---+---+---+---+---+---+---+
 * |  mod  |    reg    |     rm    |
 * +---+---+---+---+---+---+---+---+
 *
 * MODRM.mod (2 bits)
 * MODRM.reg (3 bits)
 * MODRM.rm  (3 bits)
 *
 * mod
 * 00   Register indirect addressing mode or SIB with no displacement
 *      (when R/M = 100) or Displacement only addressing mode (when R/M = 101)
 * 01   One-byte signed displacement follows addressing mode byte(s)
 * 10   Four-byte signed displacement follows addressing mode byte(s)
 * 11   Register addressing mode
 *
 * reg
 * The reg field can have one of two values:
 *  - a 3-bit opcode extension
 *  - a 3-bit register reference
 *
 * rm
 * The rm field, combined with mod, specifies either
 *  - the second operand in a two-operand instruction, OR
 *  - the only operand in a single-operand instruction like NOT or NEG
 *
 * The 'd' bit in the opcode determines which operand is the source and
 *   which is the destination:
 *
 *  d=0: MOD R/M <- REG      ,REG is the source
 *  d=1: REG     <- MOD R/M  ,REG is the destination
 *
 */