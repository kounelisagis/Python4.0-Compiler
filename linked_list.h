#ifndef HEADER_FILE
#define HEADER_FILE


#define INTEGER_VALUE 0
#define FLOAT_VALUE 1
#define STRING_VALUE 2
#define DICTIONARY 3
#define NONE_VALUE 4


typedef struct Variable Variable;
typedef struct node node_t;
typedef struct Dictionary Dictionary;

struct Dictionary{
    node_t * keys;
    node_t * values;
};


struct Variable{
    char* name;
    int type;

    int intValue;
    double floatValue;
    char* stringValue;

    Dictionary * dictionary;
};

struct node {
    Variable val;
    struct node * next;
};


void print_variable(Variable *);

void print_inner_dictionary(node_t *, node_t *, node_t *);

void print_dictionary(Dictionary *);

void print_list(node_t *);

node_t * push_front(node_t *, char *, int, int, double, char *, Dictionary *);

Variable* find_variable(node_t *, char *);

node_t * assign_variable(node_t *, char *, int, int, double, char *, Dictionary *);


#endif