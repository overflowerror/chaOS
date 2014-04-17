;; scheduler
;
; Because we want want to be able use multible thread, we need a scheduler.
; This scheduler is supposed to support up to 4 threads.
;
;;

;; global memory map
;
; $0000
;	G P R
; $001F
; $0020
;	I O R
; $005F
; $0060
;	SRAM
;	$0060
;		192 bytes of scheduler memory
;	$0102
;	$0103
;		15,680 bytes of heap
;	$3EFF
;	$3F00
;		512 bytes of stack
;	$40FF
; $40FF
;
;;
; this a ATmega1284P specific

.equ heap_start = 0x0103		; starting address of heap
.equ heap_end   = 0x3EFF		; ending address of heap

.equ scheduler_global_active = 0x0060	; address of active-thread-cell
.equ scheduler_global_number = 0x0061	; address of thread-number-cell
.equ scheduler_global_maxnum = 0x0004	; maximal number of thread
.equ scheduler_global_statu1 = 0x0062	; address of global-status-cell 1
.equ scheduler_global_statu2 = 0x0063	; address of global-status-cell 2
.equ scheduler_global_unused = 0x0064	; start address of unused block
.equ scheduler_global_thread = 0x006B	; starting address of scheduler memory
.equ scheduler_global_length = 0x0026	; length of thread in scheduler memory
.equ scheduler_global_lastad = 0x0102	; last address of scheduler memory
.equ scheduler_global_stacks = 0x3FFF	; start address of stacks

.equ scheduler_offset_stacks = 0x0080	; length of 1 stack
.equ scheduler_offset_instat = 0x0000	; offset of internal sr in scheduler memory
.equ scheduler_offset_instrh = 0x0001	; offset of iph in scheduler memory
.equ scheduler_offset_instrl = 0x0002	; offset of ipl in scheduler memory
.equ scheduler_offset_status = 0x0003	; offset of sr in scheduler memory
.equ scheduler_offset_stackh = 0x0004	; offset of sph in scheduler memory
.equ scheduler_offset_stackl = 0x0005	; offset of spl in scheduler memory
.equ scheduler_offset_gprsta = 0x0006	; start offset of gpr in scheduler momory
.equ scheduler_offset_gprend = 0x0025	; end offset of gpr in scheduler memory

;; scheduler memory
;
; We need to save the number of threads, the number of the active thread
; and some other things.
; For every thread we need to save:
;  - the instruction pointer (2 byte)
;  - the status register (1 byte)
;  - the stack pointer (2 byte)
;  - all 32 pgr
;  - plus 1 byte of status-values for the scheduler
; => 38 bytes -> $26; starting at $06B
; so: the sp of our thread x is calculated this way:
;   address = scheduler_global_thread + scheduler_global_length * x + scheduler_offset_stackp
;
;; scheduler memory map
;
; $060 active thread
; $061 number of threads
; $062 sr1 of scheduler
; $063 sr2 of scheduler
; // we still have 8 bytes of memory here
; $06B
;	thread 0
;	$06B internal sr
;	$06C iph
;	$06D ipl
;	$06E sr
;	$06F sph
;	$070 spl
;	$071
;		gpr
;	$090
; $090
; $091
;	thread 1
;	$091 internal sr
;	$092 iph
;	$093 ipl
;	$094 sr
;	$095 sph
;	$096 spl
;	$097
;		gpr
;	$0B6
; $0B6
; $0B7
;	thread 2
;	$0B7 internal sr
;	$0B8 iph
;	$0B9 ipl
;	$0BA sr
;	$0BB sph
;	$0BC spl
;	$0BD
;		gpr
;	$0DC
; $0DC
; $0DD
;	thread 3
;	$0DD internal sr
;	$0DE iph
;	$0DF ipl
;	$0E0 sr
;	$0E1 sph
;	$0E2 spl
;	$0E3
;		gpr
;	$102
; $102
; 
;
;; stacks
; 
; As we should support 4 threads, we need 4 stacks. 
; For the calculation of the stack space (see global memory map) I assumed that
; no stack will grow over 127 entries.
; Our initial stackpointer for thread x will be calculated this way:
;   address = schedulder_global_stacks + scheduler_offset_stacks * x
;
;;

SchedulerInit:
	push	r10
	in	r10,	sreg
	push	r10
	push	r11
	push	xl
	push	xh
	
	; first we'll clear all scheduler memory cells
	ldi	r10, 	0
	ldi	r11, 	low (scheduler_global_lastad)
	ldi	xl, 	low (scheduler_global_active)
	ldi	xh, 	high(scheduler_global_active)
	SchedulerInitLoop1: ; while(xl++ != r11)
		st	x+, 	r10
		cp	xl, 	r11
		brne	SchedulerInitLoop1
		
	; add main-thread
	call SchedulerAddThread
		
	; start scheduler timer
	; we will use timer0 because we don't use all posibilities of timer2
	; TODO
	
	pop	xh
	pop	xl
	pop	r11
	pop	r10
	out	sreg, 	r10
	pop	r10
	
	ret
	
SchedulerAddThread:

		
	ret
	
SchedulerChangeThread:
	; puh, that will get hard
	; first we have to get the current instruction pointer 
	
	push	xl
	push	xh
	push	r16
	in	r16,	sreg
	ldi	xl, 	low (scheduler_global_unused)
	ldi	xh, 	high(scheduler_global_unused)
	
	st	x+,	r16	; sreg is on unused[0]
	pop	r16
	st	x+, 	r16	; r16 is on unused[1]
	pop	r16
	st	x+,	r16	; xh is on unused[2]
	pop	r16
	st	x+,	r16	; xl is on unused[3]
	
	st	x+,	r17	; r17 is on unused[4]
	st	x+,	r18	; r18 is on unused[5]
	st	x+,	r19	; r19 is on unused[6]
	st	x+,	r20	; r19 is on unused[7]
	
	pop	r16	; epic win !!!!!111
	pop	r17	
	; instruction pointer high is now in r16; low in r17
	; next we have to determine where we have to store our data
	
	ldd	r18	scheduler_global_active
	; number of current thread is now in r18
	; now we have to determine the start address of our thread memory
	
	ldi	xl, 	low (scheduler_global_thread)
	ldi	xh, 	high(scheduler_global_thread)
	ldi	r19,	scheduler_global_length
	ldi	r20,	0
	
	SchedulerChangeThreadLoop1:
		cp	r20, 	r18
		breq 	SchedulerChangeThreadLoop1End
		; we can do the following, because the address can not be greater
		; than 0x00FF (as you can see in the scheduler memory map)
		add 	xl,	r19
		inc	r20
		jmp SchedulerChangeThreadLoop1
	SchedulerChangeThreadLoop1End:
	
	; x now contains the start address of our thread memory
	; let's copy some data
	
	; this is, because we don't want to modify the status register
	ld	r11,	x+
	
	; instruction pointer
	st	x+,	r16
	st	x+,	r17
	
	; we need the status register, it's saved in unused[0]
	ldd	r16,	scheduler_global_unused
	st	x+,	r16
	
	; so: the next step is the stack pointer
	in	r16,	sph
	st	x+,	r16
	in	r16,	spl
	st	x+,	r16
	
	; whew. next we have to save all the pgrs
	st	x+,	r0
	st	x+,	r1
	st	x+,	r2
	st	x+,	r3
	st	x+,	r4
	st	x+,	r5
	st	x+,	r6
	st	x+,	r7
	st	x+,	r8
	st	x+,	r9
	st	x+,	r10
	st	x+,	r11
	st	x+,	r12
	st	x+,	r13
	st	x+,	r14
	st	x+,	r15
	ldd	r16,	(scheduler_global_unused + 1)
	st	x+,	r16
	ldd	r16,	(scheduler_global_unused + 4)	; this is r17
	st	x+,	r16
	ldd	r16,	(scheduler_global_unused + 5)	; this is r18
	st	x+,	r16
	ldd	r16,	(scheduler_global_unused + 6)	; this is r19
	st	x+,	r16
	ldd	r16,	(scheduler_global_unused + 7)	; this is r20
	st	x+,	r16
	st	x+,	r21
	st	x+,	r22
	st	x+,	r23
	st	x+,	r24
	st	x+,	r25
	ldd	r16,	(scheduler_global_unused + 3)	; this is xl
	st	x+,	r16
	ldd	r16,	(scheduler_global_unused + 2)	; this is xh
	st	x+,	r16
	st	x+,	yl
	st	x+,	yh
	st	x+,	zl
	st	x+,	zh
	
	; soooo. we now have to get to know which is the next thread.
	; TODO:
	;   - (r18 contains the nr of the active thread)
	;   - r17 = scheduler_global_number
	;   - if r18 = r17 then r18 = 0 else r18++
	;   - cache ip
	;   - cache sr
	;   - replace sp
	;   - do the same game in the other direction :D
	;
	; I'll write that later. 
	
	ret