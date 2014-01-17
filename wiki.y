%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdbool.h>
#include "symbol_table.h"
#include "utils.h"

static struct wiki_node* table;
static struct wiki_scope* global_scope;
static struct wiki_scope* current_scope;

/* Keep track of all the used scopes for debug */
static int scope_num = 0;
static struct wiki_scope* scope_history[1024] = {NULL,};

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
    /* Debug history */
    scope_history[scope_num] = current_scope;
    scope_num++;
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
%token <node> LIST_ITEM_ENTRY
%token <node> LIST_ITEM_EXIT
%token LIST_EXIT
%token <node> DYNAMIC_ENTRY
%token <node> DYNAMIC_EXIT
%token <node> DYNAMIC_STRING
%token <node> DYNAMIC_ID
%token <node> DYNAMIC_ASSIG
%token END_OF_FILE
%token <node> LINK_ENTRY
%token LINK_EXIT
%token <node> LINK_URL
%token <node> LINK_NAME
%token LINK_SEPARATOR

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
%type <result> list_item 
%type <result> list_item_content
%type <result> list_item_parts
%type <result> list
%type <result> dynamic
%type <result> dynamic_assignment
%type <result> dynamic_print
%type <result> link 

%start wikitext

%%

wikitext
	: /* empty */
	| wikitext block {
            printf("%s", $2);
        }
	;

block
	: block_text {
//			$$ = produce_output("<p>\n", $1, "</p>\n");
//THIS DOES NOT WORK! it produces one paragraph for each character
		}
	| header
	| list 	{
			$$ = produce_output("<ul>\n", $1, "</ul>\n");
		}
	;

block_text
    : dynamic
	| bold
	| italic
	| monospace
	| underline
	| text
	| link
	;

link
	: LINK_ENTRY LINK_URL LINK_NAME LINK_EXIT {
			char buf[1024];
			snprintf(buf, sizeof buf, "<a href='%s'>%s</a>", $2->lexeme, $3->lexeme + 1);
			$$ = produce_output(buf, NULL, NULL);
		}
	| LINK_ENTRY LINK_URL LINK_EXIT {
			char buf[1024];
			snprintf(buf, sizeof buf, "<a href='%s'>%s</a>", $2->lexeme, $2->lexeme);
			$$ = produce_output(buf, NULL, NULL);
		}
	;

text
	: TEXT {
			add_symbol($1, current_scope);
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
    : dynamic
	| text
	| italic
	| underline
	| monospace
	;

bold_content
	: bold_parts 
	| bold_content bold_parts {
		//	printf("BP: '%s'\n", $2);
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
	| italic_content italic_parts {
			$$ = produce_output($$, $2, NULL); 
		}
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
			if(level > 6) {
				level = 6;
			}
            char buf1[10];
            char buf2[10];
            sprintf(buf1, "<h%d>", level);
            sprintf(buf2, "</h%d>", level);
			
			// Too many equal signs? Produce output... 
			char *equalsigns = trim(strdup($4->lexeme));
			if(level < strlen(equalsigns)) {
				char buf3[512];
				char buf4[1024];
				snprintf(buf3, strlen($4->lexeme) - level + 1, "%s", $4->lexeme);			
				snprintf(buf4, sizeof buf4, "%s%s", buf3, buf2);
            	$$ = produce_output(buf1, $3, buf4);
			} else {
				$$ = produce_output(buf1, $3, buf2);
			}
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
    : dynamic
	| text
	;

list
	: list_item LIST_EXIT {
			$$ = produce_output($1, NULL, NULL);
		}
	| list_item END_OF_FILE {
			$$ = produce_output($1, NULL, NULL);
		}
	| list_item list {
			$$ = produce_output($1, $2, NULL);
		} 
	;

list_item
    : LIST_ITEM_ENTRY {
            set_new_scope("list_item");
        }
    list_item_content
    LIST_ITEM_EXIT {
            $$ = produce_output("<li>", $3, "</li>\n");
            scope_go_up();
        }
	;

list_item_content 
	: list_item_parts
	| list_item_content list_item_parts {
			$$ = produce_output($$, $2, NULL);
		}
	;

list_item_parts
	: block_text
	;

dynamic
	: DYNAMIC_ENTRY dynamic_print DYNAMIC_EXIT {
			$$ = strdup($2);
		}
	| DYNAMIC_ENTRY dynamic_assignment DYNAMIC_EXIT {
			$$ = strdup($2);
		}
	;

dynamic_assignment
	: DYNAMIC_ID DYNAMIC_ASSIG DYNAMIC_STRING {
	bool overwrite = false;
	            struct wiki_node* variable = find_identifier($1->lexeme, current_scope);
	        if (variable != NULL)
	        {
                /* If we find a variable, check for its scope */
                if (variable->scope == current_scope)
                {
                    /* If we have it, overwrite */
                    variable->value = strdup($3->lexeme);
                    overwrite = true;
                }
	        }
	        if (!overwrite)
	        {
                add_symbol($1, current_scope);
                /* Set it to variable type */
                $1->type = TYPE_VARIABLE;
                /* The value is the actual content */
                $1->value = strdup($3->lexeme);
            }
            $$ = ""; // nothing is outputted when assigning
//			$$ = produce_output("DYNAMIC_ASSIGNMENT: ", $1->lexeme, $3->lexeme);			
		}
	;

dynamic_print
	: DYNAMIC_ID {
//            $$ = produce_output("DYNAMIC_OUTPUT: ", $1->lexeme, NULL);
            struct wiki_node* variable = find_identifier($1->lexeme, current_scope);
            if (variable == NULL)
            {
                char tmp[512];
                sprintf(tmp, "%s not found!", $1->lexeme);
                yyerror(tmp);
                exit(1);
            }
            else {
                $$ = strdup(variable->value);
            }
		}
	;

%%

#include "lex.yy.c"

/* Called by yyparse on error.  */
int yyerror (char const *s)
{
    fprintf(stderr, "error, %s: '%s' in line %d\n", s, yytext, yylineno);
}

int main(void)
{
    /* Symbol table initialization and test */
    global_scope = scope_init();
    current_scope = global_scope;
//    fprintf(stderr, "Initial symbol table size: %d\n", symbol_table_length(table));
//    if (table == NULL)
//        fprintf(stderr, "Unable to allocate memory for symbol table\n");
    int err = yyparse();
    int i = 0;
//    fprintf(stderr, "Final symbol table lenght: %d\n", symbol_table_length(table));
    for (i; i < scope_num; i++)
        print_symbol_table(scope_history[i]);
//    symbol_table_free();
    return err;
}
