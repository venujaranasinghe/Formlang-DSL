CC = gcc
CFLAGS = -Wall

all: formlang

formlang: y.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o formlang y.tab.c lex.yy.c -ly -ll

y.tab.c: parser.y
	yacc -d parser.y

lex.yy.c: lexer.l
	lex lexer.l

clean:
	rm -f formlang y.tab.c y.tab.h lex.yy.c output.html

test: formlang
	./formlang example.form output.html
	cat output.html