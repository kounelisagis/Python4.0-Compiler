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

%left '=' '+' '-' '*' '/' '(' ')' ':'

%start program

%type<intValue> exprINT;
%type<floatValue> exprFLOAT;

%%

program:
        main
        ;


main:
        /* empty */
        | classdef main
        | import_stmt NEWLINE main
        | assignment NEWLINE main
        | NEWLINE main /*ignore newlines*/
        ;


import_stmt:
        IMPORT IDENTIFIER              { printf("Import was successful for module %s\n", $2); }
        | IMPORT MODULE                { printf("Import was successful for module %s\n", $2); }
        ;


assignment:
        IDENTIFIER '=' STRING          { printf("-----Variable: %s | value: %s\n", $1, $3); }
        | IDENTIFIER '=' exprFLOAT     { printf("-----Variable: %s | value: %f\n", $1, $3); }
        | IDENTIFIER '=' exprINT       { printf("-----Variable: %s | value: %d\n", $1, $3); }
        ;


exprINT:
        '-' INT                        { $$ = -$2; printf("111-%d\n", $2); }
        | INT                          { $$ = $1; printf("111-%d\n", $1); }
        | '+' INT                      { $$ = $2; printf("111-%d\n", $2); }
        | exprINT '+' exprINT          { $$ = $1 + $3; printf("%d + %d\n", $1, $3); }
        | exprINT '-' exprINT          { $$ = $1 - $3; printf("%d - %d\n", $1, $3); }
        | exprINT '*' exprINT          { $$ = $1 * $3; printf("%d * %d\n", $1, $3); }
        | exprINT '/' exprINT          { $$ = $1 / $3; printf("%d / %d\n", $1, $3); }
        ;


exprFLOAT:
        '-' FLOAT                      { $$ = -$2; printf("111-%f\n", $2); }
        | FLOAT                        { $$ = $1; printf("222-%f\n", $1); }
        | '+' FLOAT                    { $$ = $2; printf("222-%f\n", $2); }
        | exprFLOAT '+' exprFLOAT      { $$ = $1 + $3; printf("%f + %f\n", $1, $3); }
        | exprFLOAT '-' exprFLOAT      { $$ = $1 - $3; printf("%f - %f\n", $1, $3); }
        | exprFLOAT '*' exprFLOAT      { $$ = $1 * $3; printf("%f * %f\n", $1, $3); }
        | exprFLOAT '/' exprFLOAT      { $$ = $1 / $3; printf("%f / %f\n", $1, $3); }
        ;


classdef:
        CLASS IDENTIFIER ':' NEWLINE suite
        ;

suite:
        /*empty*/
        | INDENT main suite
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
