#include <stdlib.h>

#include <avr/io.h>

#include "ash.h"
#include "../stdio.h"
#include "../types.h"
#include "../string.h"

void interpret(char***, tiny*, char*, tiny);

#define clLength 64

int ashMain () {
	char input[clLength];

	char *prompt = "ash> ";

	tiny position = 0;

	puts(prompt);

	while (true) {
		char c = getch();
		if (c == '\r') {
			input[position] = '\0';
			puts(nl);
			char **args;
			tiny argc;
			interpret(&args, &argc, input, position);		
			position = 0;
			puts(args[0]);
			puts(nl);
			puts(prompt);
			free(args);
			PORTB |= 2;
			continue;
		}
		if (position >= clLength - 1)
			continue;
		putc(c);
		input[position] = c;
		position++;
	}
	return 0;
}

void interpret(char*** args, tiny* argc, char* input, tiny length) {
	(*argc) = 0;
	(*args) = (char**) malloc(sizeof(char*));
	(*args)[0] = (char*) malloc(sizeof(char));
	tiny paramLength = 0;
	for (tiny i = 0; i < length; i++) {
		if (input[i] == ' ') {
			if (paramLength == 0)
				continue;			
			(*args)[(*argc)] = (char*) realloc((*args)[(*argc)], (paramLength + 1) * sizeof(char));
			(*args)[(*argc)][paramLength] = '\0';
			(*argc)++;
			(*args) = (char**) realloc((*args), ((*argc) + 1) * sizeof(char*));
			(*args)[(*argc)] = (char*) malloc(sizeof(char));
			paramLength = 0;
		}
		(*args)[(*argc)] = (char*) realloc((*args)[(*argc)], (paramLength + 1) * sizeof(char));
		(*args)[(*argc)][paramLength] = input[i];		
		paramLength++;
	}
	(*args)[(*argc)] = (char*) realloc((*args)[(*argc)], (paramLength + 1) * sizeof(char));
	(*args)[(*argc)][paramLength] = '\0';
}
