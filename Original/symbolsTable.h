#ifndef __SYMBOLS_TABLE__
#define __SYMBOLS_TABLE__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "typesStack.h"

typedef enum categoryType {
	simpleVar,
	formalParameter,
	procedure,
	function,
} categoryType;

typedef enum passType {
	value,
	reference
} passType;

typedef struct paramDesc {
	char *identifier;
	pascalType type;
	passType pass;
} paramDesc;

typedef struct stackNode {
	char *identifier, *label;
	categoryType category;
	int lexicalLevel, displacement, numParams;
	pascalType type;
	passType pass;
	paramDesc *params;
	//TODO: free disso ^

	struct stackNode *next;
} stackNode;

typedef struct symbolsStack {
	int size;
	stackNode *top;
} symbolsStack;

void createStack(symbolsStack *symbolsTable);
int emptyStack(symbolsStack *symbolsTable);
void push(symbolsStack *symbolsTable, stackNode *newSymbol);
stackNode* getTop(symbolsStack *symbolsTable);
stackNode* getNth(symbolsStack *symbolsTable, int n);
stackNode* search(symbolsStack *symbolsTable, char *identifier);
void pop(symbolsStack *symbolsTable, int n);
stackNode* createSimpleVarInput(char *identifier, int lexicalLevel, int displacement);
stackNode* createSimpleFunctionInput(char *identifier, char *label, int lexicalLevel, int numParams, pascalType returnType);
stackNode* createSimpleProcedureInput(char *identifier, char *label, int lexicalLevel, int numParams);
stackNode* createSimpleFormalParameterInput(char *identifier, int lexicalLevel, int displacement, passType pass);
void setTypes(symbolsStack *symbolsTable, pascalType type, int n);

void printTable(symbolsStack *symbolsTable);

void updateParams(stackNode *p, symbolsStack *symbolsTable, int parameterCount);

#endif
