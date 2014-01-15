%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

//struct wiki_node* current_lexeme = NULL;

struct wiki_node* create_node(char* lexeme, long line_number)
{
    struct wiki_node* node = get_new_node();
    node->lexeme = lexeme;
    node->value = strdup(lexeme);
    node->line_number = line_number;
    return node;
}

%}

/* Scopes (aka named lexer states) */
%x HEADER

/* Comments */
/* TODO think a single line comment, if needed ;) */
/*SINGLELINE_COMMENT           \-\-.* */
WS					[\t ]
NEWLINE 			[\n\r]
MULTILINE_COMMENT   "/*"([^/]|"/"[^*])*"*/"
BOLD				"\*\*"
ITALIC 				"\/\/"
UNDERLINE			"__"
MONOSPACE			"\'\'"
HEADER_ENTRY		^("=")+
HEADER_EXIT			"="+{WS}*{NEWLINE}

%%

{BOLD} {
	yylval.node = create_node(strdup(yytext), yylineno);
	return BOLD;
}

{ITALIC} {
	yylval.node = create_node(strdup(yytext), yylineno); 
	return ITALIC;
}

{UNDERLINE} {
	yylval.node = create_node(strdup(yytext), yylineno); 
	return UNDERLINE;
}

{MONOSPACE} {
	yylval.node = create_node(strdup(yytext), yylineno); 
	return MONOSPACE;
}

{MULTILINE_COMMENT} { 
	/* do nothing */ 
}

{HEADER_ENTRY} { 
	BEGIN HEADER;
	fprintf(stderr, "HEADER_ENTRY: %s\n", yytext);
	yylval.node = create_node(strdup(yytext), yylineno);
	return HEADER_ENTRY;
}

<HEADER>{HEADER_EXIT} {
	// Return to default scope
	BEGIN 0; 
	
	// Restore the last {NEWLINE} character
	yyless(strlen(yytext) - 1);

	fprintf(stderr, "HEADER_EXIT: %s\n", yytext);
	yylval.node = create_node(strdup(yytext), yylineno);
	return HEADER_EXIT;
}

<*>. {
	yylval.node = create_node(strdup(yytext), yylineno);
	return TEXT;
}
%%
