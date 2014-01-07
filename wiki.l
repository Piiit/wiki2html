%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

//struct wiki_node* current_lexeme = NULL;

struct wiki_node* create_node(char* lexeme)
{
    struct wiki_node* node = get_new_node();
    node->lexeme = lexeme;
    node->value = strdup(lexeme);
    return node;
}

%}

/* Comments */
/* TODO think a single line comment, if needed ;) */
/*SINGLELINE_COMMENT           \-\-.* */
MULTILINE_COMMENT            "/*"([^/]|"/"[^*])*"*/"

%%

[a-zA-Z0-9 \t\n]+   yylval.node = create_node(strdup(yytext)); return TEXT;
"\*\*"              yylval.node = create_node(strdup(yytext)); return BOLD;
"\/\/"              yylval.node = create_node(strdup(yytext)); return ITALIC;
"__"				yylval.node = create_node(strdup(yytext)); return UNDERLINE;
"\'\'"				yylval.node = create_node(strdup(yytext)); return MONOSPACE;

{MULTILINE_COMMENT}            { /* do nothing */ }

%%
