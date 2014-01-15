%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

#include "symbol_table.h"

static struct wiki_node* table;
static struct wiki_scope* global_scope;
static struct wiki_scope* current_scope;

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

struct wiki_scope* set_new_scope(char* basename)
{
    char* name = malloc(32);
    struct wiki_scope* parent = current_scope;
    sprintf(name, "%s_%d", basename, scope_depth(current_scope));
    current_scope = get_new_scope_node(name, parent);
    fprintf(stderr, "New scope %s created\n", name);
}

/**
* Go up a level from the current scope
*/
struct wiki_scope* scope_go_up(void)
{
    if (current_scope->parent == NULL) {
        fprintf(stderr, "WARNING: stopping attempt to go up root scope (resulting in a fire)!\n");
        return;
    }
    fprintf(stderr, "Exiting from scope %s, back to %s\n", current_scope->name, current_scope->parent->name);
    current_scope = current_scope->parent;
}

%}

%union {
    char* result;
    struct wiki_node* node;
}

/* All tokens are described by wiki_node struct */
%token <node> TEXT
%token <node> BOLD
%token <node> ITALIC
%token <node> MONOSPACE
%token <node> UNDERLINE
%token <node> HEADER_ENTRY
%token <node> HEADER_EXIT


%type <result> block
%type <result> block_text
%type <result> text
%type <result> bold
%type <result> bold_content
%type <result> bold_parts
%type <result> italic
%type <result> italic_content
%type <result> italic_parts
%type <result> monospace
%type <result> monospace_content
%type <result> monospace_parts
%type <result> underline
%type <result> underline_content
%type <result> underline_parts
%type <result> header
%type <result> header_content
%type <result> header_parts

%start wikitext

%%

wikitext
	: /* empty */
	| wikitext block {
            printf("%s", $2);
        }
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
	: TEXT {
        add_symbol(table, $1, current_scope);
        $$ = strdup($1->lexeme);
	}
	;

bold
	: BOLD {
            set_new_scope("bold");
        }
    bold_content
    BOLD {
            //char tmp[120];
            //sprintf(tmp, "<b id=\"%s\">", current_scope->name);
            $$ = produce_output("<b>", $3, "</b>");
            scope_go_up();
        }
	;

bold_parts
	: text
	| italic
	| underline
	| monospace
	;

bold_content
	: bold_parts
	| bold_content bold_parts {
            $$ = produce_output($$, $2, NULL);
        }
	;

italic
    : ITALIC {
            set_new_scope("italic");
        }
    italic_content
    ITALIC {
            //char tmp[120];
            //sprintf(tmp, "<b id=\"%s\">", current_scope->name);
            $$ = produce_output("<i>", $3, "</i>");
            scope_go_up();
        }
	;

italic_parts
	: text
	| bold
	| underline
	| monospace
	;

italic_content
	: italic_parts
	| italic_content italic_parts { $$ = produce_output($$, $2, NULL); }
	;

underline
    : UNDERLINE {
            set_new_scope("underline");
        }
    underline_content
    UNDERLINE {
            //char tmp[120];
            //sprintf(tmp, "<b id=\"%s\">", current_scope->name);
            $$ = produce_output("<span style='text-decoration: underline;'>", $3, "</span>");
            scope_go_up();
        }
	;

underline_parts 
	: text
	| bold
	| italic
	| monospace
	;

underline_content 
	: underline_parts
	| underline_content underline_parts {
        $$ = produce_output($$, $2, NULL);
        }
	;

monospace
    : MONOSPACE {
            set_new_scope("monospace");
        }
    monospace_content
    MONOSPACE {
            //char tmp[120];
            //sprintf(tmp, "<b id=\"%s\">", current_scope->name);
            $$ = produce_output("<span style='font-family: monospace;'>", $3, "</span>");
            scope_go_up();
        }
	;

monospace_parts 
	: text
	| bold
	| italic
	| underline
	;

monospace_content 
	: monospace_parts
	| monospace_content monospace_parts {
        $$ = produce_output($$, $2, NULL);
        }
	;

header
    : HEADER_ENTRY {
            set_new_scope("header");
        }
    header_content
    HEADER_EXIT {
            int level = strlen($1->lexeme);
            char buf1[10];
            char buf2[10];
            sprintf(buf1, "<h%d>", level);
            sprintf(buf2, "</h%d>", level);
            $$ = produce_output(buf1, $3, buf2);
            scope_go_up();
        }
	;

header_content 
	: header_parts
	| header_content header_parts {
        $$ = produce_output($$, $2, NULL);
    }
	;

header_parts
	: text
	;
%%

#include "lex.yy.c"

/* Called by yyparse on error.  */
int yyerror (char const *s)
{
// TODO make line number to work!
//    fprintf(stderr, "Line: %ld: ", line_number);
    fprintf(stderr, "error, %s: '%s' in line %d\n", s, yytext, yylineno);
    fprintf(stderr, "%s\n", s);
}

int main(void)
{
    /* Symbol table initialization and test */
    global_scope = scope_init();
    current_scope = global_scope;
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
