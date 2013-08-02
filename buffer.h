#ifndef BUFFER_H
#define BUFFER_H

#include "buffer.h"
#include "types.h"

typedef struct {
	tiny maxLength;
	tiny beginPointer;
	tiny readPointer;
	char *array;
} Buffer;

void initBuffer(Buffer*, tiny);
int overflowIndex (tiny, tiny);
tiny getBufferLength(Buffer*);
bool readBuffer (Buffer*, char*);
bool writeFIFO (Buffer* , char );
bool writeLIFO (Buffer*, char);
void allocBuffer (Buffer*);

#endif
