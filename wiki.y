%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

#include "symbol_table.h"
%}

%union {
//  char* lexeme;		
//  char* value;			
    struct wiki_node* node;
}

%token <node> TEXT
%token BOLD
%token ITALIC
%token MONOSPACE
%token UNDERLINE


%type <node> paragraph
%type <node> text_paragraph
%type <node> text
%type <node> bold
%type <node> bold_content
%type <node> bold_parts
%type <node> italic
%type <node> italic_content
%type <node> italic_parts
%type <node> monospace
%type <node> monospace_content
%type <node> monospace_parts
%type <node> underline
%type <node> underline_content
%type <node> underline_parts

%start wikitext

%%

wikitext 
	: /* empty */
	| wikitext paragraph {printf("TEXT = %s\n", $2->value);}
	;

paragraph 
	: text_paragraph {$$->value = strdup($1->value);}
	;

text_paragraph 
	: bold {$$->value = strdup($1->value);}
	| italic {$$->value = strdup($1->value);}
	| monospace {$$->value = strdup($1->value);}
	| underline {$$->value = strdup($1->value);}
	| text {$$->value = strdup($1->value);}
	;

text 
	: TEXT {$$->value = strdup($1->value);}
	; 

bold 
	: BOLD bold_content BOLD {char buf[1024]; snprintf(buf, sizeof buf, "<b>%s</b>", $2->value); $$->value = strdup(buf);}
	;

bold_parts 
	: text {$$->value = strdup($1->value);}
	| italic {$$->value = strdup($1->value);}
	| underline {$$->value = strdup($1->value);}
	| monospace {$$->value = strdup($1->value);}
	;

bold_content 
	: bold_parts {$$->value = strdup($1->value);}
	| bold_content bold_parts {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $$->value, $2->value); $$->value = strdup(buf);}
	;

italic 
	: ITALIC italic_content ITALIC {char buf[1024]; snprintf(buf, sizeof buf, "<i>%s</i>", $2->value); $$->value = strdup(buf);}  		
	;

italic_parts 
	: text {$$->value = strdup($1->value);}
	| bold {$$->value = strdup($1->value);}
	| underline {$$->value = strdup($1->value);}
	| monospace {$$->value = strdup($1->value);}
	;

italic_content 
	: italic_parts {$$->value = strdup($1->value);}
	| italic_content italic_parts {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $$->value, $2->value); $$->value = strdup(buf);}
	;

underline 
	: UNDERLINE underline_content UNDERLINE {char buf[1024]; snprintf(buf, sizeof buf, "<span style='text-decoration: underline;'>%s</span>", $2->value); $$->value = strdup(buf);}  		
	;

underline_parts 
	: text {$$->value = strdup($1->value);}
	| bold {$$->value = strdup($1->value);}
	| italic {$$->value = strdup($1->value);}
	| monospace {$$->value = strdup($1->value);}
	;

underline_content 
	: underline_parts {$$->value = strdup($1->value);}
	| underline_content underline_parts {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $$->value, $2->value); $$->value = strdup(buf);}
	;

monospace 
	: MONOSPACE monospace_content MONOSPACE {char buf[1024]; snprintf(buf, sizeof buf, "<span style='font-family: monospace;'>%s</span>", $2->value); $$->value = strdup(buf);}  		
	;

monospace_parts 
	: text {$$->value = strdup($1->value);}
	| bold {$$->value = strdup($1->value);}
	| italic {$$->value = strdup($1->value);}
	| underline {$$->value = strdup($1->value);}
	;

monospace_content 
	: monospace_parts {$$->value = strdup($1->value);}
	| monospace_content monospace_parts {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $$->value, $2->value); $$->value = strdup(buf);}
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