#include <avr/io.h>
#include <avr/interrupt.h>

#include "stdio.h"
#include "types.h"
#include "string.h"
#include "serial.h"
#include "cmd/ash.h"

void setup () {
	DDRB = 0xff;
	PORTB = 0;
	initSerial(b9600, d8, even, s1);	
	initOutput();
	sei();	// FACEPALM!!!!

	puts(nl);
	puts("init [serial]");
	puts(nl);
	puts("init [output]");
	puts(nl);

	initInput();
	puts("init [input]");
	puts(nl);

	TIMSK = 0;
	puts("reset timer interrupts");
	puts(nl);

	puts("watchdog flag: ");
	putc(((MCUCSR & WDRF) >> WDRF) + '0');
	puts(nl);

	MCUCSR &= ~(1 << WDRF);
	puts("watchdog flag reset");
	puts(nl);

	PORTB |= 1;
}

int main () {
	setup();

	while (true)
		ashMain();			
	
	return 0;
}
