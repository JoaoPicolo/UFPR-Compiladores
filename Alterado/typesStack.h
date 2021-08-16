#ifndef __TYPES_STACK__
#define __TYPES_STACK__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum pascalType {
	integer,
	boolean,
	undefined,
} pascalType;

typedef struct typeNode {
	pascalType type;
	struct typeNode *next;
} typeNode;

typedef struct typesStack {
	int size;
	typeNode *top;
} typesStack;

void createTypeStack(typesStack *typesTable);
int emptyTypeStack(typesStack *typesTable);
void pushTypeStack(typesStack *typesTable, pascalType type);
pascalType popTypeStack(typesStack *typesTable);
char* defineType(pascalType type);
void typeVerify(typesStack *typesTable, char* operation);
void printTypeTable(typesStack *typesTable);

#endif