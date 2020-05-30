flex calc.l
bison -y -d calc.y
gcc -c y.tab.c lex.yy.c
gcc y.tab.c lex.yy.c -o calc -lm
./calc input.py

ALL IN ONE
flex calc.l && bison -y -d calc.y && gcc -c y.tab.c lex.yy.c && gcc y.tab.c lex.yy.c -o calc -lm && ./calc input.py

ALIAS
alias arxes='flex calc.l && bison -y -d calc.y && gcc -c y.tab.c lex.yy.c && gcc y.tab.c lex.yy.c -o calc -lm && ./calc input.py'
