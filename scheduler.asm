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
;	external I O R
; $00FF
; $0100
;	SRAM
;	$0100
;		164 bytes of scheduler memory
;	$01A3
;	$01A4
;		15,710 bytes of heap
;	$3EFF
;	$3F00
;		512 bytes of stack
;	$40FF
; $40FF
;
;;
; this a ATmega1284P specific

.equ heap_start = 0x01A3		; starting address of heap
.equ heap_end   = 0x3EFF		; ending address of heap

.equ scheduler_global_active = 0x0100	; address of active-thread-cell
.equ scheduler_global_number = 0x0101	; address of thread-number-cell
.equ scheduler_global_maxnum = 0x0004	; maximal number of thread
.equ scheduler_global_statu1 = 0x0102	; address of global-status-cell 1
.equ scheduler_global_statu2 = 0x0103	; address of global-status-cell 2
.equ scheduler_global_unused = 0x0104	; start address of unused block
.equ scheduler_global_thread = 0x010B	; starting address of scheduler memory
.equ scheduler_global_length = 0x0026	; length of thread in scheduler memory
.equ scheduler_global_lastad = 0x0142	; last address of scheduler memory
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
; $0100 active thread
; $0101 number of threads
; $0102 sr1 of scheduler
; $0103 sr2 of scheduler
; // we still have 8 bytes of memory here
; $010B
;	thread 0
;	$010B internal sr
;	$010C iph
;	$010D ipl
;	$010E sr
;	$010F sph
;	$0110 spl
;	$0111
;		gpr
;	$0130
; $0130
; $0131
;	thread 1
;	$0131 internal sr
;	$0132 iph
;	$0133 ipl
;	$0134 sr
;	$0135 sph
;	$0136 spl
;	$0137
;		gpr
;	$0156
; $0156
; $0157
;	thread 2
;	$0157 internal sr
;	$0158 iph
;	$0159 ipl
;	$015A sr
;	$015B sph
;	$015C spl
;	$015D
;		gpr
;	$017C
; $017C
; $017D
;	thread 3
;	$017D internal sr
;	$017E iph
;	$017F ipl
;	$0180 sr
;	$0181 sph
;	$0182 spl
;	$0183
;		gpr
;	$01A2
; $01A2
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
	SchedulerInitLoop0: ; while(xl++ != r11)
		st	x+, 	r10
		cp	xl, 	r11
		brne	SchedulerInitLoop0
		
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
	
	pop	r16	; the later item in the stack is high
	pop	r17	; the earlier one is low
	; epic win !!!!!111
	; instruction pointer high is now in r16; low in r17
	; next we have to determine where we have to store our data
	
	ldd	r18	scheduler_global_active
	; number of current thread is now in r18
	; now we have to determine the start address of our thread memory
	
	ldi	xl, 	low (scheduler_global_thread)
	ldi	xh, 	high(scheduler_global_thread)
	ldi	r19,	scheduler_global_length
	ldi	r20,	0
	
	SchedulerChangeThreadLoop0:	; while (r20++ != r18)
		cp	r20, 	r18
		breq 	SchedulerChangeThreadLoop0End
		; we can do the following, because the address can not be greater
		; than 0x00FF (as you can see in the scheduler memory map)
		add 	xl,	r19
		inc	r20
		jmp SchedulerChangeThreadLoop0
	SchedulerChangeThreadLoop0End:
	
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
	
	; r18 contains the nr of the active thread
	; we now increment r18 (because we want the next thread)
	inc 	r18
	
	ldd	r17,	(scheduler_global_number)
	; r17 now containes the number of threads
	
	; if r17 equals r18 our calculated next thread number is too high
	cpi	r17,	r18
	brne	SchedulerChangeThreadHop0	; if (r17 == r18)
		ldi	r18,	0
	SchedulerChangeThreadHop0:
	
	; so now we'll try to calculate the position of the scheduler memory
	; for thread [insert number in r18]
	
	ldi	xl, 	low (scheduler_global_thread)
	ldi	xh, 	high(scheduler_global_thread)
	ldi	r19,	scheduler_global_length
	ldi	r20,	0
	
	SchedulerChangeThreadLoop1:	; while (r20++ != r18)
		cp	r20, 	r18
		breq 	SchedulerChangeThreadLoop1End
		; we can do the following, because the address can not be greater
		; than 0x00FF (as you can see in the scheduler memory map)
		add 	xl,	r19
		inc	r20
		jmp SchedulerChangeThreadLoop1
	SchedulerChangeThreadLoop1End:
	
	ld	x+,	r1	; internal sr: we don't need it
	ld	x+,	r2	; iph is in r2
	ld	x+,	r3	; ipl is in r3
	ld	x+,	r16	; sr  is in r16
	ld	x+,	r5	; sph is in r5
	ld	x+,	r6	; spl is in r6
	
	std	(scheduler_global_unused + 0), r16	; sr is in unused[0]
	
	; let's set the stack pointer back
	out	sph	r5
	out	spl	r6
	; let's push the instruction pointer back to the stack
	push	r3	; the earlier one is low
	push	r2	; the later one is high

	; and now all registers again
	
	ld	r1,	x+
	ld	r2,	x+
	ld	r3,	x+
	ld	r4,	x+
	ld	r5,	x+
	ld	r6,	x+
	ld	r7,	x+
	ld	r8,	x+
	ld	r9,	x+
	ld	r10,	x+
	ld	r11,	x+
	ld	r12,	x+
	ld	r13,	x+
	ld	r14,	x+
	ld	r15,	x+
	ld	r16,	x+
	push	r16	; r16 is now on stack
	ld	r17,	x+
	ld	r18,	x+
	ld	r19,	x+
	ld	r20,	x+
	ld	r21,	x+
	ld	r22,	x+
	ld	r23,	x+
	ld	r24,	x+
	ld	r25,	x+
	ld	r16,	x+
	std	(scheduler_global_unused + 2), r16	; xl is in unused[2]
	ld	r16,	x+
	std	(scheduler_global_unused + 3), r16	; xh is in unused[3]
	ld	yl,	x+
	ld	yh,	x+
	ld	zl,	x+
	ld	zh,	x+
	
	ldd	xl,	(scheduler_global_unused + 2)
	ldd	xh,	(scheduler_global_unused + 3)
	
	; finaly we just have to replace the status register
	; and we are done
	
	ldd	r16,	(scheduler_global_unused + 0)
	out	sreg	r16
	pop	r16
	
	; done
	
	ret