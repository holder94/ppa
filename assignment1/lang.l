%option noyywrap
%option yylineno

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lang.hh"
%}


digit [0-9]
alpha [a-zA-Z]

%%

-{digit}+ {
  yylval.integer = atoi(yytext);
  return INTEGER;
}

{digit}+ {
  yylval.integer = atoi(yytext);
  return NUMBER;
}

sum|random_choice { return FUNC; }

{alpha}+ {
  yylval.str = strdup(yytext);
  return WORD;
}

, { return COMMA; }
\( { return LPAREN; }
\) { return RPAREN; }
:= { return ASSIGNMENT_OP; }
;\n { return EOL; }

" " ;

. {
  printf("Unrecognized token: %s\n", yytext);
  exit(EXIT_FAILURE);
}

%%

