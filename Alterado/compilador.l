%{


#include<stdio.h>
#include<string.h>

#include "compilador.h"
#include "compilador.tab.h"

//#define IMPRIME(STR) {};
#define IMPRIME(STR) printf("%s    # %s \n", STR, token);

int nl = 1;  

%}

pulo_linha [\n]

descarte [\t ]+

ident [a-zA-Z][a-zA-Z1-9]*

numero [0-9]+

comentario "(*".*"*)"

%%

{pulo_linha} {nl++;} 

{descarte}

{comentario}

program { simbolo  = simb_program;  
    	strncpy (token, yytext, TAM_TOKEN);
        return PROGRAM;
}

var { simbolo = simb_var;  
    	strncpy (token, yytext, TAM_TOKEN);
        return VAR;
}

begin { simbolo = simb_begin;
        strncpy (token, yytext, TAM_TOKEN);
        return T_BEGIN;
}

end { simbolo = simb_end;
        strncpy (token, yytext, TAM_TOKEN);
        return T_END;
}

:= { simbolo = simb_atribuicao;  
        strncpy (token, yytext, TAM_TOKEN);
        return ATRIBUICAO;  
}

\; { simbolo = simb_ponto_e_virgula;  
        strncpy (token, yytext, TAM_TOKEN);
        return PONTO_E_VIRGULA;
 }

\: { simbolo = simb_dois_pontos;  
        strncpy (token, yytext, TAM_TOKEN);
        return DOIS_PONTOS;
}

\, { simbolo = simb_virgula;  
        strncpy (token, yytext, TAM_TOKEN);
        return VIRGULA;
}


\. { simbolo = simb_ponto;  
        strncpy (token, yytext, TAM_TOKEN);
        return PONTO; 
}

\( { simbolo = simb_abre_parenteses;  
        strncpy (token, yytext, TAM_TOKEN);
        return ABRE_PARENTESES;
}

\) { simbolo = simb_fecha_parenteses;  
        strncpy (token, yytext, TAM_TOKEN);
        return FECHA_PARENTESES;
}

label { simbolo = simb_label;
        strncpy (token, yytext, TAM_TOKEN);
        return LABEL;
}

procedure { simbolo = simb_procedimento;
            strncpy (token, yytext, TAM_TOKEN);
            return PROCEDURE;
}

function { simbolo = simb_funcao;
            strncpy (token, yytext, TAM_TOKEN);
            return FUNCTION;
}

goto { simbolo = simb_goto;
        strncpy (token, yytext, TAM_TOKEN);
        return GOTO;
}

if { simbolo = simb_se;
       strncpy (token, yytext, TAM_TOKEN);
       return IF;
}

then { simbolo = simb_entao;
        strncpy (token, yytext, TAM_TOKEN);
        return THEN;
}

else { simbolo = simb_senao;
        strncpy (token, yytext, TAM_TOKEN);
        return ELSE;
}

while { simbolo = simb_enquanto;
        strncpy (token, yytext, TAM_TOKEN);
        return WHILE;
}

do { simbolo = simb_faca;
       strncpy (token, yytext, TAM_TOKEN);
       return DO;
}

repeat { simbolo = simb_repete;
        strncpy (token, yytext, TAM_TOKEN);
        return REPEAT;
}

until { simbolo = simb_ate;
       strncpy (token, yytext, TAM_TOKEN);
       return UNTIL;
}

\= { simbolo = simb_igual;
        strncpy (token, yytext, TAM_TOKEN);
        return EQUAL;
}

\<> { simbolo = simb_diferente;
        strncpy (token, yytext, TAM_TOKEN);
        return DIFFERENT;
}

\< { simbolo = simb_menor;
        strncpy (token, yytext, TAM_TOKEN);
        return MINOR;
}

\<= { simbolo = simb_menor_igual;
        strncpy (token, yytext, TAM_TOKEN);
        return MINOR_EQUAL;
}

\>= { simbolo = simb_maior_igual;
        strncpy (token, yytext, TAM_TOKEN);
        return GREATER_EQUAL;
}

\> { simbolo = simb_maior;
        strncpy (token, yytext, TAM_TOKEN);
        return GREATER;
}

\+ { simbolo = simb_soma;
        strncpy (token, yytext, TAM_TOKEN);
        return SUM;
}

\- { simbolo = simb_subtracao;
        strncpy (token, yytext, TAM_TOKEN);
        return SUBTRACTION;
}

\* { simbolo = simb_multiplicacao;
        strncpy (token, yytext, TAM_TOKEN);
        return MULTIPLICATION;
}

\/ { simbolo = simb_divisao_real;
        strncpy (token, yytext, TAM_TOKEN);
        return DIVISION_REAL;
}

div { simbolo = simb_divisao_inteira;
        strncpy (token, yytext, TAM_TOKEN);
        return DIVISION_REAL;
}

or { simbolo = simb_ou;
        strncpy (token, yytext, TAM_TOKEN);
        return OR;
}

and { simbolo = simb_and;
        strncpy (token, yytext, TAM_TOKEN);
        return AND;
}

not { simbolo = simb_negacao;
        strncpy (token, yytext, TAM_TOKEN);
        return NOT;
}

\[ { simbolo = simb_abre_colchetes;
        strncpy(token, yytext, TAM_TOKEN);
        return ABRE_COLCHETES;
}

\] { simbolo = simb_fecha_colchetes;
        strncpy(token, yytext, TAM_TOKEN);
        return FECHA_COLCHETES;
}

integer { simbolo = simb_integer;
           strncpy (token, yytext, TAM_TOKEN);
           return INTEGER;
}

boolean { simbolo = simb_boolean; 
              strncpy(token, yytext, TAM_TOKEN);
              return BOOLEAN;
}

read { simbolo = simb_read;
              strncpy (token, yytext, TAM_TOKEN);
              return READ;
}

write { simbolo = simb_write;
              strncpy (token, yytext, TAM_TOKEN);
              return WRITE;
}

{numero} { simbolo = simb_number;
           strncpy (token, yytext, TAM_TOKEN);
           return NUMBER;
}

{ident} { simbolo = simb_identificador; 
    	strncpy (token, yytext, TAM_TOKEN);
        return IDENT;
}


%%
