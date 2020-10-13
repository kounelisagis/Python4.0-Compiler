# Python4.0 Compiler
This is an attempt to implement a truncated version of a Python3 Compiler. It's a Lexical, Syntax and Sematic Analyzer mix.

### Team
Apostolos Kontarinis<br>
Agisilaos Kounelis<br>
John Prokopiou<br>
John Sina

### Supported Features
#### Semantic analysis:
- **Variables**: initialization (int, float, string), overriding variables with the same name, execution of arithmetic operations (* / - +), support order of operations.
- **Dictionaries**: initialization(keys: primitive types, values: everything), implementation of items() and setdefault(keyname, value=None) functions.
- **print()**: implementation of the function. Fully compatible with variables and dictionaries.

#### Syntax & Lexical analysis:
- **Comments**
- **Modules Import**
- **Classes**: definition, constructor definition, object creation.
- **Functions**: definiction, call.
- **Conditional Statements**: if, elif, else.
- **For Loops**
- **Lambda Functions**


### Compile & Run - Classic Way :neutral_face:
```sh
$ flex calc.l
$ bison -y -d calc.y
$ gcc -c y.tab.c lex.yy.c
$ gcc linked_list.c -c
$ gcc linked_list.c y.tab.c lex.yy.c -o calc -lm
$ ./calc input.py
```

### Compile & Run - Alias Way :wink:
```sh
$ alias python4='clear && flex calc.l && bison -y -d calc.y && gcc -c y.tab.c lex.yy.c && gcc linked_list.c -c && gcc y.tab.c lex.yy.c linked_list.c -o calc -lm && ./calc'
$ python4 input.py
```
