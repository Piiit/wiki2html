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
WS	[\t ]
NEWLINE [\n\r]
MULTILINE_COMMENT            "/*"([^/]|"/"[^*])*"*/"

%x HEADER

%%

"\*\*"              yylval.node = create_node(strdup(yytext)); return BOLD;
"\/\/"              yylval.node = create_node(strdup(yytext)); return ITALIC;
"__"				yylval.node = create_node(strdup(yytext)); return UNDERLINE;
"\'\'"				yylval.node = create_node(strdup(yytext)); return MONOSPACE;

{MULTILINE_COMMENT}            { /* do nothing */ }

^("=")+ {
	BEGIN HEADER;
	fprintf(stderr, "HEADER_ENTRY: %s\n", yytext);
	yylval.node = create_node(strdup(yytext));
	return HEADER_ENTRY;
}

<HEADER>"="+{WS}*{NEWLINE} {
	BEGIN 0;
//	printf("HEADER_EXIT: %s\n", yytext);
	yylval.node = create_node(strdup(yytext));
	return HEADER_EXIT;
}



<*>. {
	yylval.node = create_node(strdup(yytext));
	return TEXT;
}
%%
