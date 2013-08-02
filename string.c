#include "string.h"

int getStringLength (char* string) {
	for (int i = 0; ; i++) {
		if (string[i] == '\0')
			return i + 1;
	}
	return 0;
}
