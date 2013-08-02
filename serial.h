#ifndef SERIAL_H
#define SERIAL_H

#include <avr/io.h>

enum Parity {no, even, odd};
enum Baudrate {b2400, b4800, b9600, b19200, b38400, b57600, b155200};
enum Stopbits {s1, s2};
enum Databits {d8, d9};

void initSerial(enum Baudrate, enum Databits, enum Parity, enum Stopbits);

#define enableTransmitter() 	(UCSRB |=  (1 << TXEN))
#define disableTransmitter() 	(UCSRB &= ~(1 << TXEN))

#define enableReceiver() 	(UCSRB |=  (1 << RXEN))
#define disableReceiver() 	(UCSRB &= ~(1 << RXEN))

#define enableReceiveInterrupt()	(UCSRB |=  (1 << RXCIE))
#define disableReceiveInterrupt()	(UCSRB &= ~(1 << RXCIE))

#define enableTransmitCompleteInterrupt()	(UCSRB |=  (1 << TXCIE))
#define disableTransmitCompleteInterrupt()	(UCSRB &= ~(1 << TXCIE))

#define enableDataRegisterEmptyInterrupt()	(UCSRB |=  (1 << UDRIE))
#define disableDataRegisterEmptyInterrupt()	(UCSRB &= ~(1 << UDRIE))

#define characterGot()		(UCSRA & (1 << RXC))
#define	dataRegisterEmpty()	(UCSRA & (1 << UDRE))

#define sRead()		(UDR)
#define sWrite(c)	(UDR = c)

#endif
