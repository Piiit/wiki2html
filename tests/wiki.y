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

%type <value> formatting
%type <value> entry


%start entry

%%

entry : /* empty */         {}
      | entry formatting           {printf("%s", $2);}
      ;

/*bold : BOLD text BOLD   {char buf[1024]; snprintf(buf, sizeof buf, "<b>%s</b>", $2); $$ = strdup(buf);}
	 ;

italic : ITALIC text ITALIC {char buf[1024]; snprintf(buf, sizeof buf, "<i>%s</i>", $2); $$ = strdup(buf);}  		
	   ;*/

formatting : BOLD formatting BOLD {char buf[1024]; snprintf(buf, sizeof buf, "<b>%s</b>", $2); $$ = strdup(buf);}
            | ITALIC formatting ITALIC {char buf[1024]; snprintf(buf, sizeof buf, "<i>%s</i>", $2); $$ = strdup(buf);}
            | BOLD formatting {char buf[1024]; snprintf(buf, sizeof buf, "<b>%s</b>", $2); $$ = strdup(buf);}
            | ITALIC formatting {char buf[1024]; snprintf(buf, sizeof buf, "<i>%s</i>", $2); $$ = strdup(buf);}
/*            | formatting ITALIC {char buf[1024]; snprintf(buf, sizeof buf, "<b>%s</b>", $1); $$ = strdup(buf);}
            | formatting BOLD {char buf[1024]; snprintf(buf, sizeof buf, "<i>%s</i>", $1); $$ = strdup(buf);}*/
            | TEXT {$$ = strdup($1);}
            ;

/*italic_content : text {$$ = strdup($1);}
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
			   ;*/


%%

#include "lex.yy.c"
