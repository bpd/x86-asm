;-------------------------------------------;
; Project Kay Boot Loader
;
;
; References:
;  - http://wiki.osdev.org/Memory_Map_(x86)
;  - http://wiki.osdev.org/Detecting_Memory_(x86)
;  - http://www.sandpile.org/aa64/index.htm
;  - FreeForth: http://christophe.lavarenne.free.fr/ff/
;  - vga reference: http://www.brackeen.com/vga/basics.html
;
;-------------------------------------------;		

ORG	7C00h

;-------------------------------------------;
; Sector 1
;
; Load additional sectors, enter long mode,
; and then jump to loaded sectors
;
; References:
; AMD64 Architecture Programmer's Manual, Volume 2: System Programming, page 361
; Thread discussing 'quick long mode': http://forum.osdev.org/viewtopic.php?f=1&t=11093
;   ^^ resulting code: http://wiki.osdev.org/Entering_Long_Mode_Directly
;
;
; Overview of what I may want to do in real mode:
; - memory detection
; - setup default video mode
; - start other CPUs
; - obtain CPU capabilities/features/bugs
; - detect NUMA areas
; 
;
;-------------------------------------------;

USE16

boot:
; Parameter from BIOS: dl = boot drive

	; set default state
	cli
	xor	ax, ax
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0x7C00
	;sti
	;jmp load_sectors ; clear cs

load_sectors:
	mov	ax, 0x0201		; ah = Function 0x02 ; al = Number of sectors
	xor	bx, long_start	; Offset to read into (zero because it is cleared)
	mov cx, 0x0002		; ch = track to read ; cl = sector to read
	xor	dh, dh			; Head to read (0)
						; dl = Drive to read, we want to read from the drive we loaded from,
						;      which is passed in from bios
	int 0x13

pm_init:
	cli
	lgdt	[cs:GDTR]		; load GDT register

	mov	eax,cr0 		; switch to protected mode
	or	al,1
	mov	cr0,eax

	jmp	CODE_SELECTOR:pm_start



NULL_SELECTOR = 0
DATA_SELECTOR = 1 shl 3 		; flat data selector (ring 0)
CODE_SELECTOR = 2 shl 3 		; 32-bit code selector (ring 0)
LONG_SELECTOR = 3 shl 3 		; 64-bit code selector (ring 0)

GDTR:					; Global Descriptors Table Register
  dw 4*8-1				; limit of GDT (size minus one)
  dq GDT				; linear address of GDT

GDT rw 4				; null desciptor
    dw 0FFFFh,0,9200h,08Fh		; flat data desciptor
    dw 0FFFFh,0,9A00h,0CFh		; 32-bit code desciptor
    dw 0FFFFh,0,9A00h,0AFh		; 64-bit code desciptor

	USE32

pm_start:

	mov	eax,DATA_SELECTOR	; load 4 GB data descriptor
	mov	ds,ax			; to all data segment registers
	mov	es,ax
	mov	fs,ax
	mov	gs,ax
	mov	ss,ax

	mov	eax,cr4
	or	eax,1 shl 5
	mov	cr4,eax 		; enable physical-address extensions

	mov	edi,70000h
	mov	ecx,4000h shr 2
	xor	eax,eax
	rep	stosd			; clear the page tables

	mov	dword [70000h],71000h + 111b ; first PDP table
	mov	dword [71000h],72000h + 111b ; first page directory
	mov	dword [72000h],73000h + 111b ; first page table

	mov	edi,73000h		; address of first page table
	mov	eax,0 + 111b
	mov	ecx,256 		; number of pages to map (1 MB)

make_page_entries:
	stosd
	add	edi,4
	add	eax,1000h
	loop	make_page_entries

	mov	eax,70000h
	mov	cr3,eax 		; load page-map level-4 base

	mov	ecx,0C0000080h		; EFER MSR
	rdmsr
	or	eax,1 shl 8		; enable long mode
	wrmsr

	mov	eax,cr0
	or	eax,1 shl 31
	mov	cr0,eax 		; enable paging

	jmp	LONG_SELECTOR:long_start


times 7C00h+510 - $ db 000h			;fill up to the boot record signature

dw 0xAA55




;-------------------------;
; Sector 2
;
; Assumes that we are in long mode
;
;-------------------------;


USE64

long_start:

	;
	; apparently 0B8000h is mapped to video in long mode
	;
	
	mov rax, 'L O N G '
	mov	[0B8000h], rax
	
	mov r8,'M O D E '	
	mov	[0B8000h+10],r8
	
	mov r10, 15
	mov r11, 14
	
	cmp r10, r11
	je  when_equal
	jl  when_less
	jle when_less_equal
	jg  when_greater
	jge when_greater_equal
	
	fall_through:
		mov rax, '? ? ? '
		mov	[0B8000h+20], rax
		jmp after_comparison
	
	when_equal:
		mov rax, 'A = B '
		mov	[0B8000h+20], rax
		jmp after_comparison
		
	when_less:
		mov rax, 'A < B '
		mov	[0B8000h+20], rax
		jmp after_comparison
		
	when_less_equal:
		mov rax, 'A < = B '
		mov	[0B8000h+20], rax
		jmp after_comparison
		
	when_greater:
		mov rax, 'A > B '
		mov	[0B8000h+20], rax
		jmp after_comparison
	
	when_greater_equal:
		mov rax, 'A > = B '
		mov	[0B8000h+20], rax
		jmp after_comparison

	after_comparison:
		mov rax, 'D O N E '
		mov	[0B8000h+40], rax
	
	; VGA Text Example
	; Text Buffer:
	;   Attribute       Character
	; 7 6 5 4 3 2 1   7 6 5 4 3 2 1
	; ^                             blink
	;   ^^^^^                       background color
	;         ^^^^^                 foreground color
	;                 ^^^^^^^^^^^^^ code point
	
	;mov ah, 00001111b
	;mov al, 'H'
	;mov [0B8000h+20], ax

	
	




	 mov	al,10001b		; begin PIC 1 initialization
	 out	20h,al
	 mov	al,10001b		; begin PIC 2 initialization
	 out	0A0h,al
	 mov	al,80h			; IRQ 0-7: interrupts 80h-87h
	 out	21h,al
	 mov	al,88h			; IRQ 8-15: interrupts 88h-8Fh
	 out	0A1h,al
	 mov	al,100b 		; slave connected to IRQ2
	 out	21h,al
	 mov	al,2
	 out	0A1h,al
	 mov	al,1			; Intel environment, manual EOI
	 out	21h,al
	 out	0A1h,al
	 in	al,21h
	 mov	al,11111100b		; enable only clock and keyboard IRQ
	 out	21h,al
	 in	al,0A1h
	 mov	al,11111111b
	 out	0A1h,al

	 xor	edi,edi 		; create IDT (at linear address 0)
	 mov	ecx,21

make_exception_gates: 		; make gates for exception handlers
	 mov	esi,exception_gate
	 movsq
	 movsq
	 loop	make_exception_gates
	 mov	ecx,256-21

make_interrupt_gates: 		; make gates for the other interrupts
	 mov	esi,interrupt_gate
	 movsq
	 movsq
	 loop	make_interrupt_gates

	 mov	word [80h*16],clock	; set IRQ 0 handler
	 mov	word [81h*16],keyboard	; set IRQ 1 handler

	 lidt	[IDTR]			; load IDT register

	 sti				; now we may enable the interrupts

; main_loop:

	; mov	rax,'L O N G '
	; mov	[0B8000h],rax

	; jmp	main_loop


 IDTR:					; Interrupt Descriptor Table Register
   dw 256*16-1				; limit of IDT (size minus one)
   dq 0					; linear address of IDT

 exception_gate:
   dw exception and 0FFFFh,LONG_SELECTOR
   dw 8E00h,exception shr 16
   dd 0,0

 interrupt_gate:
   dw interrupt and 0FFFFh,LONG_SELECTOR
   dw 8F00h,interrupt shr 16
   dd 0,0

 exception:				; exception handler
	 in	al,61h			; turn on the speaker
	 or	al,3
	 out	61h,al
	 jmp	exception		; repeat it until reboot

 interrupt:				; handler for all other interrupts
	 iretq

 clock:
	 inc	byte [0B8000h+2*80]	; make the ticks appear
	 push	rax
	 mov	al,20h
	 out	20h,al
	 pop	rax
	 iretq

 keyboard:
	 push	rax
	 in	al,60h
	 cmp	al,1			; check for Esc key
	 ;je	reboot
   
    mov	rax,'T E S T '
	  mov	[0B8000h],rax
   
	 mov	[0B8000h+2*(80+1)],al	; show the scan key
	 in	al,61h			; give finishing information
	 out	61h,al			; to keyboard...
	 mov	al,20h
	 out	20h,al			; ...and interrupt controller
	 pop	rax
	 iretq

; reboot:
	; mov	al,0FEh
	; out	64h,al			; reboot computer
	; jmp	reboot


; For floppy emulation the image needs to be
; exactly 1474560 bytes, but it seems that
; for most emulators it just needs to be a
; multiple of 512

times 7C00h+512*2 - $ db 000h

