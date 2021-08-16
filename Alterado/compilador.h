/* -------------------------------------------------------------------
 *            Arquivo: compilaodr.h
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [15/03/2012, 08h:22m]
 *
 * -------------------------------------------------------------------
 *
 * Tipos, prot�tipos e vai�veis globais do compilador
 *
 * ------------------------------------------------------------------- */

#define TAM_TOKEN 16

typedef enum simbolos { 
  simb_program, simb_var, simb_begin, simb_end, 
  simb_identificador, simb_numero,
  simb_ponto, simb_virgula, simb_ponto_e_virgula, simb_dois_pontos,
  simb_atribuicao, simb_abre_parenteses, simb_fecha_parenteses,
  simb_label, simb_procedimento, simb_funcao,
  simb_goto, simb_se, simb_entao, simb_senao, simb_enquanto, simb_faca, simb_repete, simb_ate, simb_igual,
  simb_diferente, simb_menor, simb_menor_igual, simb_maior_igual, simb_maior, simb_soma,
  simb_subtracao, simb_multiplicacao, simb_divisao_real, simb_divisao_inteira, simb_ou, simb_and, simb_negacao,
  simb_abre_colchetes, simb_fecha_colchetes, simb_integer, simb_boolean, simb_read, simb_write, simb_number
} simbolos;



/* -------------------------------------------------------------------
 * vari�veis globais
 * ------------------------------------------------------------------- */

extern simbolos simbolo, relacao;
extern char token[TAM_TOKEN];
extern int nivel_lexico;
extern int desloc;
extern int nl;


simbolos simbolo, relacao;
char token[TAM_TOKEN];



