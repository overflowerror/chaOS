#include "serial.h"

void initSerial(enum Baudrate baudrate, enum Databits data, enum Parity parity, enum Stopbits stop) {
	switch (baudrate) {
	case b2400:
		UBRRL = 416 & 0xff;
		UBRRH = 416 >> 8;
		break;
	case b4800:
		UBRRL = 207 & 0xff;
		UBRRH = 207 >> 8;
		break;
	case b9600:
		UBRRL = 103 & 0xff;
		UBRRH = 103 >> 8;
		break;
	case b19200:
		UBRRL = 51 & 0xff;
		UBRRH = 51 >> 8;
		break;
	case b38400:
		UBRRL = 25 & 0xff;
		UBRRH = 25 >> 8;
		break;
	case b57600:
		UBRRL = 16 & 0xff;
		UBRRH = 16 >> 8;
		break;
	case b155200:
		UBRRL = 8 & 0xff;
		UBRRH = 8 >> 8;
		break;
	default:
		break;
	}

	UCSRC &= ~((0 << URSEL) | (1 << USBS));
	if (stop == s2)
		UCSRC |= (1 << URSEL) | (1 << USBS);

	UCSRB &= ~((0 << URSEL) | (1 << UCSZ2));
	UCSRC &= ~((0 << URSEL) | (1 << UCSZ1) | (1 << UCSZ0));
	
	switch (data) {
	case d8:
		UCSRB |= (0 << UCSZ2);
		UCSRC |= ((1 << URSEL) | (1 << UCSZ1) | (1 << UCSZ0));
		break;
	case d9:
		UCSRB |= (1 << UCSZ2);
		UCSRC |= ((1 << URSEL) | (1 << UCSZ1) | (1 << UCSZ0));
		break;
	default:
		break;
	}

	UCSRC &= ~((0 << URSEL) | (1 << UPM1) | (1 << UPM0));
	
	switch (parity) {
	case no:
		UCSRC |= (0 << UPM1) | (0 << UPM0);
		break;
	case even:
		UCSRC |= (1 << UPM1) | (0 << UPM0);
		break;
	case odd:
		UCSRC |= (1 << UPM1) | (1 << UPM0);
		break;
	default:
		break;
	}	
}
