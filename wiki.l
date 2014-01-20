%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"
#include "utils.h"

//struct wiki_node* current_lexeme = NULL;

struct wiki_node* create_node(char* lexeme, long line_number)
{
    struct wiki_node* node = get_new_node();
    node->lexeme = lexeme;
    node->value = strdup(lexeme);
    node->line_number = line_number;
    return node;
}

int last_state = -1;

%}

/* Scopes (aka named lexer states) */
%x HEADER
%x LIST_ITEM
%x LIST
%x DYNAMIC
%x LINK

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
HEADER_ENTRY		^("=")+{WS}*
HEADER_EXIT			{WS}*"="+{WS}*{NEWLINE}
LIST_ITEM_ENTRY		({NEWLINE}?{WS}*\*[^\*]{WS}*)
LIST_ITEM_EXIT		{NEWLINE}
LIST_ENTRY			^{LIST_ITEM_ENTRY}	
LIST_EXIT			({WS}*[^\*])
DYNAMIC_ENTRY		"{{"
DYNAMIC_EXIT		"}}"
DYNAMIC_STRING      "\""([^\]|"/"[^\"])*"\""
DYNAMIC_ID			[a-zA-Z][a-zA-Z0-9]*
DYNAMIC_ASSIG		":="
LINK_ENTRY			"\[\["
LINK_EXIT			"\]\]"
LINK_URL			([\w]+?:\/\/)*[^ \"\n\r\t<\]\|]+
LINK_SEPARATOR		[\| ]
LINK_NAME			{LINK_SEPARATOR}[^\]]*
NO_TOC				"~~NOTOC~~"

%%

<*>{LINK_ENTRY} {
	BEGIN LINK;
	lexer_states_push(LINK);

	yylval.node = create_node(strdup(yytext), yylineno);
	fprintf(stderr, "LINK_ENTRY: %s\n", yytext);
	return LINK_ENTRY;
}

{NO_TOC} {
	return NO_TOC;
}

<LINK>{LINK_EXIT} {
	BEGIN lexer_states_pop();
	fprintf(stderr, "LINK_EXIT: %s\n", yytext);
	return LINK_EXIT;
}

<LINK>{LINK_URL} {
	yylval.node = create_node(strdup(yytext), yylineno);
	fprintf(stderr, "LINK_URL: %s\n", yytext);
	return LINK_URL;
}

<LINK>{LINK_NAME} {
	yylval.node = create_node(strdup(yytext), yylineno);
	fprintf(stderr, "LINK_NAME: %s\n", yytext);
	return LINK_NAME;
}

<<EOF>> {
	fprintf(stderr, "EOF: %s\n", yytext);
	return END_OF_FILE;
}

<*>{BOLD} {
	yylval.node = create_node(strdup(yytext), yylineno);
	fprintf(stderr, "BOLD: %s\n", yytext);
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
	return MONOSPACE;}

<*>{DYNAMIC_ENTRY} {
	BEGIN DYNAMIC;
	lexer_states_push(DYNAMIC);

	fprintf(stderr, "DYNAMIC_ENTRY: %s\n", yytext);
	yylval.node = create_node(strdup(yytext), yylineno);
	return DYNAMIC_ENTRY;
}

<DYNAMIC>{WS} {
	/* ignore white spaces */
}

<DYNAMIC>{DYNAMIC_EXIT} {
	// Return to default scope
	BEGIN lexer_states_pop(); 
	
	fprintf(stderr, "DYNAMIC_EXIT: %s\n", yytext);
	yylval.node = create_node(strdup(yytext), yylineno);
	return DYNAMIC_EXIT;
}

<DYNAMIC>{DYNAMIC_ID} {
	fprintf(stderr, "DYNAMIC_ID: %s\n", yytext);
	yylval.node = create_node(strdup(yytext), yylineno);
	return DYNAMIC_ID;
}

<DYNAMIC>{DYNAMIC_ASSIG} {
	fprintf(stderr, "DYNAMIC_ASSIG: %s\n", yytext);
	return DYNAMIC_ASSIG;
}

<DYNAMIC>{DYNAMIC_STRING} {
	fprintf(stderr, "DYNAMIC_STRING: %s\n", yytext);
	char *to = strndup(yytext + 1, yyleng - 2);
	yylval.node = create_node(to, yylineno);
	return DYNAMIC_STRING;
}

{MULTILINE_COMMENT} { 
	/* do nothing */ 
}

{HEADER_ENTRY} { 
	BEGIN HEADER;
	lexer_states_push(HEADER);

	fprintf(stderr, "HEADER_ENTRY: %s\n", yytext);
	char *header = trim(strdup(yytext));
	 
	yylval.node = create_node(header, yylineno);
	return HEADER_ENTRY;
}

<HEADER>{HEADER_EXIT} {
	// Return to default scope
	BEGIN lexer_states_pop(); 
	
	// Restore the last {NEWLINE} character
	yyless(strlen(yytext) - 1);

	fprintf(stderr, "HEADER_EXIT: %s\n", yytext);
	
	yylval.node = create_node(strdup(yytext), yylineno);
	return HEADER_EXIT;
}

{LIST_ENTRY} {
	BEGIN LIST;
	lexer_states_push(LIST);

	yyless(0);

	fprintf(stderr, "LIST_ENTRY (state=%d): %s\n", last_state, yytext);
	return LIST_ENTRY;
}

<LIST>{LIST_ITEM_ENTRY} { 
	BEGIN LIST_ITEM;
	lexer_states_push(LIST_ITEM);

	fprintf(stderr, "LIST_ITEM_ENTRY (state=%d): %s\n", last_state, yytext);
	yylval.node = create_node(strdup(yytext), yylineno);
	return LIST_ITEM_ENTRY;
}

<LIST_ITEM>{LIST_ITEM_EXIT} {
	BEGIN lexer_states_pop();
	
	//yyless(0);
	
	fprintf(stderr, "LIST_ITEM_EXIT: %s\n", yytext);
	yylval.node = create_node(strdup(yytext), yylineno);
	return LIST_ITEM_EXIT;
}

<LIST>{LIST_EXIT} {
	//lexer_states_pop();
	BEGIN lexer_states_pop();
	fprintf(stderr, "LIST_EXIT: %s\n", yytext);
	
	//Restore input buffer...
	yyless(0);

	return LIST_EXIT;
}

<*>\n|. {
	lexer_states_get();
	//fprintf(stderr, "TEXT: %s\n", yytext);
	yylval.node = create_node(strdup(yytext), yylineno);
	return TEXT;
}
%%
