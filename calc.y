%{

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>


void yyerror(char *);
int yylex();

extern FILE *yyin;
extern FILE *yyout;
extern int yylineno;
%}

%union
{
    int intValue;
    float floatValue;
    char *stringValue;
}


%token <intValue> INT
%token <floatValue> FLOAT
%token <stringValue> STRING
%token <stringValue> IDENTIFIER
%token <stringValue> MODULE
%token <stringValue> IMPORT
%token <stringValue> NEWLINE
%token <stringValue> CLASS
%token <stringValue> INDENT
%token <stringValue> INLINE_COMMENT
%token <stringValue> MULTILINE_COMMENT
%token <stringValue> IF
%token <stringValue> ELIF
%token <stringValue> ELSE
%token <stringValue> ARITHMETIC_OP
%token <stringValue> IN
%token <stringValue> NOT
%token <stringValue> IS


%left '=' '+' '-' '*' '/' '(' ')' ':'

%start program

%type<intValue> exprINT;
%type<floatValue> exprFLOAT;
%type<stringValue> import_stmt2;

%%


program:
        /* empty */
        | main NEWLINE program
        | main
        ;


main:
        /* ignore newlines */
        | if_cmd
        | classdef
        | import_stmt
        | assignment
        | INLINE_COMMENT { printf("A comment here! %s\n", $1); }
        | MULTILINE_COMMENT { printf("A comment here! %s\n", $1); }
        ;


import_stmt:
        IMPORT import_stmt2            { printf("Import was successful for module %s\n", $2); }
        ;

import_stmt2:
        IDENTIFIER
        | MODULE
        ;


assignment:
        IDENTIFIER '=' STRING          { printf("Variable: %s | value: %s\n", $1, $3); }
        | IDENTIFIER '=' exprFLOAT     { printf("Variable: %s | value: %f\n", $1, $3); }
        | IDENTIFIER '=' exprINT       { printf("Variable: %s | value: %d\n", $1, $3); }
        ;


exprINT:
        '-' INT                        { $$ = -$2; /*printf("111-%d\n", $2);*/ }
        | INT                          { $$ = $1; /*printf("111-%d\n", $1);*/ }
        | '+' INT                      { $$ = $2; /*printf("111-%d\n", $2);*/ }
        | exprINT '+' exprINT          { $$ = $1 + $3; /*printf("%d + %d\n", $1, $3);*/ }
        | exprINT '-' exprINT          { $$ = $1 - $3; /*printf("%d - %d\n", $1, $3);*/ }
        | exprINT '*' exprINT          { $$ = $1 * $3; /*printf("%d * %d\n", $1, $3);*/ }
        | exprINT '/' exprINT          { $$ = $1 / $3; /*printf("%d / %d\n", $1, $3);*/ }
        ;


exprFLOAT:
        '-' FLOAT                      { $$ = -$2; /*printf("111-%f\n", $2);*/ }
        | FLOAT                        { $$ = $1; /*printf("222-%f\n", $1);*/ }
        | '+' FLOAT                    { $$ = $2; /*printf("222-%f\n", $2);*/ }
        | exprFLOAT '+' exprFLOAT      { $$ = $1 + $3; /*printf("%f + %f\n", $1, $3);*/ }
        | exprFLOAT '-' exprFLOAT      { $$ = $1 - $3; /*printf("%f - %f\n", $1, $3);*/ }
        | exprFLOAT '*' exprFLOAT      { $$ = $1 * $3; /*printf("%f * %f\n", $1, $3);*/ }
        | exprFLOAT '/' exprFLOAT      { $$ = $1 / $3; /*printf("%f / %f\n", $1, $3);*/ }
        ;


suite:
        /*empty*/
        | INDENT main suite
        ;

classdef:
        CLASS IDENTIFIER ':' NEWLINE suite { printf("New class with name %s\n", $2); }
        ;


if_cmd:
        IF expression ':' NEWLINE suite else_cmd { printf("IFFFFFFFFFFFF\n"); }
        ;


else_cmd:
        /*empty*/
        | NEWLINE ELIF expression ':' NEWLINE suite else_cmd
        | NEWLINE ELSE ':' NEWLINE suite
        ;

expression:
        exprINT ARITHMETIC_OP exprINT { printf("%d, %s, %d\n", $1, $2, $3); }
        | exprFLOAT ARITHMETIC_OP exprFLOAT
        ;

%%





void yyerror(char *s) {
    printf("Error | Line: %d\n%s\n", yylineno, s);
}


int main ( int argc, char **argv  ) 
{
    ++argv; --argc;
    if ( argc > 0 )
        yyin = fopen( argv[0], "r" );
    else
        yyin = stdin;
    yyout = fopen ( "output", "w" );
    yyparse();
    return 0;
}
