
/* -------------------------------------------------------------------
 *            Aquivo: compilador.c
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [15/03/2012, 08h:22m]
 *
 * -------------------------------------------------------------------
 *
 * Fun��es auxiliares ao compilador
 *
 * ------------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"


/* -------------------------------------------------------------------
 *  vari�veis globais
 * ------------------------------------------------------------------- */

FILE* fp=NULL;

int imprimeErro ( char* erro ) {
  fprintf (stderr, "Erro na linha %d - %s\n", nl, erro);
  exit(-1);
}

void geraCodigo(char* rot, char* comando) {

  if (fp == NULL) {
    fp = fopen ("MEPA", "w");
  }

  if ( rot == NULL ) {
    if(comando[0] == 'R')
      if(comando[1] != 'T')
        { fprintf(fp, "%s\n", comando); fflush(fp); }
      else
        { fprintf(fp, "    %s\n", comando); fflush(fp); }
    else
      { fprintf(fp, "    %s\n", comando); fflush(fp); }
  } else {
    fprintf(fp, "%s: %s \n", rot, comando); fflush(fp);
  }
}
