%{
#include "y.tab.h"  
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap

digit [0-9]
num	{digit}+
float ({digit}*)\.({num})
letter [a-zA-Z]
string {letter}+
identifier ({letter}|_)({letter}|{digit}|_)*
module ({identifier}\.)*{identifier}


%%
[ \t\n] ;
"import" { yylval.stringValue = "import"; return IMPORT; }

{identifier} { yylval.stringValue = yytext; return IDENTIFIER; }

{module} { yylval.stringValue = yytext; return MODULE; }

{num} { yylval.intValue = atoi(yytext); return INT; }

{float} { yylval.floatValue = atof(yytext); return FLOAT; }

"=" { return '='; }
"+" { return '+'; }
"*" { return '*'; }
. ;
%%
