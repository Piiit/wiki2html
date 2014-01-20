#include <string.h>
#include "stdio.h"

/*
 * Thx to http://stackoverflow.com/users/9530/adam-rosenfield
 */
char *trim(char *str)
{
  char *end;

  // Trim leading space
  while(isspace(*str)) str++;

  if(*str == 0)  // All spaces?
    return str;

  // Trim trailing space
  end = str + strlen(str) - 1;
  while(end > str && isspace(*end)) end--;

  // Write new null terminator
  *(end+1) = 0;

  return str;
}

#define LEXER_STATE_SIZE 512
int lexer_states[LEXER_STATE_SIZE] = {0};
int lexer_state = 0;

void lexer_states_push(int state) {
	if(lexer_state == LEXER_STATE_SIZE) {
		fprintf(stderr, "LEXER STATES: error out of bound!");
		return;
	}

	lexer_state++;		
	lexer_states[lexer_state] = state;
	fprintf(stderr, "LEXER STATE (push): #%d = %d\n", lexer_state, lexer_states[lexer_state]);
}

int lexer_states_pop(void) {
	if(lexer_state > 0) {
		lexer_state--;
	}
	fprintf(stderr, "LEXER STATE (pop): #%d = %d\n", lexer_state, lexer_states[lexer_state]);
	return lexer_states[lexer_state];
}

int lexer_states_get(void) {
	fprintf(stderr, "LEXER STATE (get): #%d = %d\n", lexer_state, lexer_states[lexer_state]);
	return lexer_states[lexer_state];
}

