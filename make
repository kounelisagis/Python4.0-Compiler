flex calc.l
bison -y -d calc.y
gcc -c y.tab.c lex.yy.c
gcc linked_list.c -c
gcc linked_list.c y.tab.c lex.yy.c  -o calc -lm
./calc input.py

ALL IN ONE
flex calc.l && bison -y -d calc.y && gcc -c y.tab.c lex.yy.c && gcc linked_list.c -c && gcc y.tab.c lex.yy.c linked_list.c -o calc -lm && ./calc input.py

ALIAS
alias arxes='clear && flex calc.l && bison -y -d calc.y && gcc -c y.tab.c lex.yy.c && gcc linked_list.c -c && gcc y.tab.c lex.yy.c linked_list.c -o calc -lm && ./calc input.py'
