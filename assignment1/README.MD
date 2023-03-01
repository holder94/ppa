## How to run
- #### yacc -d lang.y -o lang.cc
- #### flex lang.l
- #### g++ -c lex.yy.c -o lex.yy.o
- #### g++ lex.yy.o lang.cc analyzer.cpp -o program
- #### echo "1 x:= 10" | ./program
