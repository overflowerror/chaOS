.include	"m16def.inc"
.include	"isr_vect_table.asm"

.include	"init.asm"
.include	"scheduler.asm"
.include	"general.asm"

MainLoop:
	jmp MainLoop