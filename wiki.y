%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

#include "symbol_table.h"

/* It practically combines strings, creating a fresh char memory blob */
char* produce_output(char* start, char* content, char* end)
{
    int extra = 0;
    int start_pointer = 0;
    char* result;
    if (start) extra+=strlen(start);
    if (end) extra+=strlen(end);
    if (content) extra+=strlen(content);
    result = malloc(extra);
    if (start) strcat(result, start);
    if (content) strcat(result, content);
    if (end) strcat(result, end);
    return result;
}
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
%type <node> block_text
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
	| wikitext block {printf("%s", $2->lexeme);}
	;

block
	: block_text
	;

block_text
	: bold
	| italic
	| monospace
	| underline
	| text
	;

text
	: TEXT
	;

bold
	: BOLD bold_content BOLD { $$->lexeme = produce_output("<b>", $2->lexeme, "</b>"); }
	;

bold_parts
	: text
	| italic
	| underline
	| monospace
	;

bold_content
	: bold_parts
	| bold_content bold_parts { $$->lexeme = produce_output($$->lexeme, $2->lexeme, NULL); }
	;

italic
	: ITALIC italic_content ITALIC { $$->lexeme = produce_output("<i>", $2->lexeme, "</i>"); }  		
	;

italic_parts
	: text
	| bold
	| underline
	| monospace
	;

italic_content 
	: italic_parts
	| italic_content italic_parts { $$->lexeme = produce_output($$->lexeme, $2->lexeme, NULL); }
	;

underline 
	: UNDERLINE underline_content UNDERLINE { $$->lexeme = produce_output("<span style='text-decoration: underline;'>", $2->lexeme, "</span>"); }
	;

underline_parts 
	: text
	| bold
	| italic
	| monospace
	;

underline_content 
	: underline_parts
	| underline_content underline_parts { $$->lexeme = produce_output($$->lexeme, $2->lexeme, NULL); }
	;

monospace 
	: MONOSPACE monospace_content MONOSPACE { $$->lexeme = produce_output("<span style='font-family: monospace;'>", $2->lexeme, "</span>"); }
	;

monospace_parts 
	: text
	| bold
	| italic
	| underline
	;

monospace_content 
	: monospace_parts
	| monospace_content monospace_parts { $$->lexeme = produce_output($$->lexeme, $2->lexeme, NULL); }
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