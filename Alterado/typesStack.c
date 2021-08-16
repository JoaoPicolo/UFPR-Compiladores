#include "typesStack.h"

void createTypeStack(typesStack *typesTable) {
    typesTable->size = 0;
    typesTable->top = NULL;
}

int emptyTypeStack(typesStack *typesTable) {
    return (typesTable->size == 0);
}

void pushTypeStack(typesStack *typesTable, pascalType type) {
    typeNode *newSymbol;
    newSymbol = (typeNode*)malloc(sizeof(typeNode));
    newSymbol->type = type;

    newSymbol->next = typesTable->top;
    typesTable->top = newSymbol;
    typesTable->size++;
}

pascalType popTypeStack(typesStack *typesTable) {
    if(emptyTypeStack(typesTable)) {
        puts("Pilha de tipos vazia");
        exit(1);
    }

    typeNode *temp;
    temp = typesTable->top;

    // Top receives previous, but no free is done (compare with symbolsTable.c)
    typesTable->top = typesTable->top->next;
    typesTable->size--;

    return temp->type;
}

char* defineType(pascalType type) {
    if(type == integer) {
        return "inteiro";
    }
    else if(type == boolean) {
        return "booleano";
    }
    else {
        return "indefinido";
    }
}

void typeVerify(typesStack *typesTable, char* operation) {
    pascalType type1, type2;

    type1 = popTypeStack(typesTable);
    type2 = popTypeStack(typesTable);

    if(type1 == type2) { // Push result, execpt on assignment
        if(strcmp(operation, "atribuicao") != 0) { // Returns zero if equal
            if(strcmp(operation, "soma") == 0 || strcmp(operation, "subtracao") == 0
                || strcmp(operation, "multiplicacao") == 0 || strcmp(operation, "divisao") == 0)
                pushTypeStack(typesTable, integer);
            else
                pushTypeStack(typesTable, boolean);
        }
    }
    else {
        printf("Variaveis possuem tipos diferentes.\n");
        printf("Operacao de %s com %s e %s\n", operation, defineType(type1), defineType(type2));
        exit(1);
    }
}

void printTypeTable(typesStack *typesTable) {
    typeNode *aux = typesTable->top;
    while(aux != NULL) {
        printf("------------> tp: %d\n", aux->type);
        aux = aux->next;
    }
}
