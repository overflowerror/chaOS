#include <avr/interrupt.h>

#include "input.h"
#include "../serial.h"

#define safe 3

Buffer stdin;

void initInput () {
	initBuffer(&stdin, 64);
	enableReceiver();
	enableReceiveInterrupt();
}

char getch() {
	char c;
	while (!(readBuffer(&stdin, &c)));
	return c;
}

void ungetc(char c) {
	while (!writeLIFO(&stdin, c));
}

bool kbhit() {
	return getBufferLength(&stdin);
}

// on serial receive
ISR (USART_RXC_vect) {
	PORTB |= 8;
	if (getBufferLength(&stdin) < stdin.maxLength - safe) {
		writeFIFO(&stdin, sRead());
	}
}
