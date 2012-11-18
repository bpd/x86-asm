
ORG	7C00h

;-------------------------------------------;
; Sector 1
;
; Load additional sectors, enter long mode,
; and then jump to loaded sectors
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

;AsciiOffset DB 48

long_start:

	;
	; [0B8000h] is mapped to video in long mode
	;
  
  mov rax, 'T E S T '     ; put a dummy value in rax
  mov [RaxStore], rax     ; save off the dummy value
	
	mov rax, 'R 8 : '       ; overwrite rax
	mov	[0B8000h], rax      
  
  mov rax, [RaxStore]     ; restore rax
  mov [0B8000h+20], rax
  
  mov rax, IOAPICVER
  
  
  ;mov al, 00ffh
  ;mov [0B8000h+8], al
	
RaxStore dq ?
	
times 7C00h+512*2 - $ db 000h  ; multiple of 512
