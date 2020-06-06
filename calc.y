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
%token <stringValue> DEF
%token <stringValue> FOR
%token <stringValue> PRINT


%left '=' '+' '-' '*' '/' '(' ')' ':' ',' '[' ']'


%start program

%type<intValue> exprINT;
%type<floatValue> exprFLOAT;
%type<stringValue> import_stmt;
%type<stringValue> import_stmt2;
%type<stringValue> function_call;
%type<stringValue> function_def;
%type<stringValue> if_cmd;
%type<stringValue> classdef;
%type<stringValue> assignment;

%%


program:
        /* empty */
        | main NEWLINE program
        | main
        ;


main:
        /* ignore newlines */
        | if_cmd                        { printf("%s\n", $1); }
        | for_cmd                       { printf("FOR LOOP\n"); }
        | classdef                      { printf("Class defined with name %s\n", $1); }
        | import_stmt                   { printf("Imported %s\n", $1); }
        | assignment
        | function_def                  { printf("Function defined with name: %s\n", $1); }
        | function_call                 { printf("A function call here! %s\n", $1); }
        | INLINE_COMMENT                { printf("A comment here! %s\n", $1); }
        | MULTILINE_COMMENT             { printf("A comment here! %s\n", $1); }
        | PRINT '(' STRING ')'          { printf("Print: %s\n", $3); }
        ;



import_stmt:
        IMPORT import_stmt2             { $$ = $2; }
        ;

import_stmt2:
        IDENTIFIER { $$ = $1; }
        | MODULE { $$ = $1; }
        ;


assignment:
        IDENTIFIER '=' STRING          { printf("Variable: %s | value: %s\n", $1, $3); }
        | IDENTIFIER '=' exprFLOAT     { printf("Variable: %s | value: %f\n", $1, $3); }
        | IDENTIFIER '=' exprINT       { printf("Variable: %s | value: %d\n", $1, $3); }
        | IDENTIFIER '=' function_call { printf("Variable: %s | function: %s\n", $1, $3); }
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
        INDENT main suite_
        ;

suite_: 
        /* empty */
        | NEWLINE
        | NEWLINE suite
        ;


classdef:
        CLASS IDENTIFIER ':' NEWLINE suite { $$ = $2; }
        ;


if_cmd:
        IF expression ':' NEWLINE suite else_cmd { $$ = "If Statement"; }
        ;


else_cmd:
        /*empty*/
        | ELIF expression ':' NEWLINE suite else_cmd
        | ELSE ':' NEWLINE suite
        ;

expression:
        exprINT ARITHMETIC_OP exprINT
        | exprFLOAT ARITHMETIC_OP exprFLOAT
        ;


function_def:
        DEF IDENTIFIER parameters ':' NEWLINE suite { $$ = $2; }
        ;


function_call:
        IDENTIFIER parameters { $$ = $1; }
        ;


parameters:
        '(' ')'
        | '(' arguments ')'
        ;

arguments:
        IDENTIFIER
        | exprINT
        | exprFLOAT
        | STRING
        | assignment
        | arguments ',' arguments
        ;

for_cmd:
        FOR IDENTIFIER IN list ':' NEWLINE suite
        ;

list:
        '[' ']'
        | '[' arguments ']'
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
