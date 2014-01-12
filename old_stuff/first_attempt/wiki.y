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
%token ITALIC
%token UNDERLINE

%start line

%%
line  : TEXT 		     {printf("Result: %s\n", $1); exit(0);}
	  | BOLD TEXT BOLD	 {printf("Result2: %s\n", $2); exit(0);}
      ;


%%

#include "lex.yy.c"
