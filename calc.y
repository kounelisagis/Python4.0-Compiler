%{
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "linked_list.h"


node_t * dictionaries = NULL;
node_t * variables = NULL;
node_t * arguments_stack = NULL;


void push_dictionary();
Dictionary * pop_dictionary();
int dict_items(char*);

int lambda_flag = 0;


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
    void store_element_element(op_struct, op_struct);
    void store_element_dictionary(op_struct, Dictionary*);
}

%union {
    int intValue;
    double floatValue;
    char *stringValue;
    op_struct myStruct;
    Dictionary * dictionary;
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
%token <stringValue> AS


%left '=' '+' '-' '*' '/' '(' ')' ':' '.' '[' ']' '{' '}' ','

%start start

%type<stringValue> import_stmt;
%type<stringValue> call_arguments;
%type<stringValue> package;
%type<stringValue> function_call;
%type<stringValue> class_function_call;
%type<stringValue> function_def;
%type<stringValue> if_cmd;
%type<stringValue> classdef;
%type<stringValue> assignment;
%type<myStruct> expr;
%type<myStruct> dict_element;
%type<dictionary> dictionary;
%type<dictionary> dict;

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
        | class_function_call           { printf("A function call from object! %s\n", $1); }
        | lambda                        { printf("Lambda function call here!\n"); }
        | INLINE_COMMENT                { printf("A comment here! %s\n", $1); }
        | MULTILINE_COMMENT             { printf("A comment here! %s\n", $1); }
        | PRINT '(' STRING ')'          { printf("Print: %s\n", $3); }
        ;



import_stmt:
        IMPORT package { $$ = $2; }
        | IMPORT package AS IDENTIFIER { char str[512]; sprintf(str, "%s as %s", $2, $4); $$ = str; }
        ;

package:
        IDENTIFIER { $$ = $1; }
        | package '.' package { char str[512]; sprintf(str, "%s.%s", $1, $3); $$ = str; }
        ;


assignment:
        IDENTIFIER '=' STRING          { printf("Variable: %s | value: %s\n", $1, $3);
                                        variables = assign_variable(variables, $1, STRING_VALUE, -1, -1, $3, NULL);}
        | IDENTIFIER '=' expr          { if($<myStruct>3.type == INTEGER_VALUE) {
                                            printf("Variable: %s | value: %d\n", $1, $<myStruct>3.intValue);
                                            variables = assign_variable(variables, $1, INTEGER_VALUE, $<myStruct>3.intValue, -1, NULL, NULL);
                                        }
                                        else{
                                            printf("Variable: %s | value: %lf\n", $1, $<myStruct>3.floatValue);
                                            variables = assign_variable(variables, $1, FLOAT_VALUE, -1, $<myStruct>3.floatValue, NULL, NULL);
                                        }}
        | IDENTIFIER '=' function_call { printf("Variable: %s | function: %s\n", $1, $3); }
        | IDENTIFIER '=' dictionary    {    variables = assign_variable(variables, $1, DICTIONARY, -1, -1, NULL, $3);
                                            printf("Dictionary %s\n", $1); }
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
        IDENTIFIER '(' call_arguments ')' { arguments_stack = push_front(arguments_stack, NULL, STRING_VALUE, -1, -1, $1, NULL); print_list(arguments_stack); arguments_stack = NULL; }
        ;


call_arguments:
        expr { arguments_stack = push_front(arguments_stack, NULL, $1.type, $1.intValue, $1.floatValue, NULL, NULL); } 
        | STRING { arguments_stack = push_front(arguments_stack, NULL, STRING_VALUE, -1, -1, $1, NULL); }
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
        '{' { push_dictionary(); } dict '}' { $$ = pop_dictionary(); }
        | '{' '}' { $$ = (Dictionary*)malloc(sizeof(Dictionary)); $$->keys = NULL; $$->values = NULL; }
        ;


dict:
        dict_element ':' dict_element { store_element_element($<myStruct>1, $<myStruct>3); }
        | dict_element ':' dictionary { store_element_dictionary($<myStruct>1, $3);/*$$ = $3;*/ }
        | dict ',' dict
        ;


dict_element:
        STRING { $<myStruct>$.stringValue = $1; $<myStruct>$.type = STRING_VALUE; }
        | expr { $$ = $1; }
        ;


class_function_call:
        IDENTIFIER '.' function_call { char str[512]; sprintf(str, "%s.%s()", $1, $3); $$ = str;
                                        if(strcmp($3, "items") == 0) {
                                            int res = dict_items($1);
                                            if (res == -1) {
                                                YYABORT;
                                            }
                                        }
                                        if(strcmp($3, "setdefault") == 0){
                                            
                                        }
                                     }
        ;

%%



int dict_items(char * variable_name) {

    Variable* found_variable = find_variable(variables, variable_name);
    if(found_variable) {
        if(found_variable->type != DICTIONARY){
            if(found_variable->type == INTEGER_VALUE)
                printf("'int' object has no attribute 'items'\n");
            else if(found_variable->type == FLOAT_VALUE)
                printf("'float' object has no attribute 'items'\n");
            else if(found_variable->type == STRING_VALUE)
                printf("'str' object has no attribute 'items'\n");
            return -1;
        }
    }
    else {
        printf("name %s is not defined\n", variable_name);
        return -1;
    }


    Dictionary * dict = found_variable->dictionary;

    node_t * keys = dict->keys;
    node_t * values = dict->values;
    printf("[");

    while(keys) {

        if(keys->val.type == INTEGER_VALUE)
            printf("(%d, ", keys->val.intValue);
        else if(keys->val.type == FLOAT_VALUE)
            printf("(%lf, ", keys->val.floatValue);
        else if(keys->val.type == STRING_VALUE)
            printf("(\"%s\", ", keys->val.stringValue);


        if(values->val.type == INTEGER_VALUE)
            printf("%d", values->val.intValue);
        else if(values->val.type == FLOAT_VALUE)
            printf("%lf", values->val.floatValue);
        else if(values->val.type == STRING_VALUE)
            printf("\"%s\"", values->val.stringValue);
        else
            print_dictionary(values->val.dictionary);

        printf(")");
        keys = keys->next;
        values = values->next;

        if(keys)
            printf(", ");
    }

    printf("]\n");

    return 0;
}


void push_dictionary(){
    Dictionary * current_dictionary = (Dictionary*)malloc(sizeof(Dictionary));
    current_dictionary->keys = NULL; current_dictionary->values = NULL;

    // push
    node_t * new_node = (node_t*)malloc(sizeof(node_t));
    new_node->val.dictionary = current_dictionary;
    new_node->next = dictionaries;
    dictionaries = new_node;
}


Dictionary * pop_dictionary() {
    Dictionary * temp = dictionaries->val.dictionary;
    dictionaries = dictionaries->next;
    return temp;
}



void store_element_dictionary(op_struct a, Dictionary * inner_dictionary) {

    Dictionary * current_dictionary = dictionaries->val.dictionary;

    node_t * new_key = (node_t*)malloc(sizeof(node_t));
    new_key->next = NULL;

    new_key->val.type = a.type;
    new_key->val.intValue = a.intValue;
    new_key->val.floatValue = a.floatValue;
    new_key->val.stringValue = a.stringValue;
    new_key->val.dictionary = NULL;

    // push front
    new_key->next = current_dictionary->keys;
    current_dictionary->keys = new_key;



    node_t * new_value = (node_t*)malloc(sizeof(node_t));
    new_value->next = NULL;

    new_value->val.type = DICTIONARY;
    new_value->val.dictionary = inner_dictionary;

    // push front
    new_value->next = current_dictionary->values;
    current_dictionary->values = new_value;

}


void store_element_element(op_struct a, op_struct b) {

    Dictionary * current_dictionary = dictionaries->val.dictionary;

    node_t * new_key = (node_t*)malloc(sizeof(node_t));
    new_key->next = NULL;

    new_key->val.type = a.type;
    new_key->val.intValue = a.intValue;
    new_key->val.floatValue = a.floatValue;
    new_key->val.stringValue = a.stringValue;
    new_key->val.dictionary = NULL;

    // push front
    new_key->next = current_dictionary->keys;
    current_dictionary->keys = new_key;



    node_t * new_value = (node_t*)malloc(sizeof(node_t));
    new_value->next = NULL;

    new_value->val.type = b.type;
    new_value->val.intValue = b.intValue;
    new_value->val.floatValue = b.floatValue;
    new_value->val.stringValue = b.stringValue;
    new_value->val.dictionary = NULL;

    // push front
    new_value->next = current_dictionary->values;
    current_dictionary->values = new_value;

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
