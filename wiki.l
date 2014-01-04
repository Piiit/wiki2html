%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
%}

DIGIT    		[0-9]
LETTER   		[a-zA-Z]
WS		 		[ \t\n]+
TEXT	 		({LETTER}|{DIGIT}|{WS})+
BOLD			\*\*
ITALIC			\/\/
UNDERLINE		__

%%

{TEXT}  	{yylval.value = yytext; return TEXT;}
{BOLD} 		{return BOLD;}
{ITALIC} 	{return ITALIC;}
{UNDERLINE}	{return UNDERLINE;}

%%

