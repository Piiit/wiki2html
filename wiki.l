%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
%}

/* Generics */
DIGIT           [0-9]
DIGITS          {DIGIT}*
LETTER          [a-zA-Z]
WS              [ \t\n]+
TEXT            ({LETTER}|{DIGIT}|{WS})+
/* Comments */
ONEC            \/\/.*
MULTIC          "/*"([^/]|"/"[^*])*"*/"
/* Formatting */
BOLD            \*\*
ITALIC          \/\/
UNDERLINE       __
MONOSPACE       \'\'
/* Identifiers and strings */
STRING          \".*\"
/* Usual identifier, start with at least 1 letter */
IDENTIFIER      {LETTER}({LETTER}|{DIGIT}|[_-])*

%%

{TEXT}  	{yylval.value = yytext; return TEXT;}
{BOLD} 		{return BOLD;}
{ITALIC} 	{return ITALIC;}
{UNDERLINE}	{return UNDERLINE;}

%%

