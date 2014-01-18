#ifndef UTILS_H
#define UTILS_H

char *trim(char *str);

void lexer_states_push(int state);
int lexer_states_pop(void);
int lexer_states_get(void);

#endif
