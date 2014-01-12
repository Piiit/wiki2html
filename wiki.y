%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

#include "symbol_table.h"

struct wiki_node* table;

/* It practically combines strings, creating a fresh char memory blob */
char* produce_output(char* start, char* content, char* end)
{
    int extra = 0;
    int start_pointer = 0;
    char* result;
    if (start) extra+=strlen(start);
    if (content) extra+=strlen(content);
    if (end) extra+=strlen(end);
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

%token TEXT
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
	| wikitext block { printf("%s", $2->value);}
	;

block
	: block_text { add_symbol(table, $1); }
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
	: BOLD bold_content BOLD { $$->value = produce_output("<b>", $2->value, "</b>"); }
	;

bold_parts
	: text
	| italic
	| underline
	| monospace
	;

bold_content
	: bold_parts
	| bold_content bold_parts { $$->value = produce_output($$->value, $2->value, NULL); }
	;

italic
	: ITALIC italic_content ITALIC { $$->value = produce_output("<i>", $2->value, "</i>"); }
	;

italic_parts
	: text
	| bold
	| underline
	| monospace
	;

italic_content 
	: italic_parts
	| italic_content italic_parts { $$->value = produce_output($$->value, $2->value, NULL); }
	;

underline 
	: UNDERLINE underline_content UNDERLINE { $$->value = produce_output("<span style='text-decoration: underline;'>", $2->value, "</span>"); }
	;

underline_parts 
	: text
	| bold
	| italic
	| monospace
	;

underline_content 
	: underline_parts
	| underline_content underline_parts { $$->value = produce_output($$->value, $2->value, NULL); }
	;

monospace 
	: MONOSPACE monospace_content MONOSPACE { $$->value = produce_output("<span style='font-family: monospace;'>", $2->value, "</span>"); }
	;

monospace_parts 
	: text
	| bold
	| italic
	| underline
	;

monospace_content 
	: monospace_parts
	| monospace_content monospace_parts { $$->value = produce_output($$->value, $2->value, NULL); }
	;

%%

#include "lex.yy.c"



int main(void)
{
    /* Symbol table initialization and test */
    table = symbol_table_init();
    if (table == NULL)
        printf("Unable to allocate memory for symbol table!\n");
    int err = yyparse();
    print_symbol_table(table);
    symbol_table_free();
    return err;
}