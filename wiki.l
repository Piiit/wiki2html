%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

//struct wiki_node* current_lexeme = NULL;

struct wiki_node* create_node(char* name, char* value)
{
    struct wiki_node* node = get_new_node();
    /* TODO we can use immediately the integer that lex produces for every token... */
    node->lexeme = name;
    node->value = value;
    return node;
}

%}

/* Comments */
/* TODO think a single line comment, if needed ;) */
/*SINGLELINE_COMMENT           \-\-.* */
MULTILINE_COMMENT            "/*"([^/]|"/"[^*])*"*/"

%%

[a-zA-Z0-9 \t\n]+   yylval.node = create_node("TEXT", strdup(yytext)); return TEXT;
"\*\*"              yylval.node = create_node("BOLD", strdup(yytext)); return BOLD;
"\/\/"              yylval.node = create_node("ITALIC", strdup(yytext)); return ITALIC;
"__"				yylval.node = create_node("UNDERLINE", strdup(yytext)); return UNDERLINE;
"\'\'"				yylval.node = create_node("MONOSPACE", strdup(yytext)); return MONOSPACE;

{MULTILINE_COMMENT}            { /* do nothing */ }

%%
