jmp SystemInit 			;System Reset Handler
jmp Default_ISR			;IRQ0 Handler
jmp Default_ISR			;IRQ1 Handler
jmp Default_ISR			;Timer2 Compare Handler
jmp Default_ISR			;Timer2 Overflow Handler
jmp Default_ISR			;Timer1 Capture Handler
jmp Default_ISR			;Timer1 CompareA Handler
jmp Default_ISR			;Timer1 CompareB Handler
jmp Default_ISR			;Timer1 Overflow Handler
jmp Default_ISR			;Timer0 Overflow Handler
jmp Default_ISR			;SPI Transfer Complete Handler
jmp Default_ISR			;USART RX Complete Handler
jmp Default_ISR			;UDR Empty Handler
jmp Default_ISR			;USART TX Complete Handler
jmp Default_ISR			;ADC Conversion Complete Handler
jmp Default_ISR			;EEPROM Ready Handler
jmp Default_ISR			;Analog Comparator Handler
jmp Default_ISR			;Two-wire Serial Interface Handler
jmp Default_ISR			;IRQ2 Handler
jmp Default_ISR			;Timer0 Compare Handler
jmp Default_ISR			;Store Program Memory Ready Handler

Default_ISR:
	reti;