%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
%}

%%

[a-zA-Z0-9 \t\n]+   yylval.value = strdup(yytext); return TEXT;
"\*\*"              return BOLD;
"\/\/"              return ITALIC;

%%
