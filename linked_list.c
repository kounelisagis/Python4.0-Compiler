#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define INTEGER_VALUE 0
#define FLOAT_VALUE 1
#define STRING_VALUE 2


typedef struct Variable{
    char* name;
    int type;

    int intValue;
    double floatValue;
    char* stringValue;
} Variable;


typedef struct node {
    Variable val;
    struct node * next;
} node_t;



void print_list(node_t * head) {
    node_t * current = head;


    
    while (current != NULL) {
        printf("%s: ", current->val.name);
        if(current->val.type == INTEGER_VALUE)
            printf("%d\n", current->val.intValue);
        else if(current->val.type == FLOAT_VALUE)
            printf("%lf\n", current->val.floatValue);
        else
            printf("%s\n", current->val.stringValue);
        current = current->next;
    }

}


node_t * push_front(node_t * head, char * name, int type, int intValue, double floatValue, char * stringValue) {

    node_t * new_node = (node_t *) malloc(sizeof(node_t));

    new_node->val.name = name;
    new_node->val.type = type;
    new_node->val.intValue = intValue;
    new_node->val.floatValue = floatValue;
    new_node->val.stringValue = stringValue;

    new_node->next = head;

    return new_node;
}


Variable* find_variable(node_t * head, char * name) {

    while(head != NULL) {
        if (strcmp(head->val.name, name) == 0)
            return &(head->val);
        head = head->next;
    }

    return NULL;
}


node_t * assign_variable(node_t * head, char * name, int type, int intValue, double floatValue, char * stringValue) {
    
    Variable* variable_found = find_variable(head, name);
    
    if(!variable_found)
        return push_front(head, name, type, intValue, floatValue, stringValue);
    else {
        variable_found->type = type;
        variable_found->intValue = intValue;
        variable_found->floatValue = floatValue;
        variable_found->stringValue = stringValue;

        return head;
    }

}

