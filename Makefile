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
	$(CC) -o $@ $^ y.tab.c symbol_table.c -ly -ll

# *To see the moves of the parser:
debug:
	$(CC) -o $@ $^ -DYYDEBUG y.tab.c -ly -ll

test:
	make $(NAME)
	./wiki < test_modules/test_cases.txt 2>/dev/null | diff test_modules/test_cases_expected.txt - || exit 0

.PHONY: clean

clean:
	rm -f *.o *~ $(NAME) y.tab.c y.tab.h lex.yy.c y.output symbol_table.o
