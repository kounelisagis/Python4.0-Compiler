%{
#include "y.tab.h"  
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap
%option yylineno


digit [0-9]
num {digit}+
float ({digit}*)\.({num})
letter [a-zA-Z]
string \"(\\.|[^"\\])*\"
identifier ({letter}|_)({letter}|{digit}|_)*
module ({identifier}\.)*{identifier}


%%
[\n]            { yylval.stringValue = "\n"; return NEWLINE; }
[\t]            { yylval.stringValue = "\t"; return INDENT; }

[ ]             { /*printf("SPACE\n");*/ };

"import"        { /*printf("import\n");*/ yylval.stringValue = "import"; return IMPORT; }

"class"         { /*printf("class\n");*/ yylval.stringValue = "class"; return CLASS; }

{identifier}    { printf("identifier\n"); yylval.stringValue = strdup(yytext); return IDENTIFIER; }

{module}        { printf("module\n"); yylval.stringValue = strdup(yytext); return MODULE; }

{num}           { /*printf("num\n");*/ yylval.intValue = atoi(yytext); return INT; }

{float}         { /*printf("float\n");*/ yylval.floatValue = atof(yytext); return FLOAT; }

{string}        { /*printf("string\n");*/ yylval.stringValue = strdup(yytext); return STRING; }


"="             { /*printf("=\n");*/ return '='; }
"+"             { /*printf("+\n");*/ return '+'; }
"-"             { /*printf("-\n");*/ return '-'; }
"*"             { /*printf("*\n");*/ return '*'; }
"/"             { /*printf("/\n");*/ return '/'; }

"("             { /*printf("(\n");*/ return '('; }
")"             { /*printf(")\n");*/ return ')'; }

":"             { /*printf(":\n");*/ return ':'; }


. ;
%%
