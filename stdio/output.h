#ifndef OUTPUT_H
#define OUTPUT_H

#include "../buffer.h"

extern Buffer stdout;

void initOutput ();
void putc (char);
void puts (char*);

#endif
