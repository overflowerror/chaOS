#include <avr/interrupt.h>

#include "output.h"
#include "../string.h"
#include "../serial.h"

#define safe 3

Buffer stdout;

void initOutput () {
	initBuffer(&stdout, 64);
	enableTransmitter();
	enableTransmitCompleteInterrupt();
	enableDataRegisterEmptyInterrupt();
}

void putc (char c) {
	if (dataRegisterEmpty()) {
		sWrite(c);
		return;
	}
	while (getBufferLength(&stdout) > stdout.maxLength - safe);
	writeFIFO(&stdout, c);
}

void puts (char* string) {
	int length = getStringLength(string);
	for (int i = 0; i < length; i++) {
		putc(string[i]);
	}
}



// on serial transmit
ISR (USART_TXC_vect) {
}

// on data register empty
ISR (USART_UDRE_vect) {
	if (getBufferLength(&stdout)) {
		char c;
		readBuffer(&stdout, &c);
		sWrite(c);
	}
}
