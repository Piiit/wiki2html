%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

#include "symbol_table.h"
%}

%union {
    struct wiki_node* node;
}

%token <node> TEXT
%token BOLD
%token ITALIC
%token MONOSPACE
%token UNDERLINE


%type <node> block
%type <node> text_block
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
	| wikitext block {printf("TEXT = %s\n", $2->lexeme);}
	;

block
	: block_text {$$->lexeme = strdup($1->lexeme);}
	;

block_text
	: bold {$$->lexeme = strdup($1->lexeme);}
	| italic {$$->lexeme = strdup($1->lexeme);}
	| monospace {$$->lexeme = strdup($1->lexeme);}
	| underline {$$->lexeme = strdup($1->lexeme);}
	| text {$$->lexeme = strdup($1->lexeme);}
	;

text
	: TEXT {$$->lexeme = strdup($1->lexeme);}
	;

bold
	: BOLD bold_content BOLD {char buf[1024]; snprintf(buf, sizeof buf, "<b>%s</b>", $2->lexeme); $$->lexeme = strdup(buf);}
	;

bold_parts
	: text {$$->lexeme = strdup($1->lexeme);}
	| italic {$$->lexeme = strdup($1->lexeme);}
	| underline {$$->lexeme = strdup($1->lexeme);}
	| monospace {$$->lexeme = strdup($1->lexeme);}
	;

bold_content
	: bold_parts {$$->lexeme = strdup($1->lexeme);}
	| bold_content bold_parts {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $$->lexeme, $2->lexeme); $$->lexeme = strdup(buf);}
	;

italic
	: ITALIC italic_content ITALIC {char buf[1024]; snprintf(buf, sizeof buf, "<i>%s</i>", $2->lexeme); $$->lexeme = strdup(buf);}  		
	;

italic_parts
	: text {$$->lexeme = strdup($1->lexeme);}
	| bold {$$->lexeme = strdup($1->lexeme);}
	| underline {$$->lexeme = strdup($1->lexeme);}
	| monospace {$$->lexeme = strdup($1->lexeme);}
	;

italic_content 
	: italic_parts {$$->lexeme = strdup($1->lexeme);}
	| italic_content italic_parts {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $$->lexeme, $2->lexeme); $$->lexeme = strdup(buf);}
	;

underline 
	: UNDERLINE underline_content UNDERLINE {char buf[1024]; snprintf(buf, sizeof buf, "<span style='text-decoration: underline;'>%s</span>", $2->lexeme); $$->lexeme = strdup(buf);}  		
	;

underline_parts 
	: text {$$->lexeme = strdup($1->lexeme);}
	| bold {$$->lexeme = strdup($1->lexeme);}
	| italic {$$->lexeme = strdup($1->lexeme);}
	| monospace {$$->lexeme = strdup($1->lexeme);}
	;

underline_content 
	: underline_parts {$$->lexeme = strdup($1->lexeme);}
	| underline_content underline_parts {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $$->lexeme, $2->lexeme); $$->lexeme = strdup(buf);}
	;

monospace 
	: MONOSPACE monospace_content MONOSPACE {char buf[1024]; snprintf(buf, sizeof buf, "<span style='font-family: monospace;'>%s</span>", $2->lexeme); $$->lexeme = strdup(buf);}  		
	;

monospace_parts 
	: text {$$->lexeme = strdup($1->lexeme);}
	| bold {$$->lexeme = strdup($1->lexeme);}
	| italic {$$->lexeme = strdup($1->lexeme);}
	| underline {$$->lexeme = strdup($1->lexeme);}
	;

monospace_content 
	: monospace_parts {$$->lexeme = strdup($1->lexeme);}
	| monospace_content monospace_parts {char buf[1024]; snprintf(buf, sizeof buf, "%s%s", $$->lexeme, $2->lexeme); $$->lexeme = strdup(buf);}
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