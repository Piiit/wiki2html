%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
%}

/* Comments */
/* TODO think a single line comment, if needed ;) */
/*SINGLELINE_COMMENT           \-\-.* */
MULTILINE_COMMENT            "/*"([^/]|"/"[^*])*"*/"

%%

[a-zA-Z0-9 \t\n]+   yylval.value = strdup(yytext); return TEXT;
"\*\*"              return BOLD;
"\/\/"              return ITALIC;
"__"				return UNDERLINE;
"\'\'"				return MONOSPACE;

{MULTILINE_COMMENT}            { /* do nothing */ }

%%
