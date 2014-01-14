%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

#include "symbol_table.h"

struct wiki_node* table;
struct wiki_scope* main_scope;

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
%token <node> HEADER_ENTRY
%token HEADER_EXIT


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
%type <node> header
%type <node> header_content
%type <node> header_parts

%start wikitext
/* TODO substitute $$->value with a result variable */
%%

wikitext
	: /* empty */
	| wikitext block { printf("%s", $2->value); }
	;

block
	: block_text
	| header
	;

block_text
	: bold
	| italic
	| monospace
	| underline
	| text
	;

text
	: TEXT { $$="" }
	;

bold
	: BOLD bold_content BOLD { $$->value = produce_output("<b>", $2->value, "</b>"); }
	;

bold_parts
	: text { add_symbol(table, $1, main_scope); }
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
	: text { add_symbol(table, $1, main_scope); }
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
	: text { add_symbol(table, $1, main_scope); }
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
	: text { add_symbol(table, $1, main_scope); }
	| bold
	| italic
	| underline
	;

monospace_content 
	: monospace_parts
	| monospace_content monospace_parts { $$->value = produce_output($$->value, $2->value, NULL); }
	;

header
	: HEADER_ENTRY header_content HEADER_EXIT {$$->value = produce_output("<h>", $2->value, "</h>");}
	;

header_content 
	: header_parts 
	| header_content header_parts {$$->value = produce_output($$->value, $2->value, NULL);} 
	;

header_parts
	: text { add_symbol(table, $1, main_scope); }
	; 
%%

#include "lex.yy.c"



int main(void)
{
    /* Symbol table initialization and test */
    main_scope = scope_init();
    table = symbol_table_init();
    fprintf(stderr, "Initial symbol table size: %d\n", symbol_table_length(table));
    if (table == NULL)
        fprintf(stderr, "Unable to allocate memory for symbol table!\n");
    int err = yyparse();
    fprintf(stderr, "Final symbol table lenght: %d\n", symbol_table_length(table));
    print_symbol_table(table);
    symbol_table_free();
    return err;
}
