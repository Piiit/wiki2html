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

%type <value> line
%type <value> text
%type <value> bold
%type <value> bold_content
%type <value> italic
%type <value> italic_content

%start lines

%%

lines : /* empty */
	  | line lines {printf("TEXT = %s\n", $1);}
	  ;

line : bold				{$$ = strdup($1);}
	 | italic			{$$ = strdup($1);}
	 | text 			{$$ = strdup($1);}
     ;

text : TEXT				{$$ = strdup($1);}
	 ; 

bold : BOLD bold_content BOLD   {char buf[1024]; snprintf(buf, sizeof buf, "<b>%s</b>", $2); $$ = strdup(buf);}
	 ;

italic : ITALIC italic_content ITALIC {char buf[1024]; snprintf(buf, sizeof buf, "<i>%s</i>", $2); $$ = strdup(buf);}  		
	   ;

italic_content : text {$$ = strdup($1);}
			   | bold {$$ = strdup($1);}
			   | text bold {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $1, $2); $$ = strdup(buf);}
               | bold text {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $1, $2); $$ = strdup(buf);}
               | text bold text {char buf[1024]; snprintf(buf, sizeof buf, "%s%s%s", $1, $2, $3); $$ = strdup(buf);}
			   ;

bold_content   : text {$$ = strdup($1);}
			   | italic {$$ = strdup($1);}
			   | text italic {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $1, $2); $$ = strdup(buf);}
               | italic text {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $1, $2); $$ = strdup(buf);}
               | text italic text {char buf[1024]; snprintf(buf, sizeof buf, "%s%s%s", $1, $2, $3); $$ = strdup(buf);}
			   ;


%%

#include "lex.yy.c"
