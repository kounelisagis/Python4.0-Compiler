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
%left '=' '+' '*'
%start program


%type<intValue> expr;
%type<stringValue> module;


%%

program:
        main
        ;


main:
        /* empty */
        | import_stmt main
        | expr main
        | assignment main
        ;


import_stmt:
        IMPORT module { printf("Import was successful for module %s\n", $2); }
        ;

module:
        IDENTIFIER
        | MODULE
        ;


assignment:
        IDENTIFIER '=' expr { printf("-----Variable: %s", $1); }
        ;


expr:
        INT                      { $$ = $1; printf("1-%d\n", $1); }
        | FLOAT                  { $$ = $1; printf("2-%f\n", $1); }
        | expr '+' expr          { $$ = $1 + $3; printf("3-MATCH1\n"); }
        | expr '*' expr          { $$ = $1 * $3; printf("4-MATCH2\n"); }
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
