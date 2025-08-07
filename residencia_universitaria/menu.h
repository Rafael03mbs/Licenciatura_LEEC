#ifndef MENU_H_
#define MENU_H_

typedef struct base_estudante * estudante;
typedef struct base_gerente * gerente;
typedef struct base_de_dados* sistema;
typedef struct base_de_gerentes* sistema_gerentes;
typedef struct base_candidato * candidato;
typedef struct base_quarto* quarto;

char* juntanome(char nome[], char apelido[]);
void funcao_ie(char* instrucao, sistema s);
void funcao_de(char* instrucao, sistema s);
void funcao_ig(char* instrucao, sistema_gerentes sg, gerente g);
void funcao_dg(char* instrucao, sistema_gerentes sg);
void funcao_iq(char* instrucao, sistema_gerentes sg,gerente g);
void funcao_dq(char* instrucao, quarto *q);
void remover_quarto(char* codigo,candidato c,quarto* q);
void modificar_estado_quarto(char* instrucao, candidato c); 
void registrar_candidatura(char* instrucao, candidato* c);
void aceita_candidato(char* instrucao,candidato *c,sistema s);
void funcao_lc(char* instrucao,sistema s);


#endif

