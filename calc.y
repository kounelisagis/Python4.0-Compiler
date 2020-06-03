%{
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>


void yyerror(char *);
int yylex();

extern FILE *yyin;
extern FILE *yyout;
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
%left '=' '+' '*' '/'

%start program


%type<stringValue> module;
%type<intValue> exprINT;
%type<floatValue> exprFLOAT;
%type<intValue> returnedInt;
%type<floatValue> returnedFloat;


%%

program:
        main
        ;


main:
        /* empty */
        | import_stmt main
        | exprINT main
        | exprFLOAT main
        | assignment main
        ;


import_stmt:
        IMPORT module                  { printf("Import was successful for module %s\n", $2); }
        ;


module:
        IDENTIFIER                     { printf("-----Identifier: %s\n", $1); }
        | MODULE                       { printf("-----Module: %s\n", $1); }
        ;


assignment:
        IDENTIFIER '=' exprINT         { printf("-----Variable: %s | value: %d\n", $1, $3); }
        | IDENTIFIER '=' exprFLOAT     { printf("-----Variable: %s | value: %f\n", $1, $3); }
        | IDENTIFIER '=' STRING        { printf("-----Variable: %s | value: %s\n", $1, $3); }
        ;


exprINT:
        returnedInt                    { $$ = $1; printf("1-%d\n", $1);} 
        | INT                          { $$ = $1; printf("111-%d\n", $1); }
        | exprINT '+' exprINT          { $$ = $1 + $3; printf("%d + %d\n", $1, $3); }
        | exprINT '-' exprINT          { $$ = $1 - $3; printf("%d - %d\n", $1, $3); }
        | exprINT '*' exprINT          { $$ = $1 * $3; printf("%d * %d\n", $1, $3); }
        | exprINT '/' exprINT          { $$ = $1 / $3; printf("%d / %d\n", $1, $3); }
        ;


exprFLOAT:
        returnedFloat                  { $$ = $1; printf("2-%f\n", $1);}
        | FLOAT                        { $$ = $1; printf("222-%f\n", $1); }
        | exprFLOAT '+' exprFLOAT      { $$ = $1 + $3; printf("%f + %f\n", $1, $3); }
        | exprFLOAT '-' exprFLOAT      { $$ = $1 - $3; printf("%f - %f\n", $1, $3); }
        | exprFLOAT '*' exprFLOAT      { $$ = $1 * $3; printf("%f * %f\n", $1, $3); }
        | exprFLOAT '/' exprFLOAT      { $$ = $1 / $3; printf("%f / %f\n", $1, $3); }
        ;


returnedInt:
        IDENTIFIER { $$ = 7; }
        ;


returnedFloat:
        IDENTIFIER { $$ = 5.7; }
        ;


%%




void yyerror(char *s) {
    printf("%s\n", s);
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
