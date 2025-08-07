#ifndef SISTEMA_H_
#define SISTEMA_H_

#include "estudante.h"

struct base_de_dados
{
    estudante* student;
    int num_logins;
};

struct base_de_gerentes
{
    gerente* manager;
    int num_logins_man;
};
typedef struct base_de_dados* sistema;

sistema cria_sistema();
void liberta_sistema(sistema s);
void libertar_estudante(estudante e);
void libertar_quarto(quarto q);

int encontrar_estudante_sistema(sistema s, char* username);
void adicionar_estudante_sistema(sistema s, char* login, char* name, int age, char* local, char* fct);

sistema_gerentes cria_sistema_man();
int encontrar_manager_sistema(sistema_gerentes sg, char* username);
void apagarDadosGerente(gerente g);
void liberta_sistema_man(sistema_gerentes sg);
void adicionar_gerente_sistema(sistema_gerentes sg, char* login, char* name,char* fct);
#endif