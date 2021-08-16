#ifndef __LABELS_STACK__
#define __LABELS_STACK__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct labelNode {
	char *label;

	struct labelNode *next;
} labelNode;

typedef struct labelsStack {
	int size;
	labelNode *top;
} labelsStack;

char* generateLabel(int labelId);
void createLabelStack(labelsStack *labelsTable);
int emptyLabelStack(labelsStack *labelsTable);
void pushLabelStack(labelsStack *labelsTable, char *newLabel);
void popLabelStack(labelsStack *labelsTable, int n);
char* getNthLabel(labelsStack *labelsTable, int n);

#endif