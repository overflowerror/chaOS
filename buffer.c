#include <stdlib.h>

#include "buffer.h"
#include "types.h"

void initBuffer(Buffer* b, tiny length) {
	b->maxLength = length;
	allocBuffer(b);
	b->beginPointer = 0;
	b->readPointer = 0;
}

int overflowIndex (tiny length, tiny index) {
	return index % length;
}

tiny getBufferLength(Buffer* b) {
	return overflowIndex(b->maxLength, b->beginPointer - b->readPointer);
}

bool readBuffer (Buffer* b, char* c) {
	if (!(getBufferLength(b) > 0))
		return false;
	*c = b->array[b->readPointer];
	b->readPointer = overflowIndex(b->maxLength, b->readPointer + 1);
	return true;
}

bool writeFIFO (Buffer* b, char c) {
	if (!(getBufferLength(b) < (b->maxLength - 1)))
		return false;
	b->array[b->beginPointer] = c;
	b->beginPointer = overflowIndex(b->maxLength, (b->beginPointer + 1));
	return true;
}

bool writeLIFO (Buffer* b, char c) {
	if (!(getBufferLength(b) < (b->maxLength - 1)))
		return false;
	b->array[b->readPointer - 1] = c;
	b->readPointer = overflowIndex(b->maxLength, (b->readPointer - 1));
	return true;
}

void allocBuffer (Buffer* b) {
	free(b->array);
	b->array = (char*) malloc (b->maxLength * sizeof(char));
}
