%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"

/* Add this line to declare yyerror */
extern void yyerror(const char *s);
%}

%option noyywrap
/* Enable automatic line counting */
%option yylineno

%%

"form"      { return FORM; }
"meta"      { return META; }
"section"   { return SECTION; }
"field"     { return FIELD; }
"validate"  { return VALIDATE; }
"if"        { return IF; }
"error"     { return ERROR; }
"required"  { return REQUIRED; }
"default"   { return DEFAULT; }
"min"       { return MIN; }
"max"       { return MAX; }
"pattern"   { return PATTERN; }
"rows"      { return ROWS; }
"cols"      { return COLS; }
"accept"    { return ACCEPT; }

"text"|"email"|"number"|"date"|"password"|"checkbox"|"radio"|"dropdown"|"textarea"|"file" { 
    yylval.strval = strdup(yytext); 
    return TYPE; 
}

"true"      { yylval.boolval = 1; return BOOLEAN; }
"false"     { yylval.boolval = 0; return BOOLEAN; }

[0-9]+      { yylval.intval = atoi(yytext); return NUMBER; }

[a-zA-Z][a-zA-Z0-9_]* { 
    yylval.strval = strdup(yytext); 
    return IDENTIFIER; 
}

\"[^\"]*\" { 
    yytext[strlen(yytext)-1] = '\0';
    yylval.strval = strdup(yytext+1);
    return STRING_LITERAL;
}

[ \t\r]+ { /* Skip whitespace */ }
\n       { /* Newlines are counted automatically by yylineno */ }

[{}[\]();:=,<>] { return yytext[0]; }

"//".*    { /* Skip single-line comments */ }
"/*"      { 
    char c, prev = 0;
    while ((c = input()) != 0) {
        if (c == '/' && prev == '*')
            break;
        prev = c;
    }
}

. { 
    /* Report unrecognized characters with line number */
    char msg[100];
    sprintf(msg, "Unrecognized character: %s", yytext);
    yyerror(msg);
}

%%