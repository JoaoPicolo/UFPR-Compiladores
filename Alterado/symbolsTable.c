#include "symbolsTable.h"

void createStack(symbolsStack *symbolsTable) {
    symbolsTable->size = 0;
    symbolsTable->top = NULL;
}

int emptyStack(symbolsStack *symbolsTable) {
    return (symbolsTable->size == 0);
}

void push(symbolsStack *symbolsTable, stackNode *newSymbol) {
    newSymbol->next = symbolsTable->top;
    symbolsTable->top = newSymbol;
    symbolsTable->size++;
}

stackNode* getTop(symbolsStack *symbolsTable) {
    if(emptyStack(symbolsTable)) {
        puts("Pilha vazia");
        return NULL;
    }
    
    return symbolsTable->top;
}

stackNode* getNth(symbolsStack *symbolsTable, int n) {
	if(emptyStack(symbolsTable) || symbolsTable->size < n) {
			puts("Pilha vazia ou de tamanho insuficiente");
			return NULL;
	}
	stackNode *node = symbolsTable->top;
	if (!n) n++;
	while (--n)
		node = node->next;
	return node;
}

stackNode* search(symbolsStack *symbolsTable, char *identifier) {
    if(emptyStack(symbolsTable)) {
        puts("Pilha vazia");
        return NULL;
    }
    stackNode *node;
    int hasFound = 0;

    node = symbolsTable->top;
    while(node != NULL) {
        // Returns zero if equal
        hasFound = !strcmp(node->identifier, identifier);
        if(hasFound) {
            return node;
        }
        node = node->next;
    }

    if(!hasFound) {
        return NULL;
    }

    return node;
}

void pop(symbolsStack *symbolsTable, int n) {
    if(emptyStack(symbolsTable)) {
        puts("Pilha vazia");
        exit(1);
    }

    int i = 0;
    stackNode *temp;
    while((i < n) && (symbolsTable->size > 0)) {
        temp = symbolsTable->top;
        symbolsTable->top = symbolsTable->top->next;
        free(temp);
        symbolsTable->size--;
        i++;
    }
}

stackNode* createSimpleVarInput(char *identifier, int lexicalLevel, int displacement) {
    stackNode *newNode = (stackNode*)malloc(sizeof(stackNode));

    newNode->identifier = (char*)malloc(strlen(identifier) * sizeof(char));
    strcpy(newNode->identifier, identifier);
    
    newNode->category = simpleVar;
    newNode->lexicalLevel = lexicalLevel;
    newNode->displacement = displacement;
    newNode->type = undefined;

    return newNode;
}

stackNode* createSimpleFunctionInput(char *identifier, char *label, int lexicalLevel, int numParams, pascalType returnType) {
    stackNode *newNode = (stackNode*)malloc(sizeof(stackNode));

    newNode->identifier = (char*)malloc(strlen(identifier) * sizeof(char));
    strcpy(newNode->identifier, identifier);

    newNode->label = (char*)malloc(strlen(label) * sizeof(char));
    strcpy(newNode->label, label);
    
    newNode->category = function;
    newNode->lexicalLevel = lexicalLevel;
	newNode->displacement = -4-numParams;
    newNode->numParams = numParams;
	newNode->params = NULL;
	newNode->type = returnType;

    return newNode;
}

stackNode* createSimpleProcedureInput(char *identifier, char *label, int lexicalLevel, int numParams) {
    stackNode *newNode = (stackNode*)malloc(sizeof(stackNode));

    newNode->identifier = (char*)malloc(strlen(identifier) * sizeof(char));
    strcpy(newNode->identifier, identifier);

    newNode->label = (char*)malloc(strlen(label) * sizeof(char));
    strcpy(newNode->label, label);
    
    newNode->category = procedure;
    newNode->lexicalLevel = lexicalLevel;
    newNode->numParams = numParams;
    newNode->params = NULL;

    return newNode;
}

stackNode* createSimpleFormalParameterInput(char *identifier, int lexicalLevel, int displacement, passType pass) {
    stackNode *newNode = (stackNode*)malloc(sizeof(stackNode));

    newNode->identifier = (char*)malloc(strlen(identifier) * sizeof(char));
    strcpy(newNode->identifier, identifier);
    
    newNode->category = formalParameter;
    newNode->lexicalLevel = lexicalLevel;
		newNode->displacement = displacement;
		newNode->pass = pass;
		newNode->type = undefined;

    return newNode;
}

void setTypes(symbolsStack *symbolsTable, pascalType type, int n) {
    if(emptyStack(symbolsTable)) {
        puts("Pilha vazia");
        exit(1);
    }

    int i = 0;
    stackNode *aux = symbolsTable->top;
    while((i < n) && (aux != NULL)) {
        aux->type = type;
        aux = aux->next;
        i++;
    }
}

void printTable(symbolsStack *symbolsTable) {
    stackNode *aux = symbolsTable->top;
    while(aux != NULL) {
        printf("--------------> VAR\n");
				printf("--> &x: %p\n", aux);
        printf("--> id: %s\n", aux->identifier);
        printf("--> lb: %s\n", aux->label);
				printf("--> &p: %p\n", aux->params);
				printf("--> #p: %d\n", aux->numParams);
				printf("--> nl, ds: %d, %d\n", aux->lexicalLevel, aux->displacement);
				printf("--> cat: (%d) SV, (%d) FP, (%d) PR\n", aux->type == simpleVar, aux->type == formalParameter, aux->type == procedure);
				printf("--> type: (%d) int, (%d) bool, (%d) undef\n", aux->type == integer, aux->type == boolean, aux->type == undefined);
				printf("--> ref: %d\n", aux->pass == reference);
        aux = aux->next;
    }
}

void updateParams(stackNode *p, symbolsStack *symbolsTable, int parameterCount) {
	if (symbolsTable->size < parameterCount)
		puts("Pilha não tem elementos o suficiente");
	p->numParams = parameterCount;
	p->params = (paramDesc*)malloc(parameterCount * sizeof(paramDesc));
	stackNode *aux = symbolsTable->top;
	for (int i = 0; i < parameterCount; i++) {
		p->params[i].identifier = (char*)malloc(strlen(aux->identifier)*sizeof(char));
		strcpy(p->params[i].identifier, aux->identifier);
		p->params[i].type = aux->type;
		p->params[i].pass = aux->pass;
		aux->displacement = -4-i;
		aux = aux->next;
	}
	aux->numParams = parameterCount;
}
