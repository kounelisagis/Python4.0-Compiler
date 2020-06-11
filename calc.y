%{
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "linked_list.c"

node_t * variables = NULL;
int lambda_flag = 0;
char * current_string = NULL;

void yyerror(char *);
int yylex();

extern FILE *yyin;
extern FILE *yyout;
extern int yylineno;

%}

%code requires {
    typedef struct {
        int intValue;
        double floatValue;
        char *stringValue;
        int type;
    } op_struct;


op_struct add(op_struct, op_struct);
op_struct sub(op_struct, op_struct);
op_struct mul(op_struct, op_struct);
op_struct divide(op_struct, op_struct);
void store_dict_element(op_struct, op_struct);
void push_element(op_struct);
void pop_element();

}

%union {
    int intValue;
    double floatValue;
    char *stringValue;
    op_struct myStruct;
};


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
%token <stringValue> LAMBDA


%left '=' '+' '-' '*' '/' '(' ')' ':' ',' '[' ']' '{' '}'


%start start

%type<stringValue> import_stmt;
%type<stringValue> import_stmt2;
%type<stringValue> function_call;
%type<stringValue> function_def;
%type<stringValue> if_cmd;
%type<stringValue> classdef;
%type<stringValue> assignment;
%type<myStruct> expr;
%type<myStruct> dict_element;

%%

start:
    program { print_list(variables); }
    ;

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
        | lambda                        { printf("Lambda function call here!\n"); }
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
        IDENTIFIER '=' STRING          { printf("Variable: %s | value: %s\n", $1, $3);
                                        variables = assign_variable(variables, $1, STRING_VALUE, -1, -1, $3);}
        | IDENTIFIER '=' expr          { if($<myStruct>3.type == 0) {
                                            printf("Variable: %s | value: %d\n", $1, $<myStruct>3.intValue);
                                            variables = assign_variable(variables, $1, INTEGER_VALUE, $<myStruct>3.intValue, -1, NULL);
                                        }
                                        else{
                                            printf("Variable: %s | value: %lf\n", $1, $<myStruct>3.floatValue);
                                            variables = assign_variable(variables, $1, FLOAT_VALUE, -1, $<myStruct>3.floatValue, NULL);
                                        }}
        | IDENTIFIER '=' function_call { printf("Variable: %s | function: %s\n", $1, $3); }
        | IDENTIFIER '=' { current_string = $1; } dictionary    { printf("Dictionary %s\n", $1); }
        ;

expr:
        /* empty */                    { if(!lambda_flag){ 
                                            $<myStruct>$.floatValue = 0; $<myStruct>$.intValue = 0; } 
                                        else{ 
                                            printf("LABDMA CALCULUS EMPTY ARGUMENTS! - line %d\n", yylineno);
                                            YYABORT; }}
        | IDENTIFIER                   {if(!lambda_flag){
                                        Variable* v = find_variable(variables, $1);
                                        if(v){
                                            $<myStruct>$.floatValue = v->floatValue;
                                            $<myStruct>$.intValue = v->intValue; }
                                        else {
                                            printf("Variable %s does not exist - line %d\n", $1, yylineno);
                                            YYABORT;
                                            } } }
        | FLOAT                        { $<myStruct>$.floatValue = $1; $<myStruct>$.type = 1; }
        | INT                          { $<myStruct>$.intValue = $1; $<myStruct>$.type = 0; }
        | expr '+' expr                { $$ = add($<myStruct>1, $<myStruct>3); }
        | expr '-' expr                { $$ = sub($<myStruct>1, $<myStruct>3); }
        | expr '*' expr                { $$ = mul($<myStruct>1, $<myStruct>3); }
        | expr '/' expr                { $$ = divide($<myStruct>1, $<myStruct>3); }
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
        expr ARITHMETIC_OP expr
        ;


function_def:
        DEF IDENTIFIER '(' def_arguments ')' ':' NEWLINE suite { $$ = $2; }
        ;


function_call:
        IDENTIFIER '(' call_arguments ')' { $$ = $1; }
        ;


call_arguments:
        expr
        | STRING
        | assignment
        | call_arguments ',' call_arguments
        ;

def_arguments:
        /* empty */
        | IDENTIFIER
        | assignment
        | def_arguments ',' def_arguments
        ;


for_cmd:
        FOR IDENTIFIER IN list ':' NEWLINE suite
        ;


list:
        '[' call_arguments ']'
        ;


lambda:
        LAMBDA def_arguments ':' { lambda_flag = 1; } expr { lambda_flag = 0; }
        ;

dictionary:
        '{' dict '}'
        | '{' '}'
        ;

dict:
        dict_element ':' dict_element { store_dict_element($<myStruct>1, $<myStruct>3); }
        | dict_element ':' { push_element($<myStruct>1); } dictionary { pop_element(); }
        | dict ',' dict
        ;

dict_element:
        STRING { $<myStruct>$.stringValue = $1; $<myStruct>$.type = STRING_VALUE; }
        | expr { $$ = $1; }
        ;
%%


void store_dict_element(op_struct a, op_struct b) {

    char *temp = malloc(sizeof(char)*100);
    strcpy(temp, current_string);
    strcat(temp, "$");

    if (a.type == INTEGER_VALUE) {
        char str[12];
        sprintf(str, "%d", a.intValue);
        strcat(temp, str);
    } else if (a.type == FLOAT_VALUE) {
        char str[12];
        sprintf(str, "%lf", a.floatValue);
        strcat(temp, str);
    } else {
        strcat(temp, "\"");
        strcat(temp, a.stringValue);
        strcat(temp, "\"");
    }

    variables = assign_variable(variables, temp, b.type, b.intValue, b.floatValue, b.stringValue);

}



void push_element(op_struct a) {
    strcat(current_string, "$"); 

    if (a.type == INTEGER_VALUE) {
        char str[12];
        sprintf(str, "%d", a.intValue);
        strcat(current_string, str);
    } else if (a.type == FLOAT_VALUE) {
        char str[12];
        sprintf(str, "%lf", a.floatValue);
        strcat(current_string, str);
    } else {
        strcat(current_string, "\"");
        strcat(current_string, a.stringValue);
        strcat(current_string, "\"");
    }
}

void pop_element() {
    int i=0;
    int last_pos;

    while(current_string[i] != '\0') {
        if(current_string[i] == '$')
            last_pos = i;
        i++;
    }
    current_string[last_pos] = '\0';
}


op_struct add(op_struct a, op_struct b) {
    
    op_struct result;

    if(a.type == 0 && b.type == 0){
        result.intValue = a.intValue + b.intValue;
        result.type = 0;
    }
    else{
        result.floatValue;
        result.type = 1;

        if(a.type == 0)
            result.floatValue = a.intValue;
        else
            result.floatValue = a.floatValue;

        if(b.type == 0)
            result.floatValue += b.intValue;
        else
            result.floatValue += b.floatValue;
    }

    return result;
}

op_struct sub(op_struct a, op_struct b) {
    
    op_struct result;

    if(a.type == 0 && b.type == 0){
        result.intValue = a.intValue - b.intValue;
        result.type = 0;
    }
    else{
        result.floatValue;
        result.type = 1;

        if(a.type == 0)
            result.floatValue = a.intValue;
        else
            result.floatValue = a.floatValue;

        if(b.type == 0)
            result.floatValue -= b.intValue;
        else
            result.floatValue -= b.floatValue;
    }

    return result;
}

op_struct mul(op_struct a, op_struct b) {
    
    op_struct result;

    if(a.type == 0 && b.type == 0){
        result.intValue = a.intValue * b.intValue;
        result.type = 0;
    }
    else{
        result.floatValue;
        result.type = 1;

        if(a.type == 0)
            result.floatValue = a.intValue;
        else
            result.floatValue = a.floatValue;

        if(b.type == 0)
            result.floatValue *= b.intValue;
        else
            result.floatValue *= b.floatValue;
    }

    return result;
}

op_struct divide(op_struct a, op_struct b) {
    
    op_struct result;

    if(a.type == 0 && b.type == 0){
        result.intValue = a.intValue / b.intValue;
        result.type = 0;
    }
    else{
        result.floatValue;
        result.type = 1;

        if(a.type == 0)
            result.floatValue = a.intValue;
        else
            result.floatValue = a.floatValue;

        if(b.type == 0)
            result.floatValue /= b.intValue;
        else
            result.floatValue /= b.floatValue;
    }

    return result;
}


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
