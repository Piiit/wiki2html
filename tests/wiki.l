%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
%}

%%

[a-zA-Z0-9 \t\n]+   yylval.value = yytext; return TEXT;
"\*\*"			 	return BOLD;

%%

