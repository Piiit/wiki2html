%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

#include "symbol_table.h"

static struct wiki_node* table;
static struct wiki_scope* main_scope;
static struct wiki_scope* current_scope;
static long line_number = 0;

/* It practically combines strings, creating a fresh char memory blob */
char* produce_output(char* start, char* content, char* end)
{
    int extra = 0;
    int start_pointer = 0;
    char* result;
    if (start) extra+=strlen(start);
    if (content) extra+=strlen(content);
    if (end) extra+=strlen(end);
    result = malloc(extra+3);
    if (start) strcat(result, start);
    if (content) strcat(result, content);
    if (end) strcat(result, end);
    return result;
}
%}

%union {
    char* result;
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
	: TEXT { if ($$ == NULL) $$=get_new_node(); }
	;

bold
	: BOLD bold_content BOLD {
// TODO go up one level of scope
                            $$->value = produce_output("<b>", $2->value, "</b>");
                            
                    }
	;

bold_parts
	: text {
                char name[32];
                sprintf(name, "bold_%d", scope_depth(main_scope));
                struct wiki_scope* parent = current_scope;
                current_scope = get_new_scope_node(name);
                current_scope->parent = parent;
                add_symbol(table, $1, current_scope);
            }
	| italic
	| underline
	| monospace
	;

bold_content
	: bold_parts
	| bold_content bold_parts {
        $$->value = produce_output($$->value, $2->value, NULL);
	}
	;

italic
	: ITALIC italic_content ITALIC {
        $$->value = produce_output("<i>", $2->value, "</i>");
    }
	;

italic_parts
	: text { add_symbol(table, $1, current_scope); }
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
	: text { add_symbol(table, $1, current_scope); }
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
	: text { add_symbol(table, $1, current_scope); }
	| bold
	| italic
	| underline
	;

monospace_content 
	: monospace_parts
	| monospace_content monospace_parts { $$->value = produce_output($$->value, $2->value, NULL); }
	;

header
	: HEADER_ENTRY header_content HEADER_EXIT {
			int level = strlen($1->lexeme); 
			char buf1[10];
			char buf2[10];
			sprintf(buf1, "<h%d>", level);
			sprintf(buf2, "</h%d>", level);
			$$->value = produce_output(buf1, $2->value, buf2);
		}
	;

header_content 
	: header_parts 
	| header_content header_parts {$$->value = produce_output($$->value, $2->value, NULL);} 
	;

header_parts
	: text { add_symbol(table, $1, current_scope); }
	; 
%%

#include "lex.yy.c"

/* Called by yyparse on error.  */
int yyerror (char const *s)
{
// TODO make line number to work!
    fprintf(stderr, "Line: %ld: ", line_number);
    fprintf(stderr, "%s\n", s);
}

int main(void)
{
    /* Symbol table initialization and test */
    main_scope = scope_init();
    current_scope = main_scope;
    table = symbol_table_init();
    fprintf(stderr, "Initial symbol table size: %d\n", symbol_table_length(table));
    if (table == NULL)
        fprintf(stderr, "Unable to allocate memory for symbol table\n");
    int err = yyparse();
    fprintf(stderr, "Final symbol table lenght: %d\n", symbol_table_length(table));
    print_symbol_table(table);
    symbol_table_free();
    return err;
}
