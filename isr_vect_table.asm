jmp SystemInit 		; System Reset Handler
jmp Default_ISR		; IRQ0 Handler
jmp Default_ISR		; IRQ1 Handler
jmp Default_ISR		; PCINT0 Handler
jmp Default_ISR		; PCINT1 Handler
jmp Default_ISR		; PCINT2 Handler
jmp Default_ISR		; PCINT3 Handler
jmp SystemInit		; Watchdog Timeout
jmp Default_ISR		; Timer2 CompareA Handler
jmp Default_ISR		; Timer2 CompareB Handler
jmp Default_ISR		; Timer2 Overflow Handler
jmp Default_ISR		; Timer1 Capture Handler
jmp Default_ISR		; Timer1 CompareA Handler
jmp Default_ISR		; Timer1 CompareB Handler
jmp Default_ISR		; Timer1 Overflow Handler
jmp Default_ISR		; Timer0 CompareA Handler
jmp Default_ISR		; Timer0 CompareB Handler
jmp Default_ISR		; Timer0 Overflow Handler
jmp Default_ISR		; SPI Transfer Complete Handler
jmp Default_ISR		; USART0 RX Complete Handler
jmp Default_ISR		; USART0 UDR Empty Handler
jmp Default_ISR		; USART0 TX Complete Handler
jmp Default_ISR		; Analog Comparator
jmp Default_ISR		; ADC Conversion Complete Handler
jmp Default_ISR		; EEPROM Ready Handler
jmp Default_ISR		; Two-wire Serial Interface Handler
jmp Default_ISR		; SPM Ready
jmp Default_ISR		; USART1 RX Complete Handler
jmp Default_ISR		; USART1 UDR Empty Handler
jmp Default_ISR		; USART1 TX Complete Handler
jmp Default_ISR		; Timer3 Capture Handler
jmp Default_ISR		; Timer3 CompareA Handler
jmp Default_ISR		; Timer3 CompareB Handler
jmp Default_ISR		; Timer3 Overflow Handler
jmp Default_ISR		; Store Program Memory Ready Handler

Default_ISR:
	reti;