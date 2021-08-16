/*
X quando ler function ou procedure marca como verdadeira
X quando sair do bloco marca como falsa
quando chegar na main ela vai ser falsa (no início do bloco)
*/
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#include "compilador.h"
#include "symbolsTable.h"
#include "typesStack.h"
#include "labelsStack.h"

int yylex();
int yyerror();
int num_vars, labelId;
int geraCodigo();

symbolsStack symbolsTable;
typesStack typesTable;
labelsStack labelsTable;
stackNode *newInput, *destinyVariable, *loadedVariable, *paramNode, *currentProcedure, *currentParameter;
int countVars, newVars, oldVars, lexicalLevel, displacement, declaredProcedures;
int receivingFormalParams, receivingByReference, oldParams, newParams, parameterCount;
unsigned int clauseHasElse, clauseHasElseIterator;
int isSubRoutine, insideProcedure, pureExpression;
char totalVars[16], command[20], callProcedure[20], varLexDisp[12], relacaoUsada[5];
char *labelWhileStart, *labelWhileEnd, *labelIfStart, *labelIfEnd, *labelSubroutineStart, *labelSubroutineEnd;
char functionIdentifier[30];
pascalType returnType;
paramDesc* paramList;

void passByReference(char *ident, int parameterIndex) {
	/* gera o comando de passagem do parametro identificado por ident para a função procedureIdent na parameterIndex-ésima posição */
	stackNode* varNode = search(&symbolsTable, ident);
	passType expectedPass = currentProcedure->params[parameterIndex].pass;
	passType actualPass = varNode->pass;
	categoryType varCategory = varNode->category;
	char loadCommand[20];
	int l, d; //lexicalLevel, displacemente de varNode
	l = varNode->lexicalLevel;
	d = varNode->displacement;
	if (!pureExpression) {
		sprintf(loadCommand, "CRVL %d, %d", l, d);
	}
	else if (varCategory == simpleVar) {
		if (expectedPass == value) //CRVL
			sprintf(loadCommand, "CRVL %d, %d", l, d);
		else //CREN
			sprintf(loadCommand, "CREN %d, %d", l, d);
	} else {
		if (expectedPass == actualPass) //CRVL
			sprintf(loadCommand, "CRVL %d, %d", l, d);
		else {
			if (expectedPass == value) //CRVI
				sprintf(loadCommand, "CRVI %d, %d", l, d);
			else //CREN
				sprintf(loadCommand, "CREN %d, %d", l, d);
		}
	}
	geraCodigo(NULL, loadCommand);
} 

void setHasElse() {
	clauseHasElse |= (1 << clauseHasElseIterator);
}

int getHasElse() { //445
	int r = clauseHasElse & (1 << clauseHasElseIterator);
	clauseHasElse &= ~(1 << clauseHasElseIterator); 
	clauseHasElseIterator--;
	if (!clauseHasElseIterator)
		clauseHasElse = 0;
	return r;
}

void initHasElse() {
	if (!(clauseHasElse & (unsigned int)1)) {
		clauseHasElse = 1; //0-esimo indice (1 << 0) indica que estamos em ifs aninhados (?)
		clauseHasElseIterator = 0;
	}
	clauseHasElseIterator++; //primeiro indice a ser usado
}

char *getParameterName() {
	paramList = destinyVariable->params;
	char *ans = paramList[newParams].identifier;
	return ans;
}

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES 
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
%token LABEL PROCEDURE FUNCTION GOTO
%token IF THEN ELSE WHILE DO REPEAT UNTIL EQUAL DIFFERENT MINOR MINOR_EQUAL GREATER_EQUAL GREATER
%token SUM SUBTRACTION MULTIPLICATION DIVISION_REAL DIVISION_INTEGER OR AND
%token NOT ABRE_COLCHETES FECHA_COLCHETES INTEGER BOOLEAN READ WRITE NUMBER

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%nonassoc NADA
%nonassoc ABRE_PARENTESES
%%

// Regra 1
programa:
	{ 
		geraCodigo(NULL, "INPP"); 
	}
	PROGRAM IDENT 
	parametros_vazio PONTO_E_VIRGULA
	bloco PONTO
	{  
		// DMEM nas variaveis do programa
		pop(&symbolsTable, countVars + declaredProcedures);
		strcpy(command,"DMEM ");
		sprintf(totalVars, "%d", countVars);
		strcat(command, totalVars);
		geraCodigo(NULL, command); 

		geraCodigo(NULL, "PARA"); 
	}
;

parametros_vazio:
	parametros
	| comando_vazio
;

parametros:
	ABRE_PARENTESES lista_idents FECHA_PARENTESES
;

// Regra 2
bloco:
	parte_declara_vars
	parte_declara_sub_rotinas
	{
		if(declaredProcedures > 0 && lexicalLevel == 0) {
			strcpy(command, labelSubroutineEnd);
			strcat(command, ": NADA");
			geraCodigo(NULL, command); 
		}
	}
	comando_composto 
;

// Regra 6
tipo:
	INTEGER { setTypes(&symbolsTable, integer, newVars); }
	| BOOLEAN { setTypes(&symbolsTable, boolean, newVars); }
;

// Regra 8
parte_declara_vars:
	var
	{
		strcpy(command,"AMEM ");
		sprintf(totalVars, "%d", countVars);
		strcat(command, totalVars);
		geraCodigo(NULL, command); 
	} | comando_vazio
;

var:
  	VAR declara_vars | declara_vars
;

declara_vars:
	declara_vars declara_var
	| declara_var 
;

// Regra 9
declara_var: 
	{ 
		newVars = 0;
	}
	lista_id_var DOIS_PONTOS tipo 
	{
		countVars += newVars;
	}
	PONTO_E_VIRGULA
;

lista_id_var:
	lista_id_var VIRGULA IDENT 
	{
		newVars++;
		newInput = createSimpleVarInput(token, lexicalLevel, displacement);
		push(&symbolsTable, newInput);
		displacement++;
	}
	| IDENT
	{
		newVars++;
		newInput = createSimpleVarInput(token, lexicalLevel, displacement);
		push(&symbolsTable, newInput);
		displacement++;
	}
;

// Regra 10
lista_idents: 
   	lista_idents VIRGULA IDENT
	{
		newVars++;
		newInput = createSimpleFormalParameterInput(token, lexicalLevel, 1, receivingByReference ? reference : value);
		push(&symbolsTable, newInput);
	}
   	| IDENT
	{
		newVars++;
		newInput = createSimpleFormalParameterInput(token, lexicalLevel, 1, receivingByReference ? reference : value);
		push(&symbolsTable, newInput);
	}
;

// Regra 11
// TODO - Confirmar se deve ir comando vazio aqui A := {a|b} no livro
parte_declara_sub_rotinas:
	parte_declara_sub_rotinas opcoes_sub_rotinas
	| comando_vazio
;

opcoes_sub_rotinas:
	declaracao_procedimento PONTO_E_VIRGULA
	| declaracao_funcao PONTO_E_VIRGULA
;

// Regra 12
declaracao_procedimento:
	PROCEDURE { isSubRoutine = 1; }
	IDENT
	{
		declaredProcedures++;
		
		// Gera rotulos de entrada e saida
		labelSubroutineEnd = generateLabel(labelId);
		labelId++;
		labelSubroutineStart = generateLabel(labelId);
		labelId++;

		pushLabelStack(&labelsTable, labelSubroutineEnd);
		pushLabelStack(&labelsTable, labelSubroutineStart);

		// Soh imprime no primeiro pois desvia pra main
		if(declaredProcedures == 1) {
			// Imprime rotulo de saida da subrotina
			strcpy(command, "DSVS ");
			strcat(command, getNthLabel(&labelsTable, 2));
			geraCodigo(NULL, command);
		}

		// Imprime rotulo de entrada da subrotina
		strcpy(command, getNthLabel(&labelsTable, 1));
		strcat(command, ": ENPR ");
		lexicalLevel++; // Lexical level is elevated on subroutine
		sprintf(varLexDisp, "%d", lexicalLevel);
		strcat(command, varLexDisp);
		geraCodigo(NULL, command); 

		newInput = createSimpleProcedureInput(token, labelSubroutineStart, lexicalLevel, 0);
		push(&symbolsTable, newInput);
	}
	{ newParams = 0; } parametros_formais_vazio PONTO_E_VIRGULA
	{
		// Zera para ser utilizado na subrotina
		// Mas salva valor para ser recuperado
		oldVars = countVars;
		countVars = 0;
		displacement = 0;
	}
	bloco
	{
		// DMEM nas variaveis do procedimento
		pop(&symbolsTable, countVars);
		strcpy(command,"DMEM ");
		sprintf(totalVars, "%d", countVars);
		strcat(command, totalVars);
		geraCodigo(NULL, command);
		
		// Pega procedimento para printar infos da saida dele
		destinyVariable = getNth(&symbolsTable, parameterCount + 1);
		if(destinyVariable == NULL) {
			printf("Procedimento nao encontrado na tabela de simbolos.\n");
			exit(1);
		}

		sprintf(command, "RTPR %d, %d", destinyVariable->lexicalLevel, destinyVariable->numParams);
		pop(&symbolsTable, parameterCount); // Removes parameters from symbols table

		newParams = 0;
		//strcat(command, totalVars);
		geraCodigo(NULL, command);
		lexicalLevel--; // Lexical level is decremented on subroutine end

		destinyVariable = NULL; // Libera variavel destino
		countVars = oldVars;    // Restabelece numero de variaveis no nivel lexico
		isSubRoutine = 0;
		popLabelStack(&labelsTable, 2);
	}
;

parametros_formais_vazio:
	parametros_formais
	| comando_vazio;
;

// Regra 13
declaracao_funcao:
    FUNCTION { isSubRoutine = 1; }
	IDENT
	{
		declaredProcedures++;
		
		// Gera rotulos de entrada e saida
		labelSubroutineEnd = generateLabel(labelId);
		labelId++;
		labelSubroutineStart = generateLabel(labelId);
		labelId++;

		pushLabelStack(&labelsTable, labelSubroutineEnd);
		pushLabelStack(&labelsTable, labelSubroutineStart);

		// Soh imprime no primeiro pois desvia pra main
		if(declaredProcedures == 1) {
			// Imprime rotulo de saida da subrotina
			strcpy(command, "DSVS ");
			strcat(command, getNthLabel(&labelsTable, 2));
			geraCodigo(NULL, command);
		}

		// Imprime rotulo de entrada da subrotina
		strcpy(command, getNthLabel(&labelsTable, 1));
		strcat(command, ": ENPR ");
		lexicalLevel++; // Lexical level is elevated on subroutine
		sprintf(varLexDisp, "%d", lexicalLevel);
		strcat(command, varLexDisp);
		geraCodigo(NULL, command);

		strcpy(functionIdentifier, token);
		newParams = 0;
		newInput = createSimpleFunctionInput(functionIdentifier, labelSubroutineStart, lexicalLevel, 0, undefined);
		push(&symbolsTable, newInput);
	}
	{ newParams = 0; } parametros_formais_vazio
	DOIS_PONTOS tipo_funcao
	{
		// Updates paramters and return type
		newInput = search(&symbolsTable, functionIdentifier);
		newInput->numParams = newParams;
		newInput->type = returnType;
		newInput->displacement = -4 - newParams;
	}
	PONTO_E_VIRGULA
	{
		// Zera para ser utilizado na subrotina
		// Mas salva valor para ser recuperado
		oldVars = countVars;
		countVars = 0;
		displacement = 0;
	}
	bloco
	{
		// DMEM nas variaveis do procedimento
		pop(&symbolsTable, countVars);
		strcpy(command,"DMEM ");
		sprintf(totalVars, "%d", countVars);
		strcat(command, totalVars);
		geraCodigo(NULL, command);
		
		// Pega procedimento para printar infos da saida dele
		destinyVariable = getNth(&symbolsTable, parameterCount + 1);
		if(destinyVariable == NULL) {
			printf("Procedimento nao encontrado na tabela de simbolos.\n");
			exit(1);
		}

		sprintf(command, "RTPR %d, %d", destinyVariable->lexicalLevel, destinyVariable->numParams);
		geraCodigo(NULL, command);

		pop(&symbolsTable, parameterCount); // Removes parameters from symbols table
		newParams = 0;
		lexicalLevel--; // Lexical level is decremented on subroutine end

		destinyVariable = NULL; // Libera variavel destino
		countVars = oldVars;    // Restabelece numero de variaveis no nivel lexico
		isSubRoutine = 0;
		popLabelStack(&labelsTable, 2);
	}
;

tipo_funcao:
	INTEGER { returnType = integer; }
	| BOOLEAN { returnType = boolean; }
;

// Regra 14
parametros_formais:
	ABRE_PARENTESES { parameterCount = 0; }
	lista_parametros_formais
	FECHA_PARENTESES
	{
		updateParams(getNth(&symbolsTable, parameterCount + 1),
								&symbolsTable, parameterCount);
	}
;

lista_parametros_formais:
	lista_parametros_formais PONTO_E_VIRGULA secao_parametros_formais
	| { newParams++; } secao_parametros_formais
;

// Regra 15
secao_parametros_formais:
   	{ parameterCount++; } var_vazio { newVars = 0; } lista_idents DOIS_PONTOS tipo
;

var_vazio:
   	VAR { receivingByReference = 1; } | comando_vazio
;

// Regra 16
comando_composto:
	T_BEGIN comandos T_END
; 

comandos:
	comandos PONTO_E_VIRGULA comando
	| comando
;

// Regra 17
comando: 
   	numero_ou_vazio comando_sem_rotulo
;

numero_ou_vazio:
	numero DOIS_PONTOS
	| comando_vazio
;

comando_vazio:;

// Regra 18
comando_sem_rotulo:
	variavel atribuicao_procedimento
	| desvio
	| comando_composto
	| comando_condicional
	| comando_repetitivo
	| leitura
	| escrita
;

atribuicao_procedimento:
	atribuicao
	| chama_procedimento 
;

// Regra 19
atribuicao:
	ATRIBUICAO expressao
	{
		typeVerify(&typesTable, "atribuicao");
		strcpy(command,"ARMZ ");
		sprintf(varLexDisp, "%d, ", destinyVariable->lexicalLevel);
		strcat(command, varLexDisp);
		sprintf(varLexDisp, "%d", destinyVariable->displacement);
		strcat(command, varLexDisp);
		geraCodigo(NULL, command); 
		destinyVariable = NULL;
	}
;

// Regra 20
chama_procedimento:
    {
		insideProcedure = 1;
		// Imprime rotulo de entrada da subrotina
		currentProcedure = destinyVariable;
		strcpy(callProcedure, "CHPR ");
		strcat(callProcedure, destinyVariable->label);
		sprintf(varLexDisp, ",%d", lexicalLevel);
		strcat(callProcedure, varLexDisp);
   	}
	ABRE_PARENTESES {  receivingFormalParams = 1; newParams = 0; }
	lista_expressoes_ou_vazio
	FECHA_PARENTESES
	{ 
		insideProcedure = 0;
		geraCodigo(NULL, callProcedure); 
		receivingFormalParams = 0;
	}
	{ destinyVariable = NULL; }
	|
	{
		insideProcedure = 1;
		currentProcedure = destinyVariable;
		// Imprime rotulo de entrada da subrotina
		strcpy(callProcedure, "CHPR ");
		strcat(callProcedure, destinyVariable->label);
		sprintf(varLexDisp, ",%d", lexicalLevel);
		strcat(callProcedure, varLexDisp);

		destinyVariable = NULL;
	}
	{ 
		insideProcedure = 0;
    	geraCodigo(NULL, callProcedure); 
	}
;

lista_expressoes_ou_vazio: 
	lista_expressoes
	| comando_vazio
;

// Regra 21
desvio:
   { }
;

// Regra 22
comando_condicional:
	if_then cond_else
	{
		if (!getHasElse()) { //já diminui o iterador
			strcpy(command, getNthLabel(&labelsTable, 1));
			strcat(command, ": NADA");
			geraCodigo(NULL, command); 
		}
		// Imprime rotulo de saida no fim do if
		strcpy(command, getNthLabel(&labelsTable, 2));
		strcat(command, ": NADA");
		geraCodigo(NULL, command); 
		// Remove rotulos do if da entrada e saida da pilha
		popLabelStack(&labelsTable, 2);
	}
;

if_then: 
	IF expressao 
	{  
		initHasElse(); //inicializa se necessario, incrementa o iterador
		// Gera rotulos de entrada e saida
		labelIfStart = generateLabel(labelId);
		labelId++;
		labelIfEnd = generateLabel(labelId);
		labelId++;

		// Adiciona rotulos na pilha
		pushLabelStack(&labelsTable, labelIfStart);
		pushLabelStack(&labelsTable, labelIfEnd);
			
		// Imprime rotulo de entrada no inicio do if
		strcpy(command, "DSVF ");
		strcat(command, getNthLabel(&labelsTable, 1));
		geraCodigo(NULL, command);
	} THEN comando_sem_rotulo
;

cond_else:
	ELSE
	{
		setHasElse(); //marca que a clauseHasElseIterator-ésima cláusula tem else
		// Imprime rotulo de entrada no inicio do if
		strcpy(command, "DSVS ");
		strcat(command, getNthLabel(&labelsTable, 2));
		geraCodigo(NULL, command);

		// Imprime rotulo de entrada no fim do if
		strcpy(command, getNthLabel(&labelsTable, 1));
		strcat(command, ": NADA");
		geraCodigo(NULL, command);
	}
	else_multiplo_unico
	| %prec LOWER_THAN_ELSE
;

else_multiplo_unico:
	comando_sem_rotulo
;

// Regra 23
comando_repetitivo:
	WHILE
	{
		// Gera rotulos de entrada e saida
		labelWhileStart = generateLabel(labelId);
		labelId++;
		labelWhileEnd = generateLabel(labelId);
		labelId++;

		// Adiciona rotulos na pilha
		pushLabelStack(&labelsTable, labelWhileStart);
		pushLabelStack(&labelsTable, labelWhileEnd);

		// Imprime rotulo de entrada no inicio do while
		strcpy(command, getNthLabel(&labelsTable, 2));
		strcat(command, ": NADA");
		geraCodigo(NULL, command); 
	}
	expressao DO
	{
		// Imprime rotulo de saida durante execucao do while
		strcpy(command, "DSVF ");
		strcat(command, getNthLabel(&labelsTable, 1));
		geraCodigo(NULL, command);
	}
	comando_composto
	{ 
		// Imprime rotulo de entrada ao final do while
		strcpy(command, "DSVS ");
		strcat(command, getNthLabel(&labelsTable, 2));
		geraCodigo(NULL, command);

		// Imprime rotulo de saida ao final do while
		strcpy(command, getNthLabel(&labelsTable, 1));
		strcat(command, ": NADA");
		geraCodigo(NULL, command);

		// Remove rotulos do while da entrada e saida da pilha
		popLabelStack(&labelsTable, 2);
	}
	| REPEAT { // Alteracao pedida
		pushLabelStack(&labelsTable, generateLabel(labelId++));
		strcpy(command, getNthLabel(&labelsTable, 1)); //pega o topo
		strcat(command, ": NADA");
		geraCodigo(NULL, command);
	} comandos UNTIL expressao
	{
		strcpy(command, "DSVF ");
		strcat(command, getNthLabel(&labelsTable, 1));
		geraCodigo(NULL, command);
		popLabelStack(&labelsTable, 1);
	}
;

// Regra 24
lista_expressoes: expressao | expressao VIRGULA lista_expressoes;

// Regra 25
expressao:
   	{ newParams++; } expressao_simples relacao_exp_simples_vazio 
;

relacao_exp_simples_vazio:
	relacao expressao_simples
	{ 
		typeVerify(&typesTable, "relacional");
		geraCodigo(NULL, relacaoUsada);
	}
	| comando_vazio
;

// Regra 26
relacao:
	EQUAL { strcpy(relacaoUsada, "CMIG"); } 
	| DIFFERENT { strcpy(relacaoUsada, "CMDG"); } 
	| MINOR { strcpy(relacaoUsada, "CMME"); } 
	| MINOR_EQUAL { strcpy(relacaoUsada, "CMEG"); } 
	| GREATER_EQUAL { strcpy(relacaoUsada, "CMAG"); } 
	| GREATER { strcpy(relacaoUsada, "CMMA"); } 
;

// Regra 27
expressao_simples:
   	mais_menos_vazio expressao_lista_termo
;

mais_menos_vazio:
   	SUM { pureExpression = 0; } | SUBTRACTION { pureExpression = 0; } | comando_vazio;
;

expressao_lista_termo:
	expressao_lista_termo lista_termo 
	| termo 
;

lista_termo:
	{ pureExpression = 0; } SUM termo { typeVerify(&typesTable, "soma"); geraCodigo(NULL, "SOMA"); }
	| { pureExpression = 0; } SUBTRACTION termo { typeVerify(&typesTable, "subtracao"); geraCodigo(NULL, "SUBT"); }
	| { pureExpression = 0; } OR termo { typeVerify(&typesTable, "or"); geraCodigo(NULL, "DISJ"); }
;

// Regra 28
termo:
	termo lista_fator 
	| fator 
;

lista_fator:
	{ pureExpression = 0; } MULTIPLICATION fator { typeVerify(&typesTable, "multiplicacao"); geraCodigo(NULL, "MULT"); }
	| { pureExpression = 0; } DIVISION_REAL fator { typeVerify(&typesTable, "divisao"); geraCodigo(NULL, "DIVI"); }
	| { pureExpression = 0; } AND fator { typeVerify(&typesTable, "and"); geraCodigo(NULL, "CONJ"); }
;

// Regra 29
fator:
   	variavel %prec NADA
	{
		if(loadedVariable != NULL) {
			if(loadedVariable->category == function) {
				strcpy(callProcedure, "CHPR ");
				strcat(callProcedure, loadedVariable->label);
				sprintf(varLexDisp, ", %d", lexicalLevel);
				strcat(callProcedure, varLexDisp);
				geraCodigo(NULL, callProcedure);
			}
			else {
				strcpy(command, "CRVL ");
				sprintf(varLexDisp, "%d, ", loadedVariable->lexicalLevel);
				strcat(command, varLexDisp);
				sprintf(varLexDisp, "%d", loadedVariable->displacement);
				loadedVariable = NULL;
				strcat(command, varLexDisp);
				geraCodigo(NULL, command);
			}
		}
		else {
			if(destinyVariable->category == function) {
				strcpy(callProcedure, "CHPR ");
				strcat(callProcedure, destinyVariable->label);
				sprintf(varLexDisp, ", %d", lexicalLevel);
				strcat(callProcedure, varLexDisp);
				geraCodigo(NULL, callProcedure);
			}
			else {
				strcpy(command, "CRVL ");
				sprintf(varLexDisp, "%d, ", destinyVariable->lexicalLevel);
				strcat(command, varLexDisp);
				sprintf(varLexDisp, "%d", destinyVariable->displacement);
				destinyVariable = NULL;
				strcat(command, varLexDisp);
				geraCodigo(NULL, command);
			}
		}
	}
	| variavel ABRE_PARENTESES
	{
		if(loadedVariable != NULL) {
			if(loadedVariable->category == function) {
				currentProcedure = loadedVariable;
			}
		}
		else {
			if(destinyVariable->category == function) {
				currentProcedure = destinyVariable;
			}
		}
	}
	lista_expressoes FECHA_PARENTESES
	{ 
		strcpy(callProcedure, "CHPR ");
		strcat(callProcedure, currentProcedure->label);
		sprintf(varLexDisp, ",%d", lexicalLevel);
		strcat(callProcedure, varLexDisp);
		geraCodigo(NULL, callProcedure);
	}
	| numero
	| ABRE_PARENTESES expressao FECHA_PARENTESES
	| NOT fator
;

// Regra 30
variavel:
   	IDENT {
		// If null, looks for left side of atribution
		if(destinyVariable == NULL) {
			destinyVariable = search(&symbolsTable, token);
			if(destinyVariable == NULL) {
				printf("Variavel %s nao encontrada na tabela de simbolos.\n", token);
				exit(1);
			}
			pushTypeStack(&typesTable, destinyVariable->type);
		}
		else { // Otherwise, looks for right side
			loadedVariable = search(&symbolsTable, token);
			if(loadedVariable == NULL) {
				printf("Variavel %s nao encontrada na tabela de simbolos.\n", token);
				exit(1);
			}
			pushTypeStack(&typesTable, loadedVariable->type);
		}
   	}
;

// Regra 32
numero:
	NUMBER
	{
		pushTypeStack(&typesTable, integer);
		strcpy(command,"CRCT ");
		sprintf(totalVars, "%s", token);
		strcat(command, totalVars);
		geraCodigo(NULL, command); 
	}
;

// Comandos sem regra --> leitura e escrita
leitura:
  	READ ABRE_PARENTESES lista_leitura FECHA_PARENTESES
;

lista_leitura:
   	lista_leitura VIRGULA simbolo_leitura
   	| simbolo_leitura
;

simbolo_leitura:
	IDENT
	{
		// Codigo leitura
		geraCodigo(NULL, "LEIT");
		
		// Procura por variavel na tabela de simbolos
		destinyVariable = search(&symbolsTable, token);
		if(destinyVariable == NULL) {
			printf("Variavel nao encontrada na tabela de simbolos.\n");
			exit(1);
		}

		// Armazena na variavel
		strcpy(command,"ARMZ ");
		sprintf(varLexDisp, "%d, ", destinyVariable->lexicalLevel);
		strcat(command, varLexDisp);
		sprintf(varLexDisp, "%d", destinyVariable->displacement);
		strcat(command, varLexDisp);
		geraCodigo(NULL, command); 
		destinyVariable = NULL;
	}
;

escrita:
   	WRITE ABRE_PARENTESES lista_escrita FECHA_PARENTESES
;

lista_escrita:
	lista_escrita VIRGULA expressao { geraCodigo (NULL, "IMPR"); }
	| expressao { geraCodigo (NULL, "IMPR"); }
;

%%

int main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   if (argc<2 || argc>2) {
         printf("usage compilador <arq>a %d\n", argc);
         return(-1);
      }

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("usage compilador <arq>b\n");
      return(-1);
   }


/* -------------------------------------------------------------------
 *  Inicia a Tabela de S�mbolos
 * ------------------------------------------------------------------- */
	createStack(&symbolsTable);
	createTypeStack(&typesTable);
	createLabelStack(&labelsTable);
	insideProcedure = 0;
	clauseHasElse = 0;
	oldParams = newParams = 0;
	receivingByReference = 0;
	receivingFormalParams = 0;
	returnType = undefined;
	countVars = 0;
	newVars = 0;
	oldVars = 0;
	lexicalLevel = 0;
	displacement = 0;
	declaredProcedures = 0;
	labelId = 0;
	yyin=fp;
	yyparse();

   return 0;
}

