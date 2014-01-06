%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

#include "symbol_table.h"
%}

%union {
  char* lexeme;		
  char* value;			
}

%token <value> TEXT
%token BOLD
%token ITALIC
%token MONOSPACE
%token UNDERLINE


%type <value> paragraph
%type <value> text_paragraph
%type <value> text
%type <value> bold
%type <value> bold_content
%type <value> bold_parts
%type <value> italic
%type <value> italic_content
%type <value> italic_parts
%type <value> monospace
%type <value> monospace_content
%type <value> monospace_parts
%type <value> underline
%type <value> underline_content
%type <value> underline_parts

%start wikitext

%%

wikitext 
	: /* empty */
	| wikitext paragraph {printf("TEXT = %s\n", $2);}
	;

paragraph 
	: text_paragraph {$$ = strdup($1);}
	;

text_paragraph 
	: bold {$$ = strdup($1);}
	| italic {$$ = strdup($1);}
	| monospace {$$ = strdup($1);}
	| underline {$$ = strdup($1);}
	| text {$$ = strdup($1);}
	;

text 
	: TEXT {$$ = strdup($1);}
	; 

bold 
	: BOLD bold_content BOLD {char buf[1024]; snprintf(buf, sizeof buf, "<b>%s</b>", $2); $$ = strdup(buf);}
	;

bold_parts 
	: text {$$ = strdup($1);}
	| italic {$$ = strdup($1);}
	| underline {$$ = strdup($1);}
	| monospace {$$ = strdup($1);}
	;

bold_content 
	: bold_parts {$$ = strdup($1);}
	| bold_content bold_parts {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $$, $2); $$ = strdup(buf);}
	;

italic 
	: ITALIC italic_content ITALIC {char buf[1024]; snprintf(buf, sizeof buf, "<i>%s</i>", $2); $$ = strdup(buf);}  		
	;

italic_parts 
	: text {$$ = strdup($1);}
	| bold {$$ = strdup($1);}
	| underline {$$ = strdup($1);}
	| monospace {$$ = strdup($1);}
	;

italic_content 
	: italic_parts {$$ = strdup($1);}
	| italic_content italic_parts {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $$, $2); $$ = strdup(buf);}
	;

underline 
	: UNDERLINE underline_content UNDERLINE {char buf[1024]; snprintf(buf, sizeof buf, "<span style='text-decoration: underline;'>%s</span>", $2); $$ = strdup(buf);}  		
	;

underline_parts 
	: text {$$ = strdup($1);}
	| bold {$$ = strdup($1);}
	| italic {$$ = strdup($1);}
	| monospace {$$ = strdup($1);}
	;

underline_content 
	: underline_parts {$$ = strdup($1);}
	| underline_content underline_parts {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $$, $2); $$ = strdup(buf);}
	;

monospace 
	: MONOSPACE monospace_content MONOSPACE {char buf[1024]; snprintf(buf, sizeof buf, "<span style='font-family: monospace;'>%s</span>", $2); $$ = strdup(buf);}  		
	;

monospace_parts 
	: text {$$ = strdup($1);}
	| bold {$$ = strdup($1);}
	| italic {$$ = strdup($1);}
	| underline {$$ = strdup($1);}
	;

monospace_content 
	: monospace_parts {$$ = strdup($1);}
	| monospace_content monospace_parts {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $$, $2); $$ = strdup(buf);}
	;

%%

#include "lex.yy.c"

int main(void)
{
    /* Symbol table initialization and test */
    struct wiki_node* table;
    table = symbol_table_init();
    if (table == NULL)
        printf("Unable to allocate memory for symbol table!");
    symbol_table_free();
    int err = yyparse();
    return err;
}