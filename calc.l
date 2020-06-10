%{
#include "y.tab.h"  
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* remove_quotes(char*);
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
inlineComment #(\\.|[^\n\\])*
multilineComment \'\'\'(\\.|[^\\])*\'\'\'
arithmetic_op <|>|==|>=|<=|<>|!=


%%
[\n]            { yylval.stringValue = "\n"; return NEWLINE; }

[\t]            { yylval.stringValue = "\t"; return INDENT; }

[ ]             { /*printf("SPACE\n");*/ };

{inlineComment} { /*printf("comment\n");*/ yylval.stringValue = strdup(yytext); return INLINE_COMMENT; }

{multilineComment} { /*printf("comment\n");*/ yylval.stringValue = strdup(yytext); return MULTILINE_COMMENT; }

"print"         { /*printf("print\n");*/ yylval.stringValue = "print"; return PRINT; }

"import"        { /*printf("import\n");*/ yylval.stringValue = "import"; return IMPORT; }

"lambda"         { /*printf("lambda\n");*/ yylval.stringValue = "lambda"; return LAMBDA; }

"class"         { /*printf("class\n");*/ yylval.stringValue = "class"; return CLASS; }

"if"            { /*printf("if\n");*/ yylval.stringValue = "if"; return IF; }

"elif"          { /*printf("elif\n");*/ yylval.stringValue = "elif"; return ELIF; }

"else"          { /*printf("else\n");*/ yylval.stringValue = "else"; return ELSE; }

"in"            { /*printf("in\n");*/ yylval.stringValue = "in"; return IN; }

"not"           { /*printf("not\n");*/ yylval.stringValue = "not"; return NOT; }

"is"            { /*printf("is\n");*/ yylval.stringValue = "is"; return IS; }

"def"           { /*printf("def\n");*/ yylval.stringValue = "def"; return DEF; }

"for"           { /*printf("for\n");*/ yylval.stringValue = "for"; return FOR; }

{identifier}    { /*printf("identifier\n");*/ yylval.stringValue = strdup(yytext); return IDENTIFIER; }

{module}        { /*printf("module\n");*/ yylval.stringValue = strdup(yytext); return MODULE; }

{num}           { /*printf("num\n");*/ yylval.intValue = atoi(yytext); return INT; }

{float}         { /*printf("float\n");*/ yylval.floatValue = atof(yytext); return FLOAT; }

{string}        { /*printf("string\n");*/ yylval.stringValue = remove_quotes(strdup(yytext)); return STRING; }

{arithmetic_op} { /*printf("comparison\n");*/ yylval.stringValue = "arithmetic_op"; return ARITHMETIC_OP; }

"="             { /*printf("=\n");*/ return '='; }

"+"             { /*printf("+\n");*/ return '+'; }

"-"             { /*printf("-\n");*/ return '-'; }

"*"             { /*printf("*\n");*/ return '*'; }

"/"             { /*printf("/\n");*/ return '/'; }

"("             { /*printf("(\n");*/ return '('; }

")"             { /*printf(")\n");*/ return ')'; }

":"             { /*printf(":\n");*/ return ':'; }

","             { /*printf(",\n");*/ return ','; }

"["             { /*printf("[\n");*/ return '['; }

"]"             { /*printf("]\n");*/ return ']'; }

. ;


%%


char* remove_quotes(char* c){
    int i=0;
    char* new_char = c+1;
    while(new_char[i] != '\"'){
        i++;
    }
    *(new_char+i) = '\0';
    return new_char;
}
