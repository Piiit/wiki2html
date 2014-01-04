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
%type <value> bold

%start lines

%%

lines : /* empty */
	  | line lines
	  ;

line : bold				{printf("BOLD %s\n", $1);}
	 | text 			{printf("SIMPLE %s\n", $1);}
     ;

text : TEXT				{$$ = $1;}
	 ; 

bold : BOLD text BOLD   {$$ = $2;}
	 ;

%%

#include "lex.yy.c"
