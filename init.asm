SystemInit: 
	rcall SchedulerInit
	
	sei
	
	jmp MainLoop