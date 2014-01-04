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
%type <value> text

%start lines

%%

lines : /* empty */
	  | lines line
	  ;

line : BOLD text BOLD	{$$ = $2; printf("BOLD %s\n", $2);}
	 | text 			{$$ = $1; printf("SIMPLE %s\n", $1);}
     ;

text : TEXT				{$$ = $1; printf("TEXT %s\n", $1);}
	 ; 

%%

#include "lex.yy.c"
