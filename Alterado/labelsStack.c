#include "labelsStack.h"

char* generateLabel(int labelId) {
    char *label = (char*)malloc(4 * sizeof(char));
    sprintf(label, "R%02d", labelId);

    return label;
}

void createLabelStack(labelsStack *labelsTable) {
    labelsTable->size = 0;
    labelsTable->top = NULL;
}

int emptyLabelStack(labelsStack *labelsTable) {
    return (labelsTable->size == 0);
}

void pushLabelStack(labelsStack *labelsTable, char *newLabel) {
    labelNode *newSymbol;
    newSymbol = (labelNode*)malloc(sizeof(labelNode));
    newSymbol->label = (char*)malloc(4 * sizeof(char));
    newSymbol->label = newLabel;

    newSymbol->next = labelsTable->top;
    labelsTable->top = newSymbol;
    labelsTable->size++;
}

void popLabelStack(labelsStack *labelsTable, int n) {
    if(emptyLabelStack(labelsTable)) {
        puts("Pilha de rotulos vazia");
        exit(1);
    }

    int i = 0;
    labelNode *temp;
    while((i < n) && (labelsTable->size > 0)) {
        temp = labelsTable->top;
        labelsTable->top = labelsTable->top->next;
        free(temp);
        labelsTable->size--;
        i++;
    }
}

char* getNthLabel(labelsStack *labelsTable, int n) {
    if(emptyLabelStack(labelsTable)) {
        puts("Pilha de rotulos vazia");
        exit(1);
    }

    labelNode *node = labelsTable->top;
	if (!n) n++;
	while (--n)
		node = node->next;

	return node->label;
}