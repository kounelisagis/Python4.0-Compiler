%{
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "linked_list.h"


int lambda_flag = 0;
int level = 0;

node_t * dictionaries = NULL;
node_t * variables = NULL;
node_t * function_stack = NULL;


int dict_set_default(char *);
void print_function_call();
void push_dictionary();
Dictionary * pop_dictionary();
int dict_items(char*);
void yyerror(char *);
int yylex();


extern FILE *yyin;
extern FILE *yyout;
extern int yylineno;

%}

%code requires {

    Variable add(Variable, Variable);
    Variable sub(Variable, Variable);
    Variable mul(Variable, Variable);
    Variable divide(Variable, Variable);
    void store_element_element(Variable, Variable);
    void store_element_dictionary(Variable, Dictionary*);
}

%union {
    int intValue;
    double floatValue;
    char *stringValue;
    Variable myStruct;
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
%token <intValue> INDENT
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


%left '=' '(' ')' ':' '.' '[' ']' '{' '}' ','
%left '+' '-'
%left '*' '/'

%start start

%type<stringValue> import_stmt;
%type<stringValue> call_arguments;
%type<stringValue> package;
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
    program { printf("\n\n======VARIABLES=======\n\n"); print_list(variables); }
    ;

program:
        /* empty */ 
        | main NEWLINE program 
        | main
        ;


main:
        /* ignore newlines */
        | if_cmd                        { printf("%s\n", $1); }
        | for_cmd                       { printf("FOR LOOP\n"); function_stack = NULL; }
        | classdef                      { printf("Class defined with name %s\n", $1); }
        | import_stmt                   { printf("Imported %s\n", $1); }
        | assignment
        | expr
        | function_def                  { printf("Function defined with name: %s\n", $1); }
        | function_call                 { printf("A function call here!\n"); if(level==0) {print_function_call();} function_stack = NULL; }
        | class_function_call           { printf("A function call from object!\n"); if(level==0) {print_function_call();} function_stack = NULL; }
        | lambda                        { printf("Lambda function defined\n"); }
        | INLINE_COMMENT                { printf("A comment here! %s\n", $1); }
        | MULTILINE_COMMENT             { printf("A comment here! %s\n", $1); }
        | PRINT '(' STRING ')'          { if(level==0) {printf("Print: %s\n", $3);} }
        | PRINT '(' expr ')'            { if(level==0) {print_variable(&$<myStruct>3); printf("\n");} }
        | PRINT '(' IDENTIFIER ')'      { if(level==0) {Variable* v = find_variable(variables, $3);
                                          if(v) { print_variable(v); printf("\n"); }
                                          else printf("Variable not found!\n");} }
        ;



import_stmt:
        IMPORT package { $$ = $2; }
        | IMPORT package AS IDENTIFIER { if(level==0) {char str[512]; sprintf(str, "%s as %s", $2, $4); $$ = str;} }
        ;

package:
        IDENTIFIER { $$ = $1; }
        | package '.' package { if(level==0) {char str[512]; sprintf(str, "%s.%s", $1, $3); $$ = str;} }
        ;


assignment:
        IDENTIFIER '=' STRING          { if(level==0) {printf("Variable: %s | value: %s\n", $1, $3);
                                        variables = assign_variable(variables, $1, STRING_VALUE, -1, -1, $3, NULL);}
                                       }
        | IDENTIFIER '=' expr          { if(level==0) { printf("Variable: %s | value: ", $1); print_variable(&$<myStruct>3); printf("\n");
                                         variables = assign_variable(variables,  $1, $3.type, $3.intValue, $3.floatValue, NULL, NULL);}
                                       }
        | IDENTIFIER '=' function_call { if(level==0) {printf("Variable: %s | function: ", $1); print_function_call(); function_stack = NULL;} }
        | IDENTIFIER '=' dictionary    { if(level==0) {variables = assign_variable(variables, $1, DICTIONARY, -1, -1, NULL, $3);
                                         printf("Dictionary %s\n", $1);}
                                       }
        | IDENTIFIER '=' lambda        { if(level==0) { printf("Lambda function defined\n"); } }
        ;



expr:
        IDENTIFIER                     { if(level==0) {if(!lambda_flag){
                                        Variable* v = find_variable(variables, $1);
                                        if(v && v->type == FLOAT_VALUE || v->type == INTEGER_VALUE){
                                            $<myStruct>$.type = v->type;
                                            $<myStruct>$.floatValue = v->floatValue;
                                            $<myStruct>$.intValue = v->intValue; }
                                        else {
                                            printf("Variable %s does not exist - line %d\n", $1, yylineno);
                                            YYABORT;
                                            } } } }
        | FLOAT                        { if(level==0) {$<myStruct>$.floatValue = $1; $<myStruct>$.type = FLOAT_VALUE;} }
        | INT                          { if(level==0) {$<myStruct>$.intValue = $1; $<myStruct>$.type = INTEGER_VALUE;} }
        | expr '+' expr                { if(level==0) {$$ = add($<myStruct>1, $<myStruct>3);} }
        | '+' expr                     { if(level==0) {$$ = $<myStruct>2;} }
        | expr '-' expr                { if(level==0) {$$ = sub($<myStruct>1, $<myStruct>3);} }
        | '-' expr                     { if(level==0) {$<myStruct>2.floatValue = -$<myStruct>2.floatValue; $<myStruct>2.intValue = -$<myStruct>2.intValue;
                                         $$ = $<myStruct>2;} }
        | expr '*' expr                { if(level==0) {$$ = mul($<myStruct>1, $<myStruct>3);} }
        | expr '/' expr                { if(level==0) {$$ = divide($<myStruct>1, $<myStruct>3);} }
        ;


suite:
        INDENT main suite_
        ;


suite_:
        /* empty if last file row */ 
        | NEWLINE
        | NEWLINE suite
        ;


classdef:
        CLASS IDENTIFIER ':' NEWLINE { level++; } suite { level--; $$ = $2; }
        ;


if_cmd:
        IF expression ':' NEWLINE { level++; } suite else_cmd { level--; $$ = "If Statement"; }
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
        DEF IDENTIFIER '(' def_arguments ')' ':' NEWLINE { level++; } suite { level--; $$ = $2; }
        | DEF IDENTIFIER '(' ')' ':' NEWLINE { level++; } suite { level--; $$ = $2; }
        ;


def_arguments:
        IDENTIFIER
        | assignment
        | def_arguments ',' def_arguments
        ;


function_call:
        IDENTIFIER '(' call_arguments ')' { function_stack = push_front(function_stack, NULL, STRING_VALUE, -1, -1, $1, NULL); }
        | IDENTIFIER '(' ')' { function_stack = push_front(function_stack, NULL, STRING_VALUE, -1, -1, $1, NULL); }
        ;


call_arguments:
        expr { function_stack = push_front(function_stack, NULL, $1.type, $1.intValue, $1.floatValue, NULL, NULL); } 
        | STRING { function_stack = push_front(function_stack, NULL, STRING_VALUE, -1, -1, $1, NULL); }
        | expr ',' call_arguments { function_stack = push_front(function_stack, NULL, $1.type, $1.intValue, $1.floatValue, NULL, NULL); }
        | STRING ',' call_arguments { function_stack = push_front(function_stack, NULL, STRING_VALUE, -1, -1, $1, NULL); }
        ;


for_cmd:
        FOR IDENTIFIER IN list ':' NEWLINE { level++; } suite { level--; }
        ;


list:
        '[' call_arguments ']'
        ;


lambda:
        LAMBDA def_arguments ':' { lambda_flag = 1; } expr { lambda_flag = 0; }
        | LAMBDA ':' { lambda_flag = 1; } expr { lambda_flag = 0; }
        ;


dictionary:
        '{' { if(level==0) {push_dictionary();} } dict '}' { if(level==0) {$$ = pop_dictionary();} }
        | '{' '}' { if(level==0) {$$ = (Dictionary*)malloc(sizeof(Dictionary)); $$->keys = NULL; $$->values = NULL;} }
        ;


dict:
        dict_element ':' dict_element { if(level==0) { store_element_element($<myStruct>1, $<myStruct>3);} }
        | dict_element ':' dictionary { if(level==0) { store_element_dictionary($<myStruct>1, $3);} }
        | dict ',' dict
        ;


dict_element:
        STRING { $<myStruct>$.stringValue = $1; $<myStruct>$.type = STRING_VALUE; }
        | expr { $$ = $1; }
        ;


class_function_call:
        IDENTIFIER '.' function_call {  if(level==0) {char * function_name = function_stack->val.stringValue;/*
                                        function_stack = function_stack->next;
                                        char str[512]; sprintf(str, "%s.%s()", $1, function_name); $$ = str; printf("======>>> %s\n\n", str);*/

                                        if(strcmp(function_name, "items") == 0) {
                                            int res = dict_items($1);
                                            if (res == -1) {
                                                YYABORT;
                                            }
                                        }
                                        if(strcmp(function_name, "setdefault") == 0) {
                                            int res = dict_set_default($1);
                                            if (res == -1) {
                                                YYABORT;
                                            }

                                        }
                                     } }
        ;

%%

void print_function_call() {

    node_t * temp_stack = function_stack;

    printf("%s(", temp_stack->val.stringValue);

    temp_stack = temp_stack->next;

    while (temp_stack) {
        print_variable(&temp_stack->val);
        
        temp_stack = temp_stack->next;
        if (temp_stack)
            printf(", ");
    }

    printf(")\n");
}


int dict_set_default(char * variable_name) {

    node_t * temp_stack = function_stack->next; // 1st is the name

    if (temp_stack == NULL) {
        printf("setdefault expected at least 1 arguments\n");
        return -1;
    }


    Variable * key = &temp_stack->val;
    // print_variable(key);

    temp_stack = temp_stack->next;

    Variable * value = NULL;
    if(temp_stack) {
        value = &temp_stack->val;

        if(temp_stack->next != NULL) {
            printf("setdefault expected at most 2 arguments, got more\n");
            return -1;
        }
    }

        // has 1 or 2 arguments

    Variable* found_variable = find_variable(variables, variable_name);
    if(!found_variable) {
        printf("name %s is not defined\n", variable_name);
        return -1;
    }

    if(found_variable->type != DICTIONARY){
        if(found_variable->type == INTEGER_VALUE)
            printf("'int' object has no attribute 'setdefault'\n");
        else if(found_variable->type == FLOAT_VALUE)
            printf("'float' object has no attribute 'setdefault'\n");
        else if(found_variable->type == STRING_VALUE)
            printf("'str' object has no attribute 'setdefault'\n");
        return -1;
    }

    Dictionary * dictionary = found_variable->dictionary;
    
    node_t * key_list = dictionary->keys;
    node_t * value_list = dictionary->values;
    
    Variable * current_key = NULL;
    Variable * current_value = NULL;

    while(key_list) {
        current_key = &key_list->val;
        current_value = &value_list->val;

        if(current_key->type == INTEGER_VALUE && current_key->type == key->type)
            if(current_key->intValue == key->intValue) {
                //printf("->> %d\n", current_value->intValue);
                break;
            }
        else if(current_key->type == FLOAT_VALUE && current_key->type == key->type)
            if(current_key->floatValue == key->floatValue) {
                //printf("%lf", current_value->floatValue);
                break;
            }
        else if(current_key->type == STRING_VALUE && current_key->type == key->type)
            if(strcmp(current_key->stringValue, key->stringValue) == 0) {
                //printf("\"%s\"", current_key->stringValue);
                break;
            }

        key_list = key_list->next;
        value_list = value_list->next;
    }


    if(key_list) { // key found
        print_variable(current_value);
        printf("\n");
    } else { // key not found
        dictionary->keys = push_front(dictionary->keys, key->name, key->type, key->intValue, key->floatValue, key->stringValue, NULL);
        if(value) { // 2 arguments
            dictionary->values = push_front(dictionary->values, value->name, value->type, value->intValue, value->floatValue, value->stringValue, value->dictionary);
        } else {
            dictionary->values = push_front(dictionary->values, NULL, NONE_VALUE, -1, -1, NULL, NULL);
        }
    }

}


int dict_items(char * variable_name) {

    node_t * temp_stack = function_stack->next; // 1st is the name

    if(temp_stack != NULL){
        printf("items cannot have arguments\n");
        return -1;
    }

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

        printf("(");
        print_variable(&keys->val);
        printf(", ");

        print_variable(&values->val);

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



void store_element_dictionary(Variable a, Dictionary * inner_dictionary) {

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


void store_element_element(Variable a, Variable b) {

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


Variable add(Variable a, Variable b) {
    
    Variable result;

    if(a.type == INTEGER_VALUE && b.type == INTEGER_VALUE){
        result.intValue = a.intValue + b.intValue;
        result.type = INTEGER_VALUE;
    }
    else{
        result.floatValue;
        result.type = FLOAT_VALUE;

        if(a.type == INTEGER_VALUE)
            result.floatValue = a.intValue;
        else
            result.floatValue = a.floatValue;

        if(b.type == INTEGER_VALUE)
            result.floatValue += b.intValue;
        else
            result.floatValue += b.floatValue;
    }

    return result;
}

Variable sub(Variable a, Variable b) {
    
    Variable result;

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

Variable mul(Variable a, Variable b) {
    
    Variable result;

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

Variable divide(Variable a, Variable b) {
    
    Variable result;

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


int main ( int argc, char **argv ) {
    ++argv; --argc;
    if ( argc > 0 )
        yyin = fopen( argv[0], "r" );
    else
        yyin = stdin;
    yyout = fopen ( "output", "w" );
    yyparse();
    return 0;
}
