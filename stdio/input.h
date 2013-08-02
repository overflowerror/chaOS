#ifndef INPUT_H
#define INPUT_H

#include "../buffer.h"

extern Buffer stdin;

void initInput ();
char getch();
void ungetc(char c);
bool kbhit();

#endif
