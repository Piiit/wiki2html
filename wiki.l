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
%x LIST_ITEM
%x DYNAMIC

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
LIST_ITEM_ENTRY		^({WS}*\*{WS})
LIST_ITEM_EXIT		{WS}*{NEWLINE}
DYNAMIC_ENTRY		"{{"
DYNAMIC_EXIT		"}}"
DYNAMIC_STRING      "\""([^\]|"/"[^\"])*"\""
DYNAMIC_ID			[a-zA-Z][a-zA-Z0-9]*
DYNAMIC_ASSIG		":="

%%

<*>{BOLD} {
	yylval.node = create_node(strdup(yytext), yylineno);
	return BOLD;
}

<*>{ITALIC} {
	yylval.node = create_node(strdup(yytext), yylineno); 
	return ITALIC;
}

<*>{UNDERLINE} {
	yylval.node = create_node(strdup(yytext), yylineno); 
	return UNDERLINE;
}

<*>{MONOSPACE} {
	yylval.node = create_node(strdup(yytext), yylineno); 
	return MONOSPACE;
}

<*>{DYNAMIC_ENTRY} {
	BEGIN DYNAMIC;
//	fprintf(stderr, "DYNAMIC_ENTRY: %s\n", yytext);
	yylval.node = create_node(strdup(yytext), yylineno);
	return DYNAMIC_ENTRY;
}

<DYNAMIC>{WS} {
	/* ignore white spaces */
}

<DYNAMIC>{DYNAMIC_EXIT} {
	// Return to default scope
	BEGIN 0; 
	
//	fprintf(stderr, "DYNAMIC_EXIT: %s\n", yytext);
	yylval.node = create_node(strdup(yytext), yylineno);
	return DYNAMIC_EXIT;
}

<DYNAMIC>{DYNAMIC_ID} {
//	fprintf(stderr, "DYNAMIC_ID: %s\n", yytext);
	yylval.node = create_node(strdup(yytext), yylineno);
	return DYNAMIC_ID;
}

<DYNAMIC>{DYNAMIC_ASSIG} {
//	fprintf(stderr, "DYNAMIC_ASSIG: %s\n", yytext);
	return DYNAMIC_ASSIG;
}

<DYNAMIC>{DYNAMIC_STRING} {
//	fprintf(stderr, "DYNAMIC_STRING: %s\n", yytext);
	char *to = strndup(yytext + 1, yyleng - 2);
	yylval.node = create_node(strdup(to), yylineno);
	return DYNAMIC_STRING;
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

<*>{LIST_ITEM_ENTRY} { 
	BEGIN LIST_ITEM;
	fprintf(stderr, "LIST_ITEM_ENTRY: %s\n", yytext);
	yylval.node = create_node(strdup(yytext), yylineno);
	return LIST_ITEM_ENTRY;
}

<LIST_ITEM>{LIST_ITEM_EXIT} {
	// Return to default scope
	BEGIN 0; 

	fprintf(stderr, "LIST_ITEM_EXIT: %s\n", yytext);
	yylval.node = create_node(strdup(yytext), yylineno);
	return LIST_ITEM_EXIT;
}

<*>. {
	yylval.node = create_node(strdup(yytext), yylineno);
	return TEXT;
}
%%
