CC=gcc
LEXER=flex
YACC=yacc
# CFLAGS=-I.
# DEPS = hellomake.h
# OBJ = hellomake.o hellofunc.o 

NAME=wiki

$(NAME):
	$(LEXER) -l $(NAME).l
	$(YACC) -vd $(NAME).y
#	-v: generates the DFA
#	-d: generate the y.tab.h file
	$(CC) -o $@ $^ y.tab.c -ly -ll

# *To see the moves of the parser:
debug:
	$(CC) -o $@ $^ -DYYDEBUG y.tab.c -ly -ll

.PHONY: clean

clean:
	rm -f *.o *~ $(NAME) y.tab.c y.tab.h lex.yy.c y.output
