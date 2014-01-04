%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
%}

%union {
       char* lexeme;		
       char* value;			
       }

%token <value> TEXT
%token BOLD

%type <value> line

%start lines

%%

lines : /* empty */
	  | lines line {printf("%s\n", $2);}
	  ;

line : BOLD TEXT BOLD	{$$ = $<value>2;}
	 | TEXT 			{$$ = $1;}
     ;

%%

#include "lex.yy.c"
