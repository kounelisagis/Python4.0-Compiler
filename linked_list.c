#include "linked_list.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>



void print_inner_dictionary(node_t * keys, node_t * values, node_t * start_pointer) {

    if(keys == NULL)
        return;
    
    print_inner_dictionary(keys->next, values->next, start_pointer);

    // print
    
    // if(keys->val.type == INTEGER_VALUE)
    //     printf("%d: ", keys->val.intValue);
    // else if(keys->val.type == FLOAT_VALUE)
    //     printf("%lf: ", keys->val.floatValue);
    // else if(keys->val.type == STRING_VALUE)
    //     printf("\"%s\": ", keys->val.stringValue);


    // if(values->val.type == INTEGER_VALUE)
    //     printf("%d", values->val.intValue);
    // else if(values->val.type == FLOAT_VALUE)
    //     printf("%lf", values->val.floatValue);
    // else if(values->val.type == STRING_VALUE)
    //     printf("\"%s\"", values->val.stringValue);
    // else
    //     print_dictionary(values->val.dictionary);

    print_variable(&keys->val);
    printf(": ");
    print_variable(&values->val);


    if(keys != start_pointer)
        printf(", ");

}



void print_dictionary(Dictionary * dict_var) {

    node_t * keys = dict_var->keys;
    node_t * values = dict_var->values;

    printf("{");
    
    print_inner_dictionary(keys, values, keys);
    
    printf("}");

}


void print_variable(Variable * var) {
    if(var->type == INTEGER_VALUE)
        printf("%d", var->intValue);
    else if(var->type == FLOAT_VALUE)
        printf("%lf", var->floatValue);
    else if(var->type == STRING_VALUE)
        printf("\"%s\"", var->stringValue);
    else if(var->type == NONE_VALUE)
        printf("None");
    else
        print_dictionary(var->dictionary);
}


void print_list(node_t * head) {
    node_t * current = head;

    while (current != NULL) {
        printf("%s: ", current->val.name);
        print_variable(&current->val);
        current = current->next;
        printf("\n");
    }

}


node_t * push_front(node_t * head, char * name, int type, int intValue, double floatValue, char * stringValue, Dictionary * dictionary) {

    node_t * new_node = (node_t *) malloc(sizeof(node_t));

    new_node->val.name = name;
    new_node->val.type = type;
    new_node->val.intValue = intValue;
    new_node->val.floatValue = floatValue;
    new_node->val.stringValue = stringValue;
    new_node->val.dictionary = dictionary;

    if (head == NULL) {
        new_node->next = NULL;
        return new_node;
    }

    new_node->next = head;

    return new_node;
}


Variable * find_variable(node_t * head, char * name) {

    while(head != NULL) {
        if (strcmp(head->val.name, name) == 0)
            return &(head->val);
        head = head->next;
    }

    return NULL;
}


node_t * assign_variable(node_t * head, char * name, int type, int intValue, double floatValue, char * stringValue, Dictionary * dictionary) {
    
    Variable* variable_found = find_variable(head, name);
    
    if(!variable_found)
        return push_front(head, name, type, intValue, floatValue, stringValue, dictionary);
    else {
        variable_found->type = type;
        variable_found->intValue = intValue;
        variable_found->floatValue = floatValue;
        variable_found->stringValue = stringValue;
        variable_found->dictionary = dictionary;

        return head;
    }

}
